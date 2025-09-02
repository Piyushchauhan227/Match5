import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/bot_user_api.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/notification_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/message_model.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/const.dart';
import 'package:match5/questions.dart';
import 'package:match5/utils/message_send.dart';
import 'package:match5/utils/message_with_image.dart';
import 'package:match5/utils/prompted_questions.dart';
import 'package:match5/utils/reply_message.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:match5/utils/reply_with_image.dart';
import 'package:match5/views/Pages/connect_screen.dart';
import 'package:match5/views/Pages/image_view.dart';
import 'package:http/http.dart' as http;
import 'package:match5/views/Pages/individual_loaded_chat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:lottie/lottie.dart';

class IndividualChatPage extends StatefulWidget {
  const IndividualChatPage(
      {required this.socket,
      required this.username,
      required this.myId,
      required this.partnerId,
      required this.profilePic,
      required this.role,
      required this.isBot,
      super.key});

  final IO.Socket socket;
  final String username;
  final String myId;
  final String partnerId;
  final String profilePic;
  final String role;
  final bool isBot;

  @override
  State<IndividualChatPage> createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  var messages = [];
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmoji = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? file;
  var messageApiCount = 0;
  var conversationId = "";
  var role = "";
  var decisionTime = false;
  var matched = false;
  UserModel? userModel;
  bool showPrompts = true;
  bool answerTurn = true;
  bool firstTimeAnswer = true;
  bool decisionTimeForBot = false;
  bool showAlerts = false;
  bool navigatoForwardFromTimer = false;

  List<String> randomShuffled = [];
  bool didYouMatchedFirst = false;
  Timer? chatWaitTimer;
  Timer? counterTimer;
  var timeLeft = 5;
  bool timerStart = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    role = widget.role;
    userModel = Provider.of<UserProvider>(context, listen: false).user;

    final shuffled = [...softQuestions]..shuffle(Random());
    randomShuffled = shuffled.take(5).toList();
    connect();

    widget.socket.onConnect((_) {
      widget.socket.emit("matching", {
        "id": widget.myId,
        "username": widget.username,
        "userProfile": widget.profilePic
      });
    });

    widget.socket.onDisconnect((_) {});

    timeStart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    _scrollController.dispose();

    if (!matched) {
      print("its here matched but not disconnected");
      widget.socket.disconnect();
      widget.socket.dispose();
    }
    chatWaitTimer?.cancel();
    counterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (_showEmoji) {
          _showEmoji = !_showEmoji;
        }
      },
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            alertForBack();
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 35,
            leading: InkWell(
                onTap: () {
                  alertForBack();
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: const Icon(Icons.arrow_back),
                )),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.network(
                    "$BASE_URL/profile_pics/${widget.profilePic}",
                    width: 48,
                    height: 48,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 150,
                    child: Text(widget.username,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            actions: [
              if (timerStart)
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: timeLeft / 5,
                        strokeWidth: 5,
                        backgroundColor: Colors.grey,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                      Text(
                        '$timeLeft',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
          body: Stack(children: [
            Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return Container(
                              height: 60,
                            );
                          }
                          if (messages[index].type == "source") {
                            if (messages[index].path == "") {
                              return MessageSend(
                                message: messages[index].message,
                                time: messages[index].time,
                                status: "seen",
                              );
                            } else {
                              return MessageWithImage(
                                  path: messages[index].path,
                                  time: messages[index].time,
                                  caption: messages[index].message,
                                  status: "seen");
                            }
                          } else {
                            if (messages[index].path == "") {
                              return ReplyMessage(
                                  message: messages[index].message,
                                  time: messages[index].time);
                            } else {
                              return ReplyWithImage(
                                path: messages[index].path,
                                time: messages[index].time,
                                caption: messages[index].message,
                                status: "seen",
                              );
                            }
                          }
                        })),
                if (role == "questioner")
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            firstTimeAnswer = false;
                            showPrompts = !showPrompts;
                          });
                        },
                        child: Material(
                          elevation: 0,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  showPrompts == false
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_up,
                                  size: 28,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Ask something interesting",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: showPrompts ? 150 : 300,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    answerTurn = true;
                                  });
                                  var now = DateTime.now();
                                  var date = DateFormat("d MMMM y")
                                      .format(DateTime.now());
                                  var dateArr = date.split(" ");
                                  var timeToSend =
                                      ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");

                                  sendMessage(randomShuffled[index], timeToSend,
                                      "", false, false);
                                },
                                child: PromptedQuestions(
                                  question: randomShuffled[index],
                                  color: colors[index % colors.length],
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                if (role == "reader")
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 223, 231, 252),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.question_answer, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Your partner is picking a question...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                if (role == "answerer")
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        color: Color.fromRGBO(247, 247, 255, 100),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // IconButton(
                              //     onPressed: () {
                              //       filePicker();
                              //     },
                              //     icon:
                              //         Icon(Icons.add_circle_outline_outlined)
                              //         ),
                              SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _showEmoji = !_showEmoji;
                                    });
                                  },
                                  icon: Icon(Icons.emoji_emotions_outlined)),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: _textEditingController,
                                  keyboardType: TextInputType.multiline,
                                  textAlignVertical: TextAlignVertical.center,
                                  onTap: () {
                                    if (_showEmoji) {
                                      _showEmoji = !_showEmoji;
                                    }
                                  },
                                  decoration: InputDecoration(
                                      suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              firstTimeAnswer = false;
                                              answerTurn = false;
                                            });
                                            var now = DateTime.now();
                                            var date = DateFormat('d MMMM y')
                                                .format(DateTime.now());
                                            var dateArr = date.split(" ");

                                            print(date);
                                            var timeToSend =
                                                ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");
                                            sendMessage(
                                                _textEditingController.text,
                                                timeToSend,
                                                "",
                                                true,
                                                false);
                                            setState(() {
                                              if (_showEmoji) {
                                                _showEmoji = !_showEmoji;
                                                _textEditingController.clear();
                                              }
                                            });

                                            _scrollController.animateTo(
                                                _scrollController
                                                    .position.maxScrollExtent,
                                                duration:
                                                    Duration(milliseconds: 300),
                                                curve: Curves.bounceIn);
                                          },
                                          child: Icon(Icons.send)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              width: 0,
                                              style: BorderStyle.none)),
                                      fillColor:
                                          Color.fromRGBO(247, 247, 255, 100),
                                      filled: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_showEmoji)
                  EmojiPicker(
                    textEditingController:
                        _textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                    config: Config(
                      height: MediaQuery.of(context).size.height * .40,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                        // Issue: https://github.com/flutter/flutter/issues/28894
                        emojiSizeMax: 28 *
                            (foundation.defaultTargetPlatform ==
                                    TargetPlatform.iOS
                                ? 1.20
                                : 1.0),
                      ),
                      viewOrderConfig: const ViewOrderConfig(
                        top: EmojiPickerItem.categoryBar,
                        middle: EmojiPickerItem.emojiView,
                        bottom: EmojiPickerItem.searchBar,
                      ),
                      skinToneConfig: const SkinToneConfig(),
                      categoryViewConfig: const CategoryViewConfig(),
                      bottomActionBarConfig: const BottomActionBarConfig(),
                      searchViewConfig: const SearchViewConfig(),
                    ),
                  )
              ],
            ),
            decisionTime
                ? Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration:
                            BoxDecoration(color: Color.fromARGB(50, 0, 0, 0)),
                        child: Center(
                            child: Container(
                          height: 180,
                          width: 250,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 8,
                                ),
                                Image.asset(
                                  "assets/heart_sign.png",
                                  height: 35,
                                  width: 35,
                                ),
                                Text(
                                  "Match?",
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (decisionTimeForBot) {
                                          widget.socket.emit(
                                              "decision_answer", {
                                            "userId": widget.myId,
                                            "answer": "yes",
                                            "bot": true
                                          });
                                        } else {
                                          widget.socket.emit(
                                              "decision_answer", {
                                            "userId": widget.myId,
                                            "answer": "yes",
                                            "bot": false
                                          });
                                        }

                                        setState(() {
                                          decisionTime = false;
                                          decisionTimeForBot = false;
                                        });
                                        alertForMatchYes();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        height: 40,
                                        width: 100,
                                        child: Icon(
                                          Icons.thumb_up,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        alertOnDecisionNo();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        height: 40,
                                        width: 100,
                                        child: Icon(
                                          Icons.thumb_down,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        )),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  )
          ]),
        ),
      ),
    );
  }

  void sendMessage(String message, String time, String imagepath,
      bool isItFromTextFormField, bool botQuestion) async {
    if (!mounted) return;
    //with every message send check other person status
    timeStart();
    if (message != "") {
      if (!botQuestion) {
        messageApiCount++;

        setMessage("source", message, time, imagepath, "seen");

        _textEditingController.text = "";

        widget.socket.emit("message", {
          "message": message,
          "time": time,
          "path": imagepath,
          "where": isItFromTextFormField,
          "isBot": widget.isBot,
          "role": role
        });

        if (messageApiCount <= 1) {
          //first check that is the conversationId already got created by other device?
          var isConversationMade = await MessagesAPI()
              .getConversationId(widget.partnerId, widget.myId);
          if (isConversationMade == "null") {
            if (widget.isBot) {
              var conId = await MessagesAPI().createConversation(message, time,
                  widget.partnerId, widget.myId, imagepath, "true");
              setState(() {
                conversationId = conId;
              });
            } else {
              var conId = await MessagesAPI().createConversation(message, time,
                  widget.partnerId, widget.myId, imagepath, "false");
              setState(() {
                conversationId = conId;
              });
            }
          } else {
            var isConversationMade = await MessagesAPI()
                .getConversationId(widget.partnerId, widget.myId);
            setState(() {
              conversationId = isConversationMade;
            });
            MessagesAPI().updateConversation(message, time, widget.partnerId,
                widget.myId, conversationId, "seen", imagepath);
          }
        } else {
          //no need to check just update the conversation cause we already got the conversationId here.
          MessagesAPI().updateConversation(message, time, widget.partnerId,
              widget.myId, conversationId, "seen", imagepath);
        }
      } else {
        //bot questions
        messageApiCount++;

        setMessage("bot", message, time, imagepath, "seen");

        _textEditingController.text = "";

        widget.socket.emit("message", {
          "message": message,
          "time": time,
          "path": imagepath,
          "where": isItFromTextFormField,
          "isBot": widget.isBot,
          "role": role
        });

        if (messageApiCount <= 1) {
          //first check that is the conversationId already got created by other device?
          var isConversationMade = await MessagesAPI()
              .getConversationId(widget.myId, widget.partnerId);
          if (isConversationMade == "null") {
            var conId = await MessagesAPI().createConversation(message, time,
                widget.myId, widget.partnerId, imagepath, "true");
            if (mounted) {
              setState(() {
                conversationId = conId;
              });
            }
          } else {
            var isConversationMade = await MessagesAPI()
                .getConversationId(widget.myId, widget.partnerId);
            setState(() {
              conversationId = isConversationMade;
            });
            MessagesAPI().updateConversation(message, time, widget.myId,
                widget.partnerId, conversationId, "seen", imagepath);
          }
        } else {
          //no need to check just update the conversation cause we already got the conversationId here.
          MessagesAPI().updateConversation(message, time, widget.myId,
              widget.partnerId, conversationId, "seen", imagepath);
        }
      }
    }
  }

  void setMessage(
      String s, String msg, String time, String imagepath, String status) {
    //check is there any conversation already created or not
    MessageModel messageModel = MessageModel(
        type: s, message: msg, time: time, path: imagepath, status: status);
    if (mounted) {
      setState(() {
        messages.add(messageModel);
      });
    }
  }

  void connect() {
    if (widget.isBot) {
      if (widget.role == "questioner") {
        print("questioner is here");
        print(widget.role);
      } else {
        print("reader is here");
        print(widget.role);
        var question = softQuestions[Random().nextInt(softQuestions.length)];
        var now = DateTime.now();
        var date = DateFormat("d MMMM y").format(DateTime.now());
        var dateArr = date.split(" ");
        var timeToSend =
            ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");

        sendMessage(question, timeToSend, "", false, true);
      }
    }

    widget.socket.on("message", (data) {
      timeStart();
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.bounceIn);

      print("botmsgs are these");
      print(data['message']);
      setMessage(
          "destination", data["message"], data["time"], data["path"], "sent");

      if (widget.isBot) {
        if (data["botAnswered"]) {
          print("checkyhaha");

          MessagesAPI().updateConversation(
              data["message"],
              data["time"],
              widget.myId,
              widget.partnerId,
              conversationId,
              "seen",
              data["path"]);

          var question = softQuestions[Random().nextInt(softQuestions.length)];
          var now = DateTime.now();
          var date = DateFormat("d MMMM y").format(DateTime.now());
          var dateArr = date.split(" ");
          var timeToSend =
              ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");

          Timer waitTime = Timer(Duration(seconds: 5), () {
            sendMessage(question, timeToSend, "", false, true);
          });
        }
      }
    });

    widget.socket.on("chat_end", (data) {
      print("chatcanel true hi u");
      alertForChatCancel();
    });

    widget.socket.on("role_reverse", (data) {
      print("role reversing here");
      if (mounted) {
        setState(() {
          role = data["role"];
        });
      }
    });

    widget.socket.on("decision_time", (data) {
      print("decision time");
      setState(() {
        decisionTime = true;
      });
      if (data["bot"]) {
        decisionTimeForBot = true;
      }
    });

    widget.socket.on("match_result", (data) async {
      print("mtach result is here");

      if (data["matched"]) {
        await BotUserAPI().updateBot(widget.myId, widget.partnerId);
        print("yayyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy u matched");

        decisionTime = false;
        matched = true;

        if (!mounted) return;
        Navigator.of(context).pop();

        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (builder) => IndividualLoadedChat(
                username: widget.username,
                OtherUserId: widget.partnerId,
                myId: widget.myId,
                myUsername: userModel!,
                profilePic: widget.profilePic,
                isBot: widget.isBot.toString())));
      } else {
        print("nnnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooo");
        //not matched this time prompt
        deleteConversationFirst();
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    });

    widget.socket.on("user_left", (data) {
      alertForChatCancel();
    });
  }

  void alertForBack() {
    showAlerts = true;
    if (!mounted) return;
    Widget okButton = TextButton(
        onPressed: () {
          deleteConversationFirst();
          widget.socket.emit("chat_end", {"message": "chat ended"});

          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: Text("ok"));

    Widget cancelButton = TextButton(
        onPressed: () {
          showAlerts = false;
          Navigator.of(context).pop();
        },
        child: Text("Cancel"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm"),
            content: Text(
                "Are you sure you want to quit the chat you might never meet this person again"),
            actions: [okButton, cancelButton],
          );
        });
  }

  void alertForChatCancel() {
    showAlerts = true;
    print("oko");
    if (!mounted) return;
    Widget okButton = TextButton(
        onPressed: () {
          deleteConversationFirst();
          // widget.socket.emit("chat_end", {"message": "chat ended"});
          if (!mounted) return;
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          //Navigator.of(context).pop();
        },
        child: Text("ok"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sorry!"),
            content: Text("The other person has left the chat Room"),
            actions: [okButton],
          );
        });
  }

  void alertOnDecisionNo() {
    if (!mounted) return;
    Widget okButton = TextButton(
        onPressed: () async {
          widget.socket
              .emit("decision_answer", {"userId": widget.myId, "answer": "No"});
          await MessagesAPI().deleteConversation(widget.partnerId, widget.myId);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: Text("OK"));

    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Cancel"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("do you really want to not Match?"),
            actions: [okButton, cancelButton],
          );
        });
  }

  Future<void> deleteConversationFirst() async {
    print("idr v ni aaya kya");
    await MessagesAPI().deleteConversation(widget.partnerId, widget.myId);
    if (widget.isBot) {
      await MessagesAPI().deleteConversation(widget.myId, widget.partnerId);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void alertForMatchYes() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Container(
                  height: 300,
                  width: 230,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/heart_lottie.json',
                            height: 150), // cute animation
                        SizedBox(height: 20),
                        Text(
                          "Let’s see if the feeling’s mutual",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Waiting for their response...",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )),
            ),
          );
        });
  }

  void timeStart() {
    if (mounted) {
      setState(() {
        timerStart = false;
        timeLeft = 5;
      });
    }
    chatWaitTimer?.cancel();
    counterTimer?.cancel();
    chatWaitTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      startTopCounter();
    });
  }

  void startTopCounter() {
    counterTimer?.cancel();
    counterTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          timerStart = true;
        });
      }
      if (timeLeft > 0) {
        if (mounted) {
          setState(() {
            timeLeft--;
          });
        }
      }
      if (timeLeft == 0) {
        if (!mounted) return;
        if (!navigatoForwardFromTimer) {
          if (showAlerts) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
          }

          navigatoForwardFromTimer = true;
        }
      }
    });
  }
}
