import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/message_list_provider.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/Pages/navbar/home_page.dart';
import 'package:match5/views/Pages/navbar/messages_page.dart';
import 'package:match5/views/Pages/navbar/notification_page.dart';
import 'package:match5/views/Pages/navbar/settings_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.user, super.key});

  final UserModel user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //UserModel? userhere;
  String? fcmToken = "";
  int currentPage = 0;

  @override
  void initState() {
    getFCMTokenDetails();
    _checkPermissions();
    super.initState();
    getMessageList();
  }

  @override
  Widget build(BuildContext context) {
    var hasNewMessage =
        Provider.of<MessageListProvider>(context, listen: true).hasNewMessage;

    List<Widget> pagesList = [
      HomePage(),
      MessagesPage(
        myUsername: widget.user,
      ),
      const Notification_page(),
      const Setting_page()
    ];

    return Scaffold(
      body: pagesList.elementAt(currentPage),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          currentIndex: currentPage,
          selectedLabelStyle: const TextStyle(fontSize: 12, color: Colors.red),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 20,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: (value) {
            if (!mounted) return;
            setState(() {
              currentPage = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    Icons.message,
                    color: hasNewMessage
                        ? const Color.fromARGB(255, 232, 122, 114)
                        : null,
                  ),
                  if (hasNewMessage)
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                ],
              ),
              label: "Messages",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: "Notification"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Settings"),
          ]),
    );
  }

  Future<void> getFCMTokenDetails() async {
    fcmToken = await Helper.getFCMToken();

    var prevfcmToken = await Helper.getPreviousFCMToken();
    print(widget.user.email);
    print("in between didsa$fcmToken and prev $prevfcmToken");
    print("${widget.user!.fcmToken} and shared pref token is $fcmToken");

    if (!widget.user.fcmToken.contains(fcmToken)) {
      //update new token and delete prevtoken
      if (fcmToken != prevfcmToken) {
        //update and delete
        print("Dasssa tenoi");
        await OnBoardConnection()
            .updateAndDeleteFCMToken(widget.user.id, fcmToken, prevfcmToken);
      } else {
        print("g");
        //just update
        await OnBoardConnection().updateFCM(widget.user.id, fcmToken);
      }
    }
  }

  void _checkPermissions() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print("Authorization already granted");
        break;
      case AuthorizationStatus.denied:
        print("❌ Notifications denied");
        await NotificationService.askForPermissions();
        break;
      case AuthorizationStatus.notDetermined:
        print("🤔 Permission not asked yet");
        await NotificationService.askForPermissions();
        break;
      case AuthorizationStatus.provisional:
        print("⚠️ Provisional permission granted (iOS only)");
        await NotificationService.askForPermissions();
        break;
    }
  }

  void getMessageList() async {
    var list = await MessagesAPI().getSentByMessages(widget.user.id);
    print("this doens work?  $list");
    if (!mounted) return;
    Provider.of<MessageListProvider>(context, listen: false).setList(list);
    Provider.of<MessageListProvider>(context, listen: false)
        .getMessageIndicator();
  }
}
