import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<void> sendNotificationV1({
  required String deviceToken,
  required String title,
  required String body,
}) async {
  const projectId = 'iris-app-2024'; // Replace with your Firebase project ID

  // Load the service account credentials
  final serviceAccount = {
    "type": "service_account",
    "project_id": "iris-app-2024",
    "private_key_id": "67476477adebbd773eaa2b3352162dede6d01034",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCex/VbB/yp48fn\nS5xKYDbKEKYI+MwFXASCNdw7bBg5m06FMpOvcmpUhiE4Cd75C8YX5xUSEae7mc9T\nPDRxDho9oUlQUd3R1TZwpeDzE9PSyoyQgmhkmB4W4hZVtFfc0+r4wCldalE6SAW2\naH4vejfWrmQYyODqAGPFSul1zwK+rCPGGSHAMSO7L0U89t3npHg4ZhQxyi29ADwj\nFK3UOZigKUHvO4dhLrypeSjLF2lTAjNCDx7B9e7e/cXuIF71R3wOzvHKneHgBGjc\nAlFA0vlkx043g0LEdP4i079oIlnDLCIMoWtU4ol1ytMa1LIOR7afheTLmuw4bLuU\n3XfJJIh5AgMBAAECggEAIZY8oVfsK2fCdnu5AMafcFjbNlSim5OeZIjOIEe6TB09\nG9HaCafTNDP3POphnx7NdWrtOxg++eEMSRgYI74O8PB4GKRonqVSUbvU/LY5/YHZ\nAAyF1pmS69ZBUTnHyC+PqbTESz1dF0363131K0fYHfJfvBpp8TXJ5Qb2oXP7qadc\nwC+L3Lhb2i88TQGd9Glt94BNwU1NCuxbJp8bK+zDquAkv5rHvIqHJKhDJrG+x7QU\nLBd6JpspUMNBA8ecyH4mxuT+lUSvFlz1vygvbvOhQAEDbLfPNmOw2Zw8xxhVH2qy\n6HuXOxAdngUpG4OBpyZXku615juC2+zpAlk6AwstrQKBgQDR+H7oYIjElSbQB6qu\nshdVzqfSTpDnqIWcQgskT6tOG+YFK02CWNxhakOVBPQPdBa1EQ0Evdhd+Lj5/Rux\nwjkQbJqVW/JV29mCdT4WaeooQjxUfuJqevdPRHCmH5A7OCbTDyZMuldqNuouP1d+\nTLtRQ+h5o/brR2MXqkjk/pP+VwKBgQDBlrb5twlm8ygLgH6PwEhNlr2pZi/B1nrY\nQehIcQm6aU4e+9FfN3Fw9cLGaOJzh+Pn0PPN2+iIKpDFiHMmmIMWGKcCoBAXDJGl\nKEu+dzJiKJOXZHj1bGTvA/bzxaROAaJEYxeqKSvzt76Nd2h/jHBn620YVYDvKzYN\nob6T7mLNrwKBgBMuc1GBOB1VTtVkTehlppIVLemdeclf8MzEj8YCbTDWhZ3lRdBp\nk8Bmd8QOTsl2nnhuFVVgjnqPNT7JK5WCm7nvYfPREYNccTNkyIY9qMGCw4YojUCS\n+TLJmsziR0fRqmJPmP0bbM7sM1qEONb15YrX/E3Yd78op1nLGZup0hVDAoGAQIiU\ncIQyzy3pwIPSLOuFbs/8Y7cb3ns4MlUuMM/11T17fFqnvh0GZQiYKHoYWzkGoWWH\nkK1pQ9MktaS59jjLIhePvRFMq9JVzv+y2Eh19EDgioxEwlOjBgaFUVgmYJas2C1M\nWz4kV7d9/zy6CiLv6cSSdpUySQhXmY28sSW7rCMCgYBlVQF7tO0fW0GewBA9nnOh\nVuSsDjFDUdRt3Kq3I1FBpfaaUKILWLE+tfSl2rZR3aFIUEFrO07opOPn8jTtuK8M\n6UBWJX0i4A2oKahISKeAkJ3CClDXTM175HVJTVCQSSTVTp4hxXIOXwtgO15cNVh9\n4/t8eps7EL0XL5fkqU2WHw==\n-----END PRIVATE KEY-----\n",
    "client_email": "iris-app-2024@appspot.gserviceaccount.com",
    "client_id": "109232229229299844218",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/iris-app-2024%40appspot.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };
  final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Get authenticated client
  final client = await clientViaServiceAccount(accountCredentials, scopes);

  try {
    const url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final response = await client.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': {
          'token': deviceToken,
          'notification': {
            'title': title,
            'body': body,
          },
        }
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully via FCM HTTP v1');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  } finally {
    client.close();
  }
}

Future<String> getTokenByEmail(String email) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final fcmToken = querySnapshot.docs.first.data()['fcmToken'];
      print('fcmToken: $fcmToken');
      return fcmToken;
    } else {
      print('No user found with the given email.');
    }
  } catch (e) {
    print('Error fetching name: $e');
  }
  return '';
}

