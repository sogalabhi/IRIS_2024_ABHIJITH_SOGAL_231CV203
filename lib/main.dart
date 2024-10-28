import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iris_app/api/firebase_api.dart';
import 'package:iris_app/pages/admin/addhostel.dart';
import 'package:iris_app/pages/admin/allocatehostel.dart';
import 'package:iris_app/pages/admin/dashboard.dart';
import 'package:iris_app/pages/admin/hostelchangerequests.dart';
import 'package:iris_app/pages/admin/managehostels.dart';
import 'package:iris_app/pages/admin/usermanagement.dart';
import 'package:iris_app/pages/admin/usersonleave.dart';
import 'package:iris_app/pages/login.dart';
import 'package:iris_app/pages/register.dart';
import 'package:iris_app/pages/user/applyleave.dart';
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
  await FirebaseApi().initNotifications();
  await FirebaseApi().setupFlutterNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user = FirebaseAuth.instance.currentUser;
  final _router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return '/login';
      } else if (user.email == "admin@gmail.com") {
        return '/admindashboard';
      } else {
        return '/';
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/applyleave',
        builder: (context, state) => const LeaveApplicationForm(),
      ),
      GoRoute(
        path: '/hostelregister',
        builder: (context, state) => const CreateHostelPage(),
      ),
      GoRoute(
        path: '/changehostel',
        builder: (context, state) => HostelChangePage(
          currentHostel: state.extra as Map,
        ),
      ),
      //admin
      GoRoute(
        path: '/admindashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/addhostel',
        builder: (context, state) => const CreateHostelPage(),
      ),
      GoRoute(
        path: '/hostelmanagement',
        builder: (context, state) => const HostelManagementPage(),
      ),
      GoRoute(
        path: '/hostelchangelist',
        builder: (context, state) => const HostelChangeRequestsPage(),
      ),
      GoRoute(
        path: '/usermanagement',
        builder: (context, state) => const UserManagementPage(),
      ),
      GoRoute(
        path: '/leaveapplicationlist',
        builder: (context, state) => const LeaveApplicationsList(),
      ),
      GoRoute(
        path: '/allocatehostel',
        builder: (context, state) => HostelAllocationPage(
            userData: state.pathParameters,
            uid: state.pathParameters as String),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) {
    print("user: $user");
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff3b3e72)),
        useMaterial3: true,
      ),
      home: const AdminDashboardPage(),
    );
  }
}

//todo
//1. router setup
//2. hive
//3. fcm
//4. vacancy checks
//5. Rooms booking if possible