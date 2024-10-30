import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

Future<bool> checkConnectivity(BuildContext context) async {
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(Duration(seconds: 5)); // Set a timeout to avoid long waits
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print("Internet access available");
      return true;
    }
  } on SocketException catch (_) {
    print("No internet access (SocketException)");
  } on TimeoutException catch (_) {
    print("No internet access (TimeoutException)");
  }
  return false;
}
