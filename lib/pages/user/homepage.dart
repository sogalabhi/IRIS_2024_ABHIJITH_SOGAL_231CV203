import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:iris_app/models/user_model.dart';
import 'package:iris_app/pages/login.dart';
import 'package:iris_app/pages/user/applyleave.dart';
import 'package:lottie/lottie.dart';

import 'hostelchange.dart';
import 'hostelregisteration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  String email = "";
  String rollNumber = "";
  String hostel = ""; // Empty or null if no hostel registration yet
  Map<dynamic, dynamic>? userData;
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (documentSnapshot.exists) {
        setState(() {
          userData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void loadUserData() async {
    var userBox = Hive.box('userBox');
    UserModel? user = await userBox.get('user');
    if (user != null) {
      // Display or use user information
      print(user.name);
    }
  }

  void _signout() async {
    await FirebaseAuth.instance.signOut();Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    getData();
    if (userData == null) {
      return Scaffold(
          body: Center(
        child: Lottie.asset('assets/lottie/loadinglottie.json'),
      )); // Show loading indicator while fetching data
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Name
              _buildInfoTile("Name", userData?['name']),
              const SizedBox(height: 10),

              // Email
              _buildInfoTile("Email", userData?['email']),
              const SizedBox(height: 10),

              // Roll Number
              _buildInfoTile("Roll Number", userData?['rollNumber']),
              const SizedBox(height: 10),

              // Hostel Info
              if (userData?['currentHostel']['hostelName'].isNotEmpty)
                _buildInfoTile(
                    "Hostel", userData?['currentHostel']['hostelName']),

              const SizedBox(height: 10),
              if (userData?['currentHostel']['wingName'].isNotEmpty)
                _buildInfoTile("Wing", userData?['currentHostel']['wingName']),

              const SizedBox(height: 10),
              if (userData?['currentHostel']['floorNumber'].isNotEmpty)
                _buildInfoTile(
                    "Floor", userData?['currentHostel']['floorNumber']),

              if (userData?['currentHostel']['hostelName'].isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "No hostel registered yet.",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Button to Register or Apply for Hostel Change
              if (userData?['newHostel'] == null)
                ElevatedButton(
                  onPressed: () async {
                    if (userData?['currentHostel']['hostelName'].isEmpty) {
                      // Navigate to the registration page
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const HostelRegistrationPage()));
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HostelChangePage(currentHostel: userData!),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(userData?['currentHostel']['hostelName'].isEmpty
                      ? "Register for Hostel"
                      : "Apply for Hostel Change"),
                ),

              if (userData?['newHostel'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Hostel change status: ${userData?['newHostel']['status'] as String}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    // Hostel Info
                    if (userData?['newHostel']['hostelName'].isNotEmpty)
                      _buildInfoTile(
                          "Hostel", userData?['newHostel']['hostelName']),

                    const SizedBox(height: 10),
                    if (userData?['newHostel']['wingName'].isNotEmpty)
                      _buildInfoTile(
                          "Wing", userData?['newHostel']['wingName']),

                    const SizedBox(height: 10),
                    if (userData?['newHostel']['floorNumber'].isNotEmpty)
                      _buildInfoTile(
                          "Floor", userData?['newHostel']['floorNumber']),
                  ],
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const LeaveApplicationForm()));
                },
                child: const Text('Apply for leave'),
              ),
              ElevatedButton(
                onPressed: _signout,
                child: const Text('Log Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            data,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
