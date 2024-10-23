import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateHostelPage extends StatefulWidget {
  final Map<String, dynamic>? hostelData;
  final String? docID;
  final String? hostelId;

  const CreateHostelPage({super.key, this.hostelData, this.hostelId, this.docID});

  @override
  State<CreateHostelPage> createState() => _CreateHostelPageState();
}

class _CreateHostelPageState extends State<CreateHostelPage> {
  Map<String, dynamic> hostel = {'name': '', 'totalVacancies': 0, 'floors': {}};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void addHostel(Map<String, dynamic> hostelData) {
    CollectionReference hostelDoc =
        _firestore.collection('hostels');
        hostelDoc.add(hostelData);

    print(hostelData);
  }

  Future<void> updateHostel(
      String hostelId, Map<String, dynamic> hostelData) async {
    try {
      print(hostelId);
      // Reference to the specific hostel document
      DocumentReference hostelDoc =
          _firestore.collection('hostels').doc(hostelId);

      // Update the hostel document with new data
      await hostelDoc.update(hostelData);

      print('Hostel updated successfully');
    } catch (e) {
      print('Error updating hostel: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // If hostelData is provided, populate the form with existing data
    if (widget.hostelData != null) {
      hostel = widget.hostelData!;
    }
  }

  void addFloor() {
    setState(() {
      int floorNumber = hostel['floors'].length + 1;
      hostel['floors']['floor$floorNumber'] = {
        'name': 'Floor $floorNumber',
        'vacancies': 0,
        'wings': {}
      };
    });
  }

  void addWing(String floorKey) {
    setState(() {
      Map floor = hostel['floors'][floorKey];
      int wingNumber = floor['wings'].length + 1;
      floor['wings']
          ['wing$wingNumber'] = {'name': 'Wing $wingNumber', 'vacancies': 0};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostelData != null ? "Edit Hostel" : "Add Hostel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hostel Name Input
            TextFormField(
              initialValue: hostel['name'],
              decoration: const InputDecoration(labelText: 'Hostel Name'),
              onChanged: (value) {
                setState(() {
                  hostel['name'] = value;
                });
              },
            ),

            // Total Vacancies Input
            Text('Total Vacancies: ${hostel['totalVacancies'].toString()}'),

            // Dynamic Floors and Wings
            Expanded(
              child: ListView(
                children: hostel['floors'].keys.map<Widget>((floorKey) {
                  Map floor = hostel['floors'][floorKey];
                  return ExpansionTile(
                    title: Text(floor['name']),
                    subtitle: Text("Vacancies: ${floor['vacancies']}"),
                    children: [
                      // Dynamic Wings
                      Column(
                        children: floor['wings'].keys.map<Widget>((wingKey) {
                          Map wing = floor['wings'][wingKey];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Wing Name
                                Text(wing['name'],
                                    style: const TextStyle(fontSize: 16)),
                                // Wing Vacancies with Expanded
                                Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Expanded(
                                    child: SizedBox(
                                      width:
                                          100, // Fixed width for the TextFormField
                                      child: TextFormField(
                                        initialValue:
                                            wing['vacancies'].toString(),
                                        decoration: const InputDecoration(),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {
                                            print(hostel['totalVacancies']);
                                            hostel['totalVacancies'] =
                                                hostel['totalVacancies'] -
                                                        wing['vacancies'] +
                                                        int.tryParse(value) ??
                                                    0;
                                            print(hostel['totalVacancies']);
                                            floor['vacancies'] =
                                                floor['vacancies'] -
                                                        wing['vacancies'] +
                                                        int.tryParse(value) ??
                                                    0;
                                            wing['vacancies'] =
                                                int.tryParse(value) ?? 0;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      // Add Wing Button
                      ElevatedButton(
                        onPressed: () => addWing(floorKey),
                        child: const Text('Add Wing'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),

            // Add Floor Button
            ElevatedButton(
              onPressed: addFloor,
              child: const Text('Add Floor'),
            ),

            // Save Button
            ElevatedButton(
              onPressed: () {
                if (widget.docID != null) {
                  updateHostel(widget.docID!, hostel);
                } else {
                  addHostel(hostel);
                }
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
