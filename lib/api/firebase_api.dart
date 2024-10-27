import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("title: ${message.notification?.title}");
  print("body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
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

    print('Token $fCMToken');
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
    
    sendPushMessage();
  }
}
