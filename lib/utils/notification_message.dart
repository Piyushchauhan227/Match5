import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationMessage extends StatefulWidget {
  const NotificationMessage(
      {required this.message,
      required this.localNotificationResponse,
      super.key});

  final message;
  final localNotificationResponse;

  @override
  State<NotificationMessage> createState() => _NotificationMessageState();
}

class _NotificationMessageState extends State<NotificationMessage> {
  Map payload = {};
  @override
  Widget build(BuildContext context) {
    // final data = ModalRoute.of(context)!.settings.arguments;
    //for background and terminated state
    // if (widget.message is RemoteMessage) {
    //   payload = widget.message.data;
    // }

    // //for foregoround state
    // if (widget.message is NotificationResponse) {
    //   payload = jsonDecode(widget.message as String);
    // }

//for background and terminated state
    if (widget.message != "") {
      payload = widget.message.data;
    }

    // //for foregoround state
    if (widget.localNotificationResponse != "") {
      payload = jsonDecode(widget.localNotificationResponse.payload);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Message"),
      ),
      body: Center(
        child: Text(payload.toString()),
      ),
    );
  }
}
