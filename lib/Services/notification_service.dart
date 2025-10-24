import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/main.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/utils/notification_message.dart';
import 'package:match5/views/Pages/individual_loaded_chat.dart';
import 'package:match5/views/splash_screen.dart';

class NotificationService {
  //handles fcm
  static final _firebaseMessaging = FirebaseMessaging.instance;

  //handles local notifications
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //request permission
  static Future init() async {
    String? currentToken;
    var token = await Helper.getFCMToken();
    var prevToken = await Helper.getPreviousFCMToken();

    currentToken = token;
    print("token he token $currentToken");
    if (token == null || token == "") {
      try {
        currentToken = await _firebaseMessaging.getToken();
        if (currentToken != null && currentToken.isNotEmpty) {
          await Helper.saveFCMToken(currentToken);
          await Helper.savePreviousFCMToken(currentToken);
          print("tetins $currentToken");
        } else {
          debugPrint("⚠️ FCM token is null");
        }
      } catch (e, st) {
        debugPrint("❌ Failed to get FCM token: $e");
        FirebaseCrashlytics.instance
            .recordError(e, st, reason: "FCM getToken failed");
      }
    }

    if (currentToken != null && currentToken.isNotEmpty) {
      await _firebaseMessaging.subscribeToTopic("all_users");
      print("Subscribed to topic: all_users $token");
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      await Helper.saveFCMToken(newToken);
      if (currentToken != null) {
        await Helper.savePreviousFCMToken(currentToken!);
      }
      print("tetins new token $newToken");
      print("tetins old token $currentToken");
    });
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

    switch (payload["type"]) {
      case "chat":
        try {
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
                    comingFromAd: true,
                  )));
        } catch (e) {
          print("⚠️ Error parsing chat payload: $e");
        }
        break;

      case "activity":
        // 👉 Maybe navigate to your home or activity page
        print("launched from terminated in activity ${payload["type"]}");
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (builder) => SplashScreen()),
          );
        });
        break;

      default:
        print("Unhandled notification type: ${payload["type"]}");
    }
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
