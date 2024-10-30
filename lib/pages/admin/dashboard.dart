import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iris_app/models/user_model.dart';
import 'package:iris_app/pages/admin/hostelchangerequests.dart';
import 'package:iris_app/pages/admin/managehostels.dart';
import 'package:iris_app/pages/admin/usermanagement.dart';
import 'package:iris_app/pages/admin/usersonleave.dart';
import 'package:iris_app/pages/login.dart';
import 'package:iris_app/utils/getuserbyuid.dart';
import 'package:iris_app/utils/getuserfromhive.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int? users = 0, hostels = 0, leaveApplications = 0, hostelrequests = 0;
  void getDocumentCount() async {
    // Get the collection reference
    QuerySnapshot snapshot1 = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isNotEqualTo: 'admin@gmail.com')
        .get();
    QuerySnapshot snapshot2 =
        await FirebaseFirestore.instance.collection('hostels').get();
    QuerySnapshot snapshot3 =
        await FirebaseFirestore.instance.collection('leave_applications').get();
    QuerySnapshot snapshot4 = await FirebaseFirestore.instance
        .collection('hostel_change_requests')
        .where('status', isEqualTo: 'pending')
        .get();
    setState(() {
      users = snapshot1.docs.length;
      hostels = snapshot2.docs.length;
      leaveApplications = snapshot3.docs.length;
      hostelrequests = snapshot4.docs.length;
    });
  }


  @override
  Widget build(BuildContext context) {
    getDocumentCount();
    
    void signout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: signout,
            child: const Icon(Icons.logout),
          ),
        ],
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview section
              const Text(
                "Overview",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildOverviewCard("Total Hostels", '$hostels', Icons.home,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const HostelManagementPage()));
                    }),
                    buildOverviewCard(
                        "Total hostellites", '$users', Icons.location_city, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UserManagementPage()));
                    }),
                    buildOverviewCard("Leave applications",
                        '$leaveApplications', Icons.event_seat, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LeaveApplicationsList()));
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (hostelrequests != 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifications",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.orange[50],
                      child: ListTile(
                        leading: const Icon(Icons.notification_important,
                            color: Colors.orange),
                        title: const Text("Pending Hostel Change Requests"),
                        subtitle:
                            Text("$hostelrequests requests awaiting approval"),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const HostelChangeRequestsPage()));
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Quick Links section
              const Text(
                "Quick Links",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildQuickLinkButton(
                          "Manage Hostels", Icons.manage_accounts, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const HostelManagementPage()));
                      }),
                      const SizedBox(width: 10),
                      buildQuickLinkButton("Users on Leave", Icons.person_off,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LeaveApplicationsList()));
                      }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      buildQuickLinkButton("Process Requests", Icons.assignment,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LeaveApplicationsList()));
                      }),
                      const SizedBox(width: 10),
                      buildQuickLinkButton("Manage Users", Icons.assignment,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserManagementPage()));
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build overview cards
  Widget buildOverviewCard(
      String title, String count, IconData icon, Function onPressed) {
    return Card(
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color(0xff3b3e72)),
              const SizedBox(height: 8),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build quick link buttons
  Widget buildQuickLinkButton(String title, IconData icon, Function onPressed) {
    return Expanded(
      child: Card(
        child: Container(
          height: 100,
          color: Colors.white24,
          child: TextButton.icon(
            onPressed: () {
              onPressed();
            },
            icon: Icon(icon, size: 30, color: const Color(0xff3b3e72)),
            label: Text(
              title,
              style: const TextStyle(color: Color(0xff3b3e72)),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}
