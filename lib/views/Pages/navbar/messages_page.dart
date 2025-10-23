import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/message_list_provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/socket_service.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/utils/message_card.dart';
import 'package:match5/views/Pages/individual_loaded_chat.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({required this.myUsername, super.key});

  final UserModel myUsername;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  var userId = "";
  var selectedList = [];
  var longPressMode = false;
  var selectionMode = false;
  var selectedChats = [];
  var notReadIndicator = false;

  UserModel? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    user = Provider.of<UserProvider>(context, listen: false).user;
    print("hello here lets check tokens ${user?.fcmToken}");
    getMessages();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //checkForDeletedConversation();
      print("ye to chla mate hai ye mate");
      getMessages();
    });

    Future.microtask(() {
      Provider.of<MessageListProvider>(context, listen: false)
          .setMessageIndicator(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var listFromDB =
        Provider.of<MessageListProvider>(context, listen: true).listFromDb;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: const Text("Messages",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: listFromDB!.isEmpty
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/no_msg.png",
                          width: 140,
                          height: 170,
                        ),
                        Text(
                          " It's quiet here... Start a conversation!",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ],
                    ))
                  : ListView.builder(
                      itemCount: listFromDB.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onLongPress: () {
                            setState(() {
                              longPressMode = true;
                            });
                            makeBottomSheet(
                                listFromDB[index]["sentTo"], user!.id, index);
                          },
                          onTap: () {
                            if (!longPressMode) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (builder) =>
                                          IndividualLoadedChat(
                                            username: listFromDB[index]["name"],
                                            OtherUserId: listFromDB[index]
                                                ["sentTo"],
                                            myId: user!.id,
                                            profilePic: listFromDB[index]
                                                ["userProfile"],
                                            isBot: listFromDB[index]["isBot"],
                                            token: user!.fcmToken,
                                            isItcomingFromMessagePage: true,
                                          )))
                                  .then((onValue) {
                                if (onValue == true) {
                                  if (!mounted) return;
                                  setState(() {
                                    getMessages();
                                  });
                                }
                              });
                            }
                            //iski else bnake tick vala scene likhna hai
                          },
                          child: MessageCard(
                              name: listFromDB[index]["name"],
                              message: listFromDB[index]["message"],
                              time: listFromDB[index]["time"],
                              date: listFromDB[index]["date"],
                              notReadIndicator: notReadIndicator,
                              profilePic: listFromDB[index]["userProfile"],
                              path: listFromDB[index]["path"],
                              status: listFromDB[index]["status"] ?? ""),
                        );
                      }))
        ],
      ),
    );
  }

  void getMessages() async {
    var list = await MessagesAPI().getSentByMessages(widget.myUsername.id);
    print("this doens work?  $list");
    if (!mounted) return;
    Provider.of<MessageListProvider>(context, listen: false).setList(list);
  }

  void makeBottomSheet(otherUserId, myId, index) async {
    final result = await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(12),
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                  onTap: () {
                    setState(() {
                      longPressMode = false;
                    });
                    deletConversation(otherUserId, myId, index);
                    Navigator.pop(context);
                    // Add your delete logic here
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton(
                        onPressed: () {
                          // Your action here
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded edges
                          ),
                          side: BorderSide(
                            color: Colors.black, // Border color
                            width: 1, // Border thickness
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          foregroundColor:
                              Colors.black, // Text and ripple color
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 50, right: 50),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
    //when bottomsheet got dismissed;
    setState(() {
      longPressMode = false;
    });
  }

  void deletConversation(otherUserId, myId, index) async {
    var conversation =
        await MessagesAPI().deleteConversation(otherUserId, myId);
    Provider.of<MessageListProvider>(context, listen: false)
        .deleteConversation(otherUserId);
  }

  Future<void> checkForDeletedConversation(id) async {
    var res = await MessagesAPI().getConversationEvenIfDeleted(id);

    //print(res);
  }
}
