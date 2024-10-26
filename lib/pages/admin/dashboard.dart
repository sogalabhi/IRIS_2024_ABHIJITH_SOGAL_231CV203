import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iris_app/pages/admin/hostelchangerequests.dart';
import 'package:iris_app/pages/admin/managehostels.dart';
import 'package:iris_app/pages/admin/usermanagement.dart';
import 'package:iris_app/pages/admin/usersonleave.dart';
import 'package:iris_app/pages/login.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int? users = 0, hostels = 0, leaveApplications = 0, hostelrequests = 0;
  void getDocumentCount() async {
    // Get the collection reference
    QuerySnapshot snapshot1 =
        await FirebaseFirestore.instance.collection('users').get();
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
  void initState() {
    super.initState();
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
      ),
      body: Padding(
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
                  buildOverviewCard("Total Hostels", '$hostels', Icons.home),
                  buildOverviewCard(
                      "Total hostellites", '$users', Icons.location_city),
                  buildOverviewCard("Leave applications", '$leaveApplications',
                      Icons.event_seat),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Notifications section
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.notification_important,
                    color: Colors.orange),
                title: const Text("Pending Hostel Change Requests"),
                subtitle: Text("$hostelrequests requests awaiting approval"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HostelChangeRequestsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Quick Links section
            const Text(
              "Quick Links",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildQuickLinkButton("Manage Hostels", Icons.manage_accounts,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostelManagementPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Users on Leave", Icons.person_off, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaveApplicationsList(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Process Requests", Icons.assignment,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostelChangeRequestsPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Manage Users", Icons.assignment, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Current Hostel Status
            const Text(
              "Current Hostel Status",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.deepPurple[50],
              child: const ListTile(
                leading: Icon(Icons.info, color: Color(0xff3b3e72)),
                title: Text("Vacancies: 42 / Total Capacity: 60"),
                subtitle: Text("Hostel 1 - Wing A, Wing B, Wing C"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build overview cards
  Widget buildOverviewCard(String title, String count, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xff3b3e72)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build quick link buttons
  Widget buildQuickLinkButton(String title, IconData icon, Function onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 80),
      ),
      onPressed: () {
        onPressed();
      },
      icon: Icon(icon, size: 30),
      label: Text(
        title,
        textAlign: TextAlign.center,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AdminDashboardPage(),
  ));
}
