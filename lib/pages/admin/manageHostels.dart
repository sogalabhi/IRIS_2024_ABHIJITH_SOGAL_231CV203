import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iris_app/pages/admin/addhostel.dart';

class HostelManagementPage extends StatefulWidget {
  const HostelManagementPage({super.key});

  @override
  State<HostelManagementPage> createState() => _HostelManagementPageState();
}

class _HostelManagementPageState extends State<HostelManagementPage> {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch hostel data from Firestore
  Stream<QuerySnapshot> getHostels() {
    return _firestore.collection('hostels').snapshots();
  }

  // Function to delete a hostel
  Future<void> deleteHostel(String docId) async {
    try {
      await _firestore.collection('hostels').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hostel deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting hostel: $e')),
      );
    }
  }

  // Function to navigate to the edit page
  void editHostel(Map<String, dynamic> hostelData, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateHostelPage(hostelData: hostelData, docID: docId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel List',
          style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateHostelPage()));
          },
          child: const Icon(
            Icons.add_box_sharp,
            size: 60,
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: getHostels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hostels found.'));
          }

          // Building the list of hostel cards
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> hostelData =
                  document.data() as Map<String, dynamic>;
              String hostelId = document.id;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hostelData['name'] ?? 'Hostel Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Total Vacancies: ${hostelData['totalVacancies']}"),
                      const SizedBox(height: 10),
                      const Text("Floors:"),
                      ..._buildFloorsList(hostelData['floors']),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xff3b3e72)),
                            onPressed: () => editHostel(hostelData, hostelId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteHostel(hostelId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Helper function to build the list of floors and wings
  List<Widget> _buildFloorsList(Map<String, dynamic> floors) {
    List<Widget> floorsList = [];
    floors.forEach((floorNumber, floorData) {
      floorsList.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(floorData['name'] ?? floorNumber),
            ..._buildWingsList(floorData['wings']),
          ],
        ),
      );
    });
    return floorsList;
  }

  // Helper function to build the list of wings for a floor
  List<Widget> _buildWingsList(Map<String, dynamic> wings) {
    List<Widget> wingsList = [];
    wings.forEach((wingName, wingData) {
      wingsList.add(Text(
          "${wingData['name'] ?? wingName} - Vacancies: ${wingData['vacancies']}"));
    });
    return wingsList;
  }
}
