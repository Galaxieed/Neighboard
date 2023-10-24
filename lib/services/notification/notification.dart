import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:neighboard/screen_direct.dart';

class MyNotification {
  String constructFCMPayload(String? token, String title, String body) {
    return jsonEncode({
      'to': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
      },
      'notification': {
        'title': title,
        'body': body,
      },
    });
  }

  Future<void> sendPushMessage(token, title, body) async {
    if (token == null) {
      if (kDebugMode) print('Unable to send FCM message, no token exists.');
      return;
    }

    if (token == myToken) {
      if (kDebugMode) print("self");
      return;
    }

    try {
      String serverKey =
          'AAAADRf6vP4:APA91bFjlIhpmGbBCmQPZ3kUHlZZoiG7Klm3lCH_wJaBa3i8Psk8AX4-40r-HWxNxsynIJsEs0Ym4uHkfdj4iWMPH2TneCQORJuMy7awzAGDbl0azJ7zIVxxXJd1_qHn_Z1E-L_kCIrY';
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'key=$serverKey'
        },
        body: constructFCMPayload(token, title, body),
      );
      if (kDebugMode) print('FCM request for device sent!');
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
