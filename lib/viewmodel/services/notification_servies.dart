import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For kIsWeb

class FirebaseNotification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> updateFcmToken() async {
    try {
      await _messaging.requestPermission();
      // Fetch the FCM token
      String? fcmToken = await _messaging.getToken();

      if (fcmToken != null && _auth.currentUser != null) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'fcmToken': fcmToken,
        });

        log('FCM token updated successfully: $fcmToken');
      } else {
        log('Failed to retrieve FCM token or user is not logged in.');
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }

  void initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create the notification channel for Android 8.0 and higher
    _createNotificationChannel();
  }

  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      description:
          'This channel is used for important notifications.', // Channel Description
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void listenForNotifications() {
    String currentUserId = _auth.currentUser?.uid ?? '';

    if (currentUserId.isNotEmpty) {
      _firestore
          .collection('notifications')
          .doc(currentUserId)
          .collection('userNotifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((querySnapshot) {
        for (var change in querySnapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            // New document added, show notification
            var notificationData = change.doc.data() as Map<String, dynamic>;
            _showLocalNotification(notificationData);
          }
        }
      });
    } else {
      log("User is not signed in, cannot listen for notifications.");
    }
  }

  // Show a local notification
  void _showLocalNotification(Map<String, dynamic> notificationData) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Use the same channel ID created in _createNotificationChannel
      'High Importance Notifications', // Channel name
      channelDescription:
          'This channel is used for important notifications.', // Channel description
      importance: Importance.high,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0,
      notificationData['username'] ?? 'New Activity',
      notificationData['type'] == 'like'
          ? '${notificationData['username']} liked your post.'
          : '${notificationData['username']} commented on your post.',
      platformChannelSpecifics,
    );
  }
}
