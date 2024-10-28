import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:iris_app/utils/send_fcm.dart';
import 'package:iris_app/pages/admin/allocatehostel.dart';
import 'package:iris_app/utils/getuserbyuid.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: 'admin@gmail.com')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUsers(),
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
            return const Center(child: Text('No Users Found'));
          }

          // If data is available, display in a ListView
          final List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              // Extract data from the Firestore document
              final Map<String, dynamic> userData =
                  users[index].data() as Map<String, dynamic>;
              String uid = users[index].id;
              return userCard(userData, context, uid);
            },
          );
        },
      ),
    );
  }

  Widget userCard(Map user, BuildContext context, String uid) {
    Future<void> deallocate() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).update({
        'currentHostel': {
          'floorId': '',
          'floorNumber': '',
          'hostelId': '',
          'hostelName': '',
          'wingId': '',
          'wingName': ''
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deallocated successfully!')),
      );
      var user = await getUserDetails(uid);
      String fcmToken = await getTokenByEmail(user?['email']);
      //Send notification
      await sendNotificationV1(
        title: "Update on hostel status",
        body: "Admin has deallocated your hostel",
        deviceToken: fcmToken,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User details
            Text('Name: ${user['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${user['email']}'),
            Text('Roll No: ${user['rollNumber']}'),
            if (user['currentHostel'] != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hostel: ${user['currentHostel']['hostelName']}'),
                  Text('Floor: ${user['currentHostel']['floorNumber']}'),
                  Text('Wing: ${user['currentHostel']['wingName']}'),
                ],
              ),

            const SizedBox(height: 8),

            // Leave Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (user['currentHostel']['hostelName'] != '')
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HostelAllocationPage(
                                      userData: user, uid: uid)));
                        },
                        child: const Text('Reallocate'),
                      ),
                    if (user['currentHostel']['hostelName'] == '')
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HostelAllocationPage(
                                      userData: user, uid: uid)));
                        },
                        child: const Text('Allocate'),
                      ),
                    if (user['currentHostel']['hostelName'] != '')
                      GestureDetector(
                        onDoubleTap: () {
                          deallocate();
                        },
                        child: const Text('Double tap to deallocate'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
