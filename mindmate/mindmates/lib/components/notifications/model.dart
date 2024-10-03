import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class NotifModel extends StatelessWidget {
  const NotifModel({super.key});

  final String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/mindmates-d4849/messages:send';


  Future<String> getAccessToken(server) async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = server;
     
    List<String> scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final auth.ServiceAccountCredentials credentials =
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson);

    final auth.AuthClient client =
        await auth.clientViaServiceAccount(credentials, scopes);

    final auth.AccessCredentials accessCredentials = await auth
        .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client);

    client.close();

    return accessCredentials.accessToken.data;
  }

  Future<void> sendFCMMessage(token, msg, server, name) async {
    final String serverKey =
        await getAccessToken(server); // Your FCM server key
   
    // final  currentFCMToken = await FirebaseMessaging.instance.getToken();
    // print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {'body': msg, 'title': '$name'},
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          "title": "Message from $name",
          "body": msg,
          'type': 'message',  // Add this line
        },
        "android": {
          "notification": {
            "channel_id": "Chats",
            }
        }
      },
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print(
          'Failed to send FCM message: ${response.statusCode} ${response.body}');
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.headers.isNotEmpty) {
        print('Response headers:');
        response.headers.forEach((key, value) {
          print('$key: $value');
        });
      }
    }
  }


    Future<void> sendFCMMessageVideo(token, msg, server, name) async {
    final String serverKey =
        await getAccessToken(server); // Your FCM server key
   
    // final  currentFCMToken = await FirebaseMessaging.instance.getToken();
    // print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {'body': msg, 'title': 'Video call'},
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          "title": "Video Call",
          "body": msg,
          'type': 'request',  // Add this line
        },
        "android": {
          "notification": {
            "channel_id": "Video",
            }
        }
      },
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print(
          'Failed to send FCM message: ${response.statusCode} ${response.body}');
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.headers.isNotEmpty) {
        print('Response headers:');
        response.headers.forEach((key, value) {
          print('$key: $value');
        });
      }
    }
  }

  Future<void> sendFCMMessageReview(token, msg, server, name) async {
    final String serverKey =
        await getAccessToken(server); // Your FCM server key
 
    // final  currentFCMToken = await FirebaseMessaging.instance.getToken();
    // print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {'body': msg, 'title': 'Professional Review'},
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          "title": "Professional Review",
          "body": msg,
          'type': 'review',  // Add this line
        },
        "android": {
          "notification": {
            "channel_id": "Review",
            }
        }
      },
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print(
          'Failed to send FCM message: ${response.statusCode} ${response.body}');
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.headers.isNotEmpty) {
        print('Response headers:');
        response.headers.forEach((key, value) {
          print('$key: $value');
        });
      }
    }
  }

   Future<void> sendFCMMessagePayment(token, msg, server, name) async {
    final String serverKey =
        await getAccessToken(server); // Your FCM server key
   
    // final  currentFCMToken = await FirebaseMessaging.instance.getToken();
    // print("fcmkey : $currentFCMToken");
    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {'body': msg, 'title': 'Payment Via Till'},
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          "title": "Payment",
          "body": msg,
          'type': 'payment',  // Add this line
        },
        "android": {
          "notification": {
            "channel_id": "Payment",
            }
        }
      },
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print(
          'Failed to send FCM message: ${response.statusCode} ${response.body}');
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.headers.isNotEmpty) {
        print('Response headers:');
        response.headers.forEach((key, value) {
          print('$key: $value');
        });
      }
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
