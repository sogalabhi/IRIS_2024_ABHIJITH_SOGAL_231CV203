import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../utils/hostel_change_reject.dart';
import '../../utils/send_fcm.dart';
import '../../utils/getuserbyuid.dart';
import '../../widgets/build_history_card.dart';
import '../../utils/get_all_hostel_change_history.dart';
import '../../utils/get_all_hostels.dart';
import '../../utils/hostel_change_approve.dart';
import '../../widgets/build_request_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hostel Change Requests',
          style: TextStyle(color: Colors.white),
        ),
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
                      return buildRequestCard(
                        request: requests[index],
                        availableVacancies: hostelData['floors'][floorId]
                            ['wings'][wingId]['vacancies'],
                        currentHostel: userData['currentHostel']['hostelName'],
                        requestedFloor: requestData['floorNumber'],
                        requestedHostel: requestData['hostelName'],
                        requestedWing: requestData['wingName'],
                        userName: userData['name'],
                        allHostels: allHostels,
                        context: context,
                      );
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
                      return buildHistoryCard(
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
}
