import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImageView extends StatefulWidget {
  const ImageView(
      {required this.path,
      required this.onImageSent,
      required this.bytes,
      super.key});
  final String path;
  final Function onImageSent;
  final Uint8List bytes;

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  final TextEditingController _textEditingController = TextEditingController();

  bool isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back)),
          title: const Text("Image",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.file(
                    File(widget.path),
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(211, 211, 211, 70)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              textAlignVertical: TextAlignVertical.center,
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                  hintText: "Caption...",
                                  hintStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black))),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (!mounted) return;
                              setState(() {
                                isSent = true;
                              });
                              var now = DateTime.now();
                              var date =
                                  DateFormat('d MMMM y').format(DateTime.now());
                              var dateArr = date.split(" ");

                              print(date);
                              var timeToSend =
                                  ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");

                              widget.onImageSent(widget.path, timeToSend,
                                  _textEditingController.text, widget.bytes);
                            },
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            isSent == true
                ? Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Color.fromARGB(80, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()],
                      ),
                    ),
                  )
                : SizedBox(height: 0)
          ],
        ));
  }
}
