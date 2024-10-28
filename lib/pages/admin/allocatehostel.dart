import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HostelAllocationPage extends StatefulWidget {
  final Map userData;
  final String uid;
  const HostelAllocationPage({super.key, required this.userData, required this.uid});
  @override
  State<HostelAllocationPage> createState() => _HostelAllocationPageState();
}

class _HostelAllocationPageState extends State<HostelAllocationPage> {
  String? selectedHostel;
  String? selectedWing;
  String? selectedFloor;
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
        });
      }
    } catch (e) {
      print("Error fetching hostels: $e");
    }
    return hostels; // Return the hostels map
  }

  Future<void> updateHostelData(
      String hostelId, String wingId, String floorId, String userId) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Use a batch write for efficient upload
    WriteBatch batch = firestore.batch();

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelData = hostels;
    print("updatedHostelData: $updatedHostelData");
    try {
      // Iterate through the Map and upload each hostel document
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
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
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
        title: const Text(
          "Allocate hostel",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text('Select Hostel'),
              value: selectedHostel,
              isExpanded: true,
              items: hostels.keys.map((String hostelKey) {
                return DropdownMenuItem<String>(
                  value: hostelKey,
                  child: Text(hostels[hostelKey]['name']),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedHostel = newValue;
                  selectedWing = null; // Reset wing dropdown on hostel change
                  selectedFloor = null; // Reset wing dropdown on hostel change
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select Floor'),
              value: selectedFloor,
              isExpanded: true,
              items: selectedHostel != null
                  ? (hostels[selectedHostel]!['floors'] as Map<String, dynamic>)
                      .keys
                      .map((String floorKey) {
                      return DropdownMenuItem<String>(
                        value: floorKey,
                        child: Text(hostels[selectedHostel]!['floors'][floorKey]
                            ['name']),
                      );
                    }).toList()
                  : [],
              onChanged: (newValue) {
                setState(() {
                  selectedFloor = newValue;
                  selectedWing = null;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select Wing'),
              value: selectedWing,
              isExpanded: true,
              items: selectedHostel != null && selectedFloor != null
                  ? (hostels[selectedHostel]!['floors'][selectedFloor]['wings']
                          as Map<String, dynamic>)
                      .keys
                      .map((String wingKey) {
                      return DropdownMenuItem<String>(
                        value: wingKey,
                        child: Text(hostels[selectedHostel]!['floors']
                            [selectedFloor]['wings'][wingKey]['name']),
                      );
                    }).toList()
                  : [],
              onChanged: (newValue) {
                setState(() {
                  selectedWing = newValue;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: selectedHostel != null && selectedWing != null
                  ? () {
                      setState(() {
                        if (hostels[selectedHostel]!['floors'][selectedFloor]
                                ['wings'][selectedWing]['vacancies'] >
                            0) {
                          // Decrease total vacancies for the selected hostel
                          hostels[selectedHostel]!['totalVacancies']--;

                          // Decrease vacancies for the selected floor
                          hostels[selectedHostel]!['floors'][selectedFloor]
                              ['vacancies']--;

                          // Decrease vacancies for the selected wing
                          hostels[selectedHostel]!['floors'][selectedFloor]
                              ['wings'][selectedWing]['vacancies']--;

                          print("Update hostel data: $hostels");
                          updateHostelData(selectedHostel!, selectedWing!,
                              selectedFloor!, widget.uid);
                          Navigator.pop(context);
                        }
                      });
                    }
                  : null, // Disable button if no hostel or wing is selected,
              child: const Text("Register the hostel"),
            ),
            // Submit button
          ],
        ),
      ),
    );
  }
}
