import 'package:flutter/material.dart';
import 'package:match5/const.dart';

class MessageCard extends StatefulWidget {
  const MessageCard(
      {required this.name,
      required this.message,
      required this.time,
      required this.date,
      required this.notReadIndicator,
      required this.profilePic,
      required this.path,
      required this.status,
      super.key});

  final String name;
  final String message;
  final String time;
  final String date;
  final bool notReadIndicator;
  final String profilePic;
  final String path;
  final String status;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("status is ${widget.status}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 10, top: 8, bottom: 8),
                child: ClipOval(
                  child: Image.network(
                    "$BASE_URL/profile_pics/${widget.profilePic}",
                    width: 55,
                    height: 55,
                    fit: BoxFit.fill,
                  ),
                )),
            //messages column
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        child: Text(widget.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: widget.status == "sent"
                                    ? FontWeight.bold
                                    : FontWeight.w500)),
                      ),
                      Container(
                          width: 150,
                          child: widget.path == ""
                              ? Text(widget.message,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: widget.status == "sent"
                                          ? Colors.black
                                          : Color.fromARGB(200, 51, 51, 51),
                                      fontWeight: widget.status == "sent"
                                          ? FontWeight.bold
                                          : FontWeight.normal))
                              : Row(
                                  children: [
                                    Icon(
                                      Icons.image,
                                      size: 18,
                                      color: Color.fromARGB(200, 51, 51, 51),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: widget.message == ""
                                          ? Text(
                                              "Image",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      200, 51, 51, 51)),
                                            )
                                          : Text(
                                              widget.message,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Color.fromARGB(
                                                      200, 51, 51, 51)),
                                            ),
                                    )
                                  ],
                                ))
                    ],
                  ),

                  //time and unread messages column
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.status == "sent")
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 10,
                            ),
                          ),
                        Text(
                          widget.time,
                          style: TextStyle(
                              fontSize: 12,
                              color: widget.status == "sent"
                                  ? Colors.black
                                  : Color.fromARGB(200, 51, 51, 51),
                              fontWeight: widget.status == "sent"
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        Container(
          height: 1,
          width: MediaQuery.of(context).size.width - 30,
          decoration: const BoxDecoration(color: Colors.grey),
        ),
        SizedBox(
          height: 4,
        )
        //grey line below
      ],
    );
  }
}
