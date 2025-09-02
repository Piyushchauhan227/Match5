import 'package:flutter/material.dart';

class MessageSend extends StatefulWidget {
  const MessageSend(
      {super.key,
      required this.message,
      required this.time,
      required this.status});

  final String message;
  final String time;
  final String status;

  @override
  State<MessageSend> createState() => _MessageSendState();
}

class _MessageSendState extends State<MessageSend> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("gg");
    print(widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          color: Color.fromRGBO(245, 214, 218, 1),
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.time,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      widget.status == "sent"
                          ? Icon(
                              Icons.done_all,
                              size: 20,
                              color: Colors.grey,
                            )
                          : Icon(
                              Icons.done_all,
                              size: 20,
                              color: Colors.blue,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
