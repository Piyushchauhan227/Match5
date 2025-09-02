import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:match5/main.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/utils/notification_message.dart';

class NotificationService {
  //handles fcm
  static final _firebaseMessaging = FirebaseMessaging.instance;

  //handles local notifications
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //request permission
  static Future init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    final currentToken = await _firebaseMessaging.getToken();
    print("Token is $currentToken");

    final token = await Helper.getFCMToken();

    await _firebaseMessaging.subscribeToTopic("all_users");
    print("Subscribed to topic: all_users $token");

    if (token == null) {
      print("in null");
      await Helper.saveFCMToken(currentToken!);
      var pt = await Helper.getFCMToken();
      print("purja hai $pt");
      await Helper.savePreviousFCMToken(currentToken);
    } else if (token != currentToken) {
      await Helper.saveFCMToken(currentToken!);
      await Helper.savePreviousFCMToken(token);
    }
  }

  //initialize local notifications
  static Future localInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

//for ios
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    //request notification permission
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  //on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (builder) => NotificationMessage(
            message: "", localNotificationResponse: notificationResponse)));
  }

  //shwo a simple notification
  static Future showSimpleNotification(
      {required String title,
      required String body,
      required String payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails("your channel ID", "your channel name",
            channelDescription: "your channel Description",
            importance: Importance.max,
            priority: Priority.high,
            ticker: "ticker");

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _flutterLocalNotificationsPlugin
        .show(0, title, body, notificationDetails, payload: payload);
  }
}
