import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iris_app/pages/admin/dashboard.dart';
import 'package:iris_app/pages/admin/hostelchangerequests.dart';
import 'package:iris_app/pages/login.dart';
import 'package:iris_app/pages/user/homepage.dart';
import 'package:iris_app/pages/user/hostelchange.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  final directory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(directory.path);

// Open the box for user data
  await Hive.openBox('userBox');

//Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}