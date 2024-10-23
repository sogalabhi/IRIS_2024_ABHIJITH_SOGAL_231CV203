import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HostelChangePage extends StatefulWidget {
  final Map currentHostel;

  const HostelChangePage({super.key, required this.currentHostel});
  @override
  State<HostelChangePage> createState() => _HostelChangePageState();
}

class _HostelChangePageState extends State<HostelChangePage> {
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

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelDataForRequest = {
      'hostelId': hostelId,
      'hostelName': hostels[hostelId]['name'],
      'wingId': wingId,
      'wingName': hostels[hostelId]['floors'][floorId]['wings'][wingId]['name'],
      'floorId': floorId,
      'floorNumber': hostels[hostelId]['floors'][floorId]['name'],
      'userId': userId,
      'status': 'pending'
    };
    print("updatedHostelData: ${updatedHostelDataForRequest.keys}");
    try {
      CollectionReference collectionReference =
          firestore.collection('hostel_change_requests');
      await collectionReference.doc(userId).set(updatedHostelDataForRequest);
      // Update the current hostel in the user's document

      await firestore.collection('users').doc(userId).update(
        {
          'newHostel': {
            'hostelId': hostelId,
            'hostelName': updatedHostelDataForRequest['hostelName'],
            'wingId': wingId,
            'wingName': updatedHostelDataForRequest['wingName'],
            'floorId': floorId,
            'floorNumber': updatedHostelDataForRequest['floorNumber'],
            'status': 'pending'
          },
        },
      );
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
        title: const Text("Apply for Hostel Change"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Hostel: ${widget.currentHostel['currentHostel']['hostelName']}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            DropdownButton<String>(
              hint: const Text('Select Hostel'),
              value: selectedHostel,
              isExpanded: true,
              items: hostels.keys
                  .where((entry) =>
                      hostels[entry]['name'] !=
                      widget.currentHostel['currentHostel']['hostelName'])
                  .map((String hostelKey) {
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
                          // hostels[selectedHostel]!['totalVacancies']--;

                          // // Decrease vacancies for the selected floor
                          // hostels[selectedHostel]!['floors'][selectedFloor]
                          //     ['vacancies']--;

                          // // Decrease vacancies for the selected wing
                          // hostels[selectedHostel]!['floors'][selectedFloor]
                          //     ['wings'][selectedWing]['vacancies']--;

                          // // INcrease vacancies in old hostel floor wing
                          // var oldhostelid =
                          //     widget.currentHostel['currentHostel']['hostelId'];
                          // var oldfloorid =
                          //     widget.currentHostel['currentHostel']['floorId'];
                          // var oldwingid =
                          //     widget.currentHostel['currentHostel']['wingId'];

                          // hostels[oldhostelid]!['totalVacancies']++;
                          // hostels[oldhostelid]!['floors'][oldfloorid]
                          //     ['vacancies']++;
                          // hostels[oldhostelid]!['floors'][oldfloorid]['wings']
                          //     [oldwingid]['vacancies']++;

                          // print("Update hostel data: $hostels");
                          var uid = FirebaseAuth.instance.currentUser?.uid;
                          print(
                              'uid $selectedHostel $selectedWing $selectedFloor');
                          updateHostelData(selectedHostel!, selectedWing!,
                              selectedFloor!, uid!);
                          // Navigator.pop(context);
                        } else {
                          print("no vacancy");
                        }
                      });
                    }
                  : null, // Disable button if no hostel or wing is selected,
              child: const Text("Apply for Change"),
            ),
            // Submit button
          ],
        ),
      ),
    );
  }
}