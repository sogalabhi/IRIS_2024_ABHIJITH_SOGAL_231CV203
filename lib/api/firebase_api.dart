import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Combine initialization settings
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // Initialize FlutterLocalNotificationsPlugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final fCMToken = await _firebaseMessaging.getToken();

    String constructFCMPayload(String? token) {
      return jsonEncode({
        'token': token,
        'data': {
          'via': 'FlutterFire Cloud Messaging!!!',
        },
        'notification': {
          'title': 'Hello FlutterFire!',
          'body': 'This notification was created via FCM!',
        },
      });
    }

    Future<void> sendPushMessage() async {
      if (fCMToken == null) {
        print('Unable to send FCM message, no token exists.');
        return;
      }

      try {
        await http.post(
          Uri.parse('https://api.rnfirebase.io/messaging/send'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: constructFCMPayload(fCMToken),
        );
        print('FCM request for device sent!');
      } catch (e) {
        print(e);
      }
    }

    sendPushMessage();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Received message while in foreground: ${message.notification?.title}');
    });
    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.notification?.title}');
      // Navigate to a specific screen or perform an action
    });
  }

  sendNotificaton() {}
}
