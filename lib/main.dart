import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:match5/Provider/analytics_provider.dart';
import 'package:match5/Provider/message_list_provider.dart';
import 'package:match5/Provider/notification_provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/Services/connectivity_service.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/firebase_options.dart';
import 'package:match5/utils/notification_message.dart';
import 'package:match5/views/Pages/individual_loaded_chat.dart';
import 'package:match5/views/Pages/navbar/messages_page.dart';
import 'package:match5/views/Pages/no_internet_screen.dart';
import 'package:match5/views/splash_screen.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("s schi mein ye dfrnt vala hai ");
  }
}

void main() async {
  //initializing app
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //initialize admob
    Future.delayed(const Duration(milliseconds: 300), () {
      AdService().init();
    });

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Send Flutter framework errors to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

//initialize firebase notifications
    await NotificationService.init();

//initialize local notifications
    await NotificationService.localInit();

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => MessageListProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => AnalyticsProvider()),
      ],
      child: MainApp(),
    ));
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    //on background notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        var payload = message.data;
        print(payload);
        var tokens = List<String>.from(jsonDecode(payload["tokens"]));
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (builder) => IndividualLoadedChat(
                  username: payload["username"],
                  OtherUserId: payload["otherUserId"],
                  myId: payload["myId"],
                  profilePic: payload["profilePic"],
                  isBot: payload["isBot"],
                  token: tokens,
                  isItcomingFromMessagePage: false,
                  comingFromAd: true,
                )));
      }
    });

    //to handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String payloadData = jsonEncode(message.data);

      if (message.notification != null) {
        if (message.data["type"] == "chat") {
          print("checking noti ethe e aa");
          Provider.of<MessageListProvider>(context, listen: false)
              .setMessageIndicator(true);
        } else {
          print("tatte");
        }
        //setting provider to true so that it can show a indicator

        NotificationService.showSimpleNotification(
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: payloadData);
      }
    });

    handleTerminatedNoti();
  }

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

  void handleTerminatedNoti() async {
    //for handling the notification in terminated state
    final RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      print("launched from terminated state");
      Future.delayed(Duration(seconds: 1), () {
        var payload = message.data;
        print(payload);
        var tokens = List<String>.from(jsonDecode(payload["tokens"]));
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (builder) => IndividualLoadedChat(
                  username: payload["username"],
                  OtherUserId: payload["otherUserId"],
                  myId: payload["myId"],
                  profilePic: payload["profilePic"],
                  isBot: payload["isBot"],
                  token: tokens,
                  isItcomingFromMessagePage: false,
                  comingFromAd: true,
                )));
      });
    }
  }
}
