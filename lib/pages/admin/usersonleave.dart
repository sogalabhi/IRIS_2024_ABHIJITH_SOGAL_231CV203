import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaveApplicationsList extends StatelessWidget {
  const LeaveApplicationsList({super.key});

  // This function returns a stream of snapshots from Firestore
  Stream<QuerySnapshot> _getLeaveApplicationsStream() {
    return FirebaseFirestore.instance
        .collection('leave_applications')
        .snapshots();
  }

  // Fetch user details by UID from users collection
  Future<Map<String, dynamic>?> _getUserDetails(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      print("Error fetching user details: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Applications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getLeaveApplicationsStream(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If there are no applications
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Leave Applications Found'));
          }

          // If data is available, display in a ListView
          final List<DocumentSnapshot> leaveApplications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaveApplications.length,
            itemBuilder: (context, index) {
              // Extract data from the Firestore document
              final Map<String, dynamic> applicationData =
                  leaveApplications[index].data() as Map<String, dynamic>;
              // Get the UID from leave application
              final String uid = applicationData['uid'] ?? '';
              // Display data in a Card widget
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserDetails(uid),
                builder: (context, userSnapshot) {
                  // Handle loading state for user details
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Handle user fetching errors
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data == null) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            Text('Error fetching user details for UID: $uid'),
                      ),
                    );
                  }

                  // User data fetched successfully
                  final Map<String, dynamic> userData = userSnapshot.data!;
                  final String userName = userData['name'] ?? 'Unknown User';
                  final String rollNumber = userData['rollNumber'] ?? 'Unknown rollNumber';
                  final String hostelName =
                      userData['currentHostel']['hostelName'] ?? 'Unknown Hostel';

                  // Display leave application data along with user details in a Card
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Name: $userName",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Roll Number: $rollNumber",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Hostel: $hostelName",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "From: ${applicationData['fromDate'] ?? 'N/A'}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "To: ${applicationData['toDate'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Message: ${applicationData['message'] ?? 'No message provided'}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
