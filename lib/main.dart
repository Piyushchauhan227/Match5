import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Provider/message_list_provider.dart';
import 'package:match5/Provider/notification_provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/connectivity_service.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/firebase_options.dart';
import 'package:match5/utils/notification_message.dart';
import 'package:match5/views/Pages/individual_chat_page.dart';
import 'package:match5/views/Pages/navbar/messages_page.dart';
import 'package:match5/views/Pages/no_internet_screen.dart';
import 'package:match5/views/onBoardScreens/first_questionaire.dart';
import 'package:match5/views/onBoardScreens/login_screen.dart';
import 'package:match5/views/onBoardScreens/second_questionare.dart';
import 'package:match5/views/onBoardScreens/choose_avatar.dart';
import 'package:match5/views/splash_screen.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("some notis are in the back");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

//initialize firebase notifications
  await NotificationService.init();

//initialize local notifications
  await NotificationService.localInit();

  //Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  //on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("bg noti tapped");
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (builder) => NotificationMessage(
                message: message,
                localNotificationResponse: "",
              )));
    }
  });

  //to handle foreground notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);

    if (message.notification != null) {
      NotificationService.showSimpleNotification(
          title: message.notification!.title!,
          body: message.notification!.body!,
          payload: payloadData);
    }
  });

  //for handling the notification in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (builder) => NotificationMessage(
              message: message, localNotificationResponse: "")));
    });
  }

  //initializing app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserProvider()),
      ChangeNotifierProvider(create: (context) => MessageListProvider()),
      ChangeNotifierProvider(create: (context) => NotificationProvider())
    ],
    child: MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
        stream: _connectivityService.connectiviyStream,
        builder: (context, snapshot) {
          if (snapshot.data == ConnectivityResult.none) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: NoInternetScreen(),
            );
          }

          return MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              theme: ThemeData(
                  splashFactory: InkRipple.splashFactory,
                  fontFamily: 'Lato',
                  primaryColor: const Color.fromARGB(255, 255, 220, 0),
                  colorScheme: ColorScheme.fromSwatch().copyWith(
                      secondary: const Color.fromARGB(255, 255, 107, 107))),
              home: const SplashScreen());
        });
  }
}
