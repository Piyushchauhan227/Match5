import 'package:flutter/material.dart';
import 'package:match5/Database/api/notification_api.dart';
import 'package:match5/Provider/notification_provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/utils/notification_card.dart';
import 'package:match5/utils/notification_date_card.dart';
import 'package:match5/views/Pages/connect_screen.dart';
import 'package:match5/views/Pages/wallet_page.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Provider/notification_provider.dart';

class Notification_page extends StatefulWidget {
  const Notification_page({super.key});

  @override
  State<Notification_page> createState() => _Notification_pageState();
}

class _Notification_pageState extends State<Notification_page> {
  var user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
    getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    var noti = Provider.of<NotificationProvider>(context, listen: true).list;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: const Text("Notifications",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: noti.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == 0) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ConnectScreen(typeOfGame: "Truth Rush")));
                        } else if (index == 1) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => WalletPage()),
                          );
                        }
                      },
                      child: NotificationCard(
                        title: noti[index]["title"],
                        message: noti[index]["message"],
                        time: noti[index]["time"],
                      ),
                    );
                  }))
        ],
      ),
    );
  }

  void getNotifications() async {
    var noti = await NotificationAPI().getUserNotifications(user.id);
    if (!mounted) return;
    Provider.of<NotificationProvider>(context, listen: false).setList(noti);
  }
}
