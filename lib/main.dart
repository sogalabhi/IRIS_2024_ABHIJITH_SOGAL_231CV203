import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> setupFlutterNotifications() async {
  // Android initialization settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Combine initialization settings
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // Initialize FlutterLocalNotificationsPlugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request permissions for iOS
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Listen to foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    showFlutterNotification(message);
  });
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
}

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
  await setupFlutterNotifications();
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
        // If the user is logged in and is the admin, redirect to admin dashboard
        return '/admindashboard';
      } else {
        // If the user is logged in and not the admin, redirect to home page
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
        path: '/changehostel/:currentHostel',
        builder: (context, state) => HostelChangePage(
          currentHostel: state.pathParameters['currentHostel'] as Map,
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
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

//todo
//1. router setup
//2. hive
//3. hive