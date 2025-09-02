import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/Pages/navbar/home_page.dart';
import 'package:match5/views/Pages/navbar/messages_page.dart';
import 'package:match5/views/Pages/navbar/notification_page.dart';
import 'package:match5/views/Pages/navbar/settings_page.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pagesList = [
      HomePage(
        user: widget.user,
      ),
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
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 20,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          onTap: (value) {
            if (!mounted) return;
            setState(() {
              currentPage = value;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
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
        print("D");
        await OnBoardConnection()
            .updateAndDeleteFCMToken(widget.user.id, fcmToken, prevfcmToken);
      } else {
        print("g");
        //just update
        await OnBoardConnection().updateFCM(widget.user.id, fcmToken);
      }
    }
  }
}
