import 'package:flutter/material.dart';
import 'package:match5/main.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard(
      {required this.title,
      required this.message,
      required this.time,
      super.key});

  final String title;
  final String message;
  final String time;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Image.asset(
                "assets/icon.png",
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 120,
                    child: Text(
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        widget.message),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    widget.time,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
