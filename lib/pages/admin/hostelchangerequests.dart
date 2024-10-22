import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HostelChangeRequestsPage extends StatefulWidget {
  const HostelChangeRequestsPage({super.key});

  @override
  State<HostelChangeRequestsPage> createState() =>
      _HostelChangeRequestsPageState();
}

class _HostelChangeRequestsPageState extends State<HostelChangeRequestsPage> {
  Map<String, dynamic> hostels = {};

  Future<Map<String, dynamic>> getAllHostels() async {
    try {
      // Fetch all documents from the 'hostels' collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('hostels').get();

      // Loop through each document and store it in the map
      for (var doc in querySnapshot.docs) {
        setState(() {
          hostels[doc.id] = doc
              .data(); // doc.id is the document ID, doc.data() contains the data
              print(hostels);
        });
      }
    } catch (e) {
      print("Error fetching hostels: $e");
    }
    return hostels; // Return the hostels map
  }
@override
  void initState() {
    getAllHostels();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Change Requests'),
        backgroundColor: Colors.deepPurpleAccent, // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Requests Section
            const Text(
              'Pending Requests',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildRequestCard(
                    userName: 'John Doe',
                    currentHostel: 'Hostel A',
                    requestedWing: 'Wing 2',
                    requestedFloor: 'Floor 3',
                    availableVacancies: 5,
                  ),
                  _buildRequestCard(
                    userName: 'Jane Smith',
                    currentHostel: 'Hostel B',
                    requestedWing: 'Wing 1',
                    requestedFloor: 'Floor 2',
                    availableVacancies: 2,
                  ),
                ],
              ),
            ),

            // Divider to separate sections
            const Divider(height: 30, color: Colors.grey),

            // Request History Section
            const Text(
              'Request History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryCard(
                    userName: 'John Doe',
                    action: 'Approved',
                    date: '12 Oct, 2024',
                  ),
                  _buildHistoryCard(
                    userName: 'Jane Smith',
                    action: 'Rejected',
                    date: '10 Oct, 2024',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateHostelData(Map<String, dynamic> hostels, String hostelId,
      String wingId, String floorId, String userId) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelData = hostels;
    print("updatedHostelData: $updatedHostelData");
    WriteBatch batch = firestore.batch();
    try {
      updatedHostelData.forEach((hostelId, hostelInfo) {
        DocumentReference docRef =
            firestore.collection('hostels').doc(hostelId);
        batch.set(
            docRef, hostelInfo); // Use set to overwrite the entire document
      });
      await batch.commit();

      print('Hostels updated successfully.');
      // Update the current hostel in the user's document
      await firestore.collection('users').doc(userId).update({
        'currentHostel': {
          'hostelId': hostelId,
          'hostelName': updatedHostelData[hostelId]['name'],
          'wingId': wingId,
          'wingName': updatedHostelData[hostelId]['floors'][floorId]['wings']
              [wingId]['name'],
          'floorId': floorId,
          'floorNumber ': updatedHostelData[hostelId]['floors'][floorId]
              ['name'],
        },
      });
      var userBox = await Hive.openBox('userBox');
      await userBox.put('currentHostel', {
        'currentHostel': {
          'hostelId': hostelId,
          'hostelName': updatedHostelData[hostelId]['name'],
          'wingId': wingId,
          'wingName': updatedHostelData[hostelId]['floors'][floorId]['wings']
              [wingId]['name'],
          'floorId': floorId,
          'floorNumber': updatedHostelData[hostelId]['floors'][floorId]['wings']
              [wingId]['name'],
        },
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
  }

  // Card Widget for Pending Requests
  Widget _buildRequestCard({
    required String userName,
    required String currentHostel,
    required String requestedWing,
    required String requestedFloor,
    required int availableVacancies,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Current Hostel: $currentHostel'),
            Text('Requested Wing: $requestedWing'),
            Text('Requested Floor: $requestedFloor'),
            const SizedBox(height: 8),
            Text(
              'Available Vacancies: $availableVacancies',
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // if (hostels[selectedHostel]!['floors'][selectedFloor]
                    //         ['wings'][selectedWing]['vacancies'] >
                    //     0) {
                    //   // Decrease total vacancies for the selected hostel
                    //   hostels[selectedHostel]!['totalVacancies']--;

                    //   // Decrease vacancies for the selected floor
                    //   hostels[selectedHostel]!['floors'][selectedFloor]
                    //       ['vacancies']--;

                    //   // Decrease vacancies for the selected wing
                    //   hostels[selectedHostel]!['floors'][selectedFloor]['wings']
                    //       [selectedWing]['vacancies']--;

                    //   // INcrease vacancies in old hostel floor wing
                    //   var oldhostelid =
                    //       widget.currentHostel['currentHostel']['hostelId'];
                    //   var oldfloorid =
                    //       widget.currentHostel['currentHostel']['floorId'];
                    //   var oldwingid =
                    //       widget.currentHostel['currentHostel']['wingId'];

                    //   hostels[oldhostelid]!['totalVacancies']++;
                    //   hostels[oldhostelid]!['floors'][oldfloorid]
                    //       ['vacancies']++;
                    //   hostels[oldhostelid]!['floors'][oldfloorid]['wings']
                    //       [oldwingid]['vacancies']++;

                    //   print("Update hostel data: $hostels");
                    //   var uid = FirebaseAuth.instance.currentUser?.uid;
                    //   print('uid $selectedHostel $selectedWing $selectedFloor');
                    //   updateHostelData(
                    //       selectedHostel!, selectedWing!, selectedFloor!, uid!);
                    //   Navigator.pop(context, {
                    //     'hostel': hostels[selectedHostel]!['name'],
                    //     'wing': hostels[selectedHostel]!['floors']
                    //         [selectedFloor]['wings'][selectedWing]['name'],
                    //     'floor': hostels[selectedHostel]!['floors']
                    //         [selectedFloor]['name']
                    //   });
                    // }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                  ),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Reject logic
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.red),
                  ),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card Widget for Request History
  Widget _buildHistoryCard({
    required String userName,
    required String action,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Action: $action'),
            Text('Date: $date'),
          ],
        ),
      ),
    );
  }
}
