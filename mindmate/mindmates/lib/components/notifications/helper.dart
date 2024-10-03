
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  // Initialize Firestore and Firebase Messaging instances
  final userr = FirebaseAuth.instance.currentUser;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Define the navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Determine the type of notification from message data
  // Assuming message.data contains a key 'type' that specifies the notification type
  String? notificationType = message.data['type'];

  String? title = message.notification?.title;
  String? body = message.notification?.body;

  if (notificationType == 'message') {
    showMessageNotification(title, body);
  } else if (notificationType == 'review') {
    showReviewNotification(title, body);
  } else if (notificationType == 'payment') {
    showRequestNotification(title, body);
  } else {
    // Fallback to a default notification if type is not specified
    _showNotification(title, body, 'Mindmate', 'Mindmate Notifications',
        'General notifications');
  }
}

// Example usage for different types of notifications:

void showMessageNotification(String? title, String? body) {
  _showNotification(title, body, 'Chats', 'Chat Notifications',
      'Notifications for messages and chats');
}

void showReviewNotification(String? title, String? body) {
  _showNotification(title, body, 'Review', 'Review Notifications',
      'Notifications for reviews');
}

void showRequestNotification(String? title, String? body) {
  _showNotification(title, body, 'Payment', 'Payment Notifications',
      'Notifications for Payments');
}

 
void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) {
  String? payload = notificationResponse.payload;
  if (payload != null) {
   
  }
}

Future<void> setupFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/minds');
  // final IOSInitializationSettings initializationSettingsIOS =
  //     IOSInitializationSettings(
  //         requestAlertPermission: true,
  //         requestBadgePermission: true,
  //         requestSoundPermission: true);
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    //  iOS: initializationSettingsIOS
  );
  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
}

void _showNotification(String? title, String? body, String channelId,
    String channelName, String channelDescription) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId, // Channel ID
    channelName, // Channel Name
    channelDescription: channelDescription, // Channel Description
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
    playSound: true, // This will use the default sound
  );
  final NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

  void initializeFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message in foreground: ${message.notification?.title}');

      String? title = message.notification?.title;
      String? body = message.notification?.body;

      // Determine the type of notification from message data
      String? notificationType = message.data['type'];

      if (notificationType == 'message') {
        showMessageNotification(title, body);
      } else if (notificationType == 'review') {
        showReviewNotification(title, body);
      } else if (notificationType == 'request') {
        showRequestNotification(title, body);
      }  else if (notificationType == 'payment') {
        showRequestNotification(title, body);
      }else {
        // Fallback to a default notification if type is not specified
        _showNotification(title, body, 'Mindmate',
            'Mindmate Notifications', 'General notifications');
      }
    });
  }


  // Utility to log errors or success messages
  void logMessage(String message) {
    print(message);
  }
}
