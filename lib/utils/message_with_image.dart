import 'dart:io';
import 'package:flutter/material.dart';
import 'package:match5/views/Pages/full_screen_image_view.dart';

class MessageWithImage extends StatelessWidget {
  const MessageWithImage(
      {required this.path,
      required this.caption,
      required this.time,
      required this.status,
      super.key});

  final String path;
  final String caption;
  final String time;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Container(
              width: 170,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(245, 214, 218, 1),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(8)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) =>
                                  FullScreenImageView(imagepath: path)));
                        },
                        child: Image.network(
                          path,
                          fit: BoxFit.cover,
                          height: 200,
                          width: 300,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Container(
                              height: 200,
                              width: 300,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.pinkAccent,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (caption != "")
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(caption),
                      ),
                    ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: caption == ""
                          ? const EdgeInsets.only(
                              left: 8, right: 8, top: 8, bottom: 8)
                          : const EdgeInsets.only(left: 8, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          status == "sent"
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
                  ),
                ],
              )),
        ));
  }
}
