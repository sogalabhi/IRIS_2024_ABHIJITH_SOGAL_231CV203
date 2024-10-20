import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HostelChangePage extends StatefulWidget {
  final String currentHostel;

  const HostelChangePage({super.key, required this.currentHostel});
  @override
  State<HostelChangePage> createState() => _HostelChangePageState();
}

class _HostelChangePageState extends State<HostelChangePage> {
  String? selectedHostel;
  String? selectedWing;
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
      String hostelId, String wingId, String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelData = hostels[hostelId]!;

    try {
      // Update the hostel document in Firestore
      await firestore.collection('hostels').doc(hostelId).update({
        'totalVacancies': updatedHostelData['totalVacancies'],
        'wings': updatedHostelData['wings']
      });

      // Update the current hostel in the user's document
      await firestore.collection('users').doc(userId).update({
        'currentHostel': {
          'hostelId': hostelId,
          'hostelName': updatedHostelData['name'],
          'wingId': wingId,
          'wingName': updatedHostelData['wings'][wingId]['name'],
        },
      });
      var userBox = await Hive.openBox('userBox');
      await userBox.put('currentHostel', {
        'currentHostel': {
          'hostelId': hostelId,
          'hostelName': updatedHostelData['name'],
          'wingId': wingId,
          'wingName': updatedHostelData['wings'][wingId]['name'],
        },
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
  }

  String? _newHostel;
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
              "Current Hostel: ${widget.currentHostel}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            DropdownButton<String>(
              hint: const Text('Select Hostel'),
              value: selectedHostel,
              isExpanded: true,
              items: hostels.keys
                  .where(
                      (entry) => hostels[entry]['name'] != widget.currentHostel)
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
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text('Select Wing'),
              value: selectedWing,
              isExpanded: true,
              items: selectedHostel != null
                  ? (hostels[selectedHostel]!['wings'] as Map<String, dynamic>)
                      .keys
                      .map((String wingKey) {
                      return DropdownMenuItem<String>(
                        value: wingKey,
                        child: Text(
                            hostels[selectedHostel]!['wings'][wingKey]['name']),
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
                        if (hostels[selectedHostel]!['totalVacancies'] > 0 &&
                            hostels[selectedHostel]!['wings']
                                    [selectedWing]!['vacancies'] >
                                0) {
                          // Decrease total vacancies for the selected hostel
                          hostels[selectedHostel]!['totalVacancies']--;

                          // Decrease vacancies for the selected wing
                          hostels[selectedHostel]!['wings']
                              [selectedWing]!['vacancies']--;
                          var uid = FirebaseAuth.instance.currentUser?.uid;
                          print(uid);
                          updateHostelData(
                              selectedHostel!, selectedWing!, uid!);
                          Navigator.pop(
                              context, {'hostel': hostels[selectedHostel]!['name'], 'wing': hostels[selectedHostel]!['wings'][selectedWing]['name']});
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
