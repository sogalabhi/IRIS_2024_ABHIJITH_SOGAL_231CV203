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
  @override
  void initState() {
    getHostelsList();
    super.initState();
  }

  Map<String, dynamic> allHostels = {};
  void getHostelsList() async {
    // Loop through each document and store it in the map
    QuerySnapshot hostelSnapshot =
        await FirebaseFirestore.instance.collection('hostels').get();
    for (var doc in hostelSnapshot.docs) {
      setState(() {
        allHostels[doc.id] = doc.data();
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAllHostels() async {
    List<Map<String, dynamic>> hostels = [];
    try {
      // Fetch all documents from the 'hostels' collection
      QuerySnapshot hostelChangeRequests = await FirebaseFirestore.instance
          .collection('hostel_change_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in hostelChangeRequests.docs) {
        Map requestData = doc.data() as Map;
        String uid = requestData['userId'];
        String hostelId = requestData['hostelId'];
        String floorId = requestData['floorId'];
        String wingId = requestData['wingId'];
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        Map userData = userSnapshot.data() as Map;
        DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .get();
        Map<String, dynamic> hostelData =
            hostelSnapshot.data() as Map<String, dynamic>;
        hostels.add({
          'request': requestData,
          'user': userData,
          'hostel': hostelData,
          'floorId': floorId,
          'wingId': wingId,
        });
      }
    } catch (e) {
      print("Error fetching hostels: $e");
    }
    return hostels; // Return the hostels map
  }

  Future<List<Map<String, dynamic>>> getAllRequestHIstory() async {
    List<Map<String, dynamic>> history = [];
    try {
      QuerySnapshot hostelChangeRequestshistory = await FirebaseFirestore
          .instance
          .collection('hostel_change_requests')
          .where('status', whereIn: ['approved', 'rejected']).get();
      // Loop through each document and store it in the map
      for (var doc in hostelChangeRequestshistory.docs) {
        Map requestData = doc.data() as Map;
        String uid = requestData['userId'];
        String hostelId = requestData['hostelId'];
        String floorId = requestData['floorId'];
        String wingId = requestData['wingId'];
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        Map userData = userSnapshot.data() as Map;
        DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .get();
        Map<String, dynamic> hostelData =
            hostelSnapshot.data() as Map<String, dynamic>;

        history.add({
          'request': requestData,
          'user': userData,
          'hostel': hostelData,
          'floorId': floorId,
          'wingId': wingId,
        });
      }
    } catch (e) {
      print("Error fetching hostels: $e");
    }
    return history; // Return the hostels map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Change Requests',
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white), // AppBar color
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

            FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllHostels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hostel change requests found'));
                }

                // List of hostel change requests with user and hostel data
                List<Map<String, dynamic>> requests = snapshot.data!;

                return Expanded(
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> requestData =
                          requests[index]['request'];
                      Map<String, dynamic> userData = requests[index]['user'];
                      Map<String, dynamic> hostelData =
                          requests[index]['hostel'];
                      String wingId = requests[index]['wingId'];
                      String floorId = requests[index]['floorId'];
                      return _buildRequestCard(
                          request: requests[index],
                          availableVacancies: hostelData['floors'][floorId]
                              ['wings'][wingId]['vacancies'],
                          currentHostel: userData['currentHostel']
                              ['hostelName'],
                          requestedFloor: requestData['floorNumber'],
                          requestedHostel: requestData['hostelName'],
                          requestedWing: requestData['wingName'],
                          userName: userData['name'],
                          allHostels: allHostels);
                    },
                  ),
                );
              },
            ),
            // Divider to separate sections
            const Divider(height: 30, color: Colors.grey),

            // Request History Section
            const Text(
              'Request History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllRequestHIstory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No hostel change requests found'));
                }

                // List of hostel change requests with user and hostel data
                List<Map<String, dynamic>> requests = snapshot.data!;
                return Expanded(
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> requestData =
                          requests[index]['request'];
                      Map<String, dynamic> userData = requests[index]['user'];
                      Map<String, dynamic> hostelData =
                          requests[index]['hostel'];
                      String wingId = requests[index]['wingId'];
                      String floorId = requests[index]['floorId'];
                      return _buildHistoryCard(
                        action: requestData['status'],
                        rollNumber: userData['rollNumber'],
                        toHostel: requestData['hostelName'],
                        userName: userData['name'],
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> updateHostelData(Map<String, dynamic> hostels, String hostelId,
      String wingId, String floorId, String userId, String statusmsg) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelData = hostels;
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
          'floorNumber': updatedHostelData[hostelId]['floors'][floorId]['name'],
        },
        'newHostel': FieldValue.delete(),
      });
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('hostel_change_requests')
          .doc(userId);

      // Update the 'vacancies' field
      await docRef.update({
        'status': statusmsg, // Set the field to the new value
      }).then((_) {
        print("Field updated successfully!");
      }).catchError((error) {
        print("Error updating field: $error");
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
  }
  Future<void> rejectHostel(String userId, String statusmsg) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Update the current hostel in the user's document
      await firestore.collection('users').doc(userId).update({
        'newHostel': FieldValue.delete(),
      });
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('hostel_change_requests')
          .doc(userId);

      // Update the 'vacancies' field
      await docRef.update({
        'status': statusmsg, // Set the field to the new value
      }).then((_) {
        print("Field updated successfully!");
      }).catchError((error) {
        print("Error updating field: $error");
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
  }

  // Card Widget for Pending Requests
  Widget _buildRequestCard(
      {required Map request,
      required String userName,
      required String currentHostel,
      required String requestedHostel,
      required String requestedWing,
      required String requestedFloor,
      required int availableVacancies,
      required Map allHostels}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Current Hostel: $currentHostel'),
            Text('Requested Hostel: $requestedHostel'),
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
                    if (availableVacancies > 0) {
                      String newhostelId = request['request']['hostelId'];
                      String oldhostelId =
                          request['user']['currentHostel']['hostelId'];
                      String newfloorId = request['request']['floorId'];
                      String oldfloorId =
                          request['user']['currentHostel']['floorId'];
                      String newwingId = request['request']['wingId'];
                      String oldwingId =
                          request['user']['currentHostel']['wingId'];

                      //Decrease vacancy in new hostel
                      //1. total vacancies
                      allHostels[newhostelId]['totalVacancies']--;
                      //2. floor vacancy
                      allHostels[newhostelId]['floors'][newfloorId]
                          ['vacancies']--;
                      //3. wing vacancy
                      allHostels[newhostelId]['floors'][newfloorId]['wings']
                          [newwingId]['vacancies']--;

                      //Increase vacancy in old hostel
                      //1. total vacancies
                      allHostels[oldhostelId]['totalVacancies']++;
                      //2. floor vacancy
                      allHostels[oldhostelId]['floors'][oldfloorId]
                          ['vacancies']++;
                      // //3. wing vacancy
                      allHostels[oldhostelId]['floors'][oldfloorId]['wings']
                          [oldwingId]['vacancies']++;
                      print("Update hostel data: ${allHostels[oldhostelId]}");
                      String uid = request['request']['userId'];
                      //   print('uid $selectedHostel $selectedWing $selectedFloor');
                      updateHostelData(allHostels as Map<String, dynamic>,
                          newhostelId, newwingId, newfloorId, uid, "approved");
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Application approved'),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green),
                  ),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                   rejectHostel(request['request']['userId'], "rejected");
                   Navigator.pop(context);
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
    required String rollNumber,
    required String toHostel,
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
              'Name: $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Action: $action'),
            Text('Roll Number: $rollNumber'),
            Text('To Hostel: $toHostel'),
          ],
        ),
      ),
    );
  }
}
