import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/main.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/utils/notification_message.dart';
import 'package:match5/views/Pages/individual_loaded_chat.dart';

class NotificationService {
  //handles fcm
  static final _firebaseMessaging = FirebaseMessaging.instance;

  //handles local notifications
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //request permission
  static Future init() async {
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

  static Future askForPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );
  }

  //initialize local notifications
  static Future localInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_m5_clean');

//for ios
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    //request notification permission
    // _flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()!
    //     .requestNotificationsPermission();

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  //on tap local notification in foreground
  static void onNotificationTap(NotificationResponse notificationResponse) {
    print(
        "notification repose hee check kro bs nr.payload chlta hai usko pele jsonDecode kro ");
    print(notificationResponse);
    var payload = jsonDecode(notificationResponse.payload!);
    print(payload);
    var tokens = List<String>.from(jsonDecode(payload["tokens"]));
    navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (builder) => IndividualLoadedChat(
              //here for otheruserid i send my id cause for other user this is otherUserid
              username: payload["username"],
              OtherUserId: payload["otherUserId"],
              myId: payload["myId"],
              profilePic: payload["profilePic"],
              isBot: payload["isBot"],
              token: tokens,
              isItcomingFromMessagePage: false,
            )));
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

  static void handleNotificationTapped(RemoteMessage message, UserModel user) {
    // if (message.notification != null) {
    //   print("bg noti tapped");
    //   navigatorKey.currentState!.push(MaterialPageRoute(
    //       builder: (builder) => MessagesPage(myUsername: )));
    // }
  }
}
