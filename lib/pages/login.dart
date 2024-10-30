import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iris_app/models/user_model.dart';
import 'package:iris_app/pages/admin/dashboard.dart';
import 'package:iris_app/pages/user/homepage.dart';
import 'package:iris_app/pages/register.dart';
import 'package:iris_app/utils/check_internet.dart';
import 'package:iris_app/utils/getuserbyuid.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String uid = "";
  void saveUserData(UserModel user) async {
    var userBox = Hive.box('userBox');
    userBox.put('user', user);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkConnectivity(context);

    void loadUserData(user) async {
      var userBox = Hive.box('userBox');
      await userBox.put(
        'user',
        UserModel(
          name: user['name'],
          email: user['email'],
          rollNumber: user['rollNumber'],
          currentHostel: user['currentHostel'],
        ),
      );
    }

    Future<void> storeUserToken(userCredential) async {
      // Get the FCM token
      final token = await FirebaseMessaging.instance.getToken();

      // Store the token in Firestore under the user's document
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid)
            .set(
          {'fcmToken': token},
          SetOptions(merge: true),
        );
        print("token updated $storeUserToken");
      }
    }

    Future<void> login() async {
      if (_formKey.currentState!.validate()) {
        try {
          // Login the user with Firebase Auth
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          storeUserToken(userCredential);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logined successfully!')),
          );

          var user = await getUserDetails(userCredential.user!.uid);
          print('user $user');
          loadUserData(user);
          if (_emailController.text.trim() == "admin@gmail.com") {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminDashboardPage()));
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            });
          }

          // Clear the fields
          _emailController.clear();
          _passwordController.clear();
        } catch (e) {
          // Handle registration error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.network("https://cdn.iris.nitk.ac.in/iris%20logo2.png"),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: login,
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
                  },
                  child: const Text('Go to register page'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
