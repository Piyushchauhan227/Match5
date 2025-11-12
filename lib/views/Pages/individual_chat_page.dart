import 'dart:async';
import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/bot_status_api.dart';
import 'package:match5/Database/api/bot_user_api.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/message_model.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/analytics_provider.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/Services/level_play_ad_service.dart';
import 'package:match5/const.dart';
import 'package:match5/questions.dart';
import 'package:match5/utils/message_send.dart';
import 'package:match5/utils/message_with_image.dart';
import 'package:match5/utils/prompted_questions.dart';
import 'package:match5/utils/reply_message.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:match5/utils/reply_with_image.dart';
import 'package:match5/views/Pages/connect_screen.dart';
import 'package:match5/views/Pages/individual_loaded_chat.dart';
import 'package:match5/views/Pages/wallet_page.dart';
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
  var timeLeft = 10;
  bool timerStart = false;
  bool alreadyPoppedNoNeedForMatchResult = false;
  bool chatAlreadyCanceled = false;
  // bool showBuyMoreFireinMatchPrompt = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //initialize ads

    role = widget.role;
    userModel = Provider.of<UserProvider>(context, listen: false).user;

    final shuffled = [...softQuestions]..shuffle(Random());
    randomShuffled = shuffled.take(10).toList();
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("in here mae");
      AdService().loadInterstitialAd();
      //LevelPlayService().loadInterstitial();
      Provider.of<AnalyticsProvider>(context, listen: false)
          .logEvent("individual_chat_page", param: {
        "user_id": userModel!.id,
      });
    });
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
    // var userForFires = Provider.of<UserProvider>(context, listen: true).user;
    // if (userForFires!.coins <= 0) {
    //   setState(() {
    //     showBuyMoreFireinMatchPrompt = true;
    //   });
    // }

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

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
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(widget.username,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      )),
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
                          fontSize: 22,
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
                Container(
                  margin: EdgeInsets.all(4),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: role == "reader"
                          ? [Colors.grey.shade100, Colors.grey.shade400]
                          : [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: role == "reader"
                            ? Colors.grey.shade100
                            : Colors.orange.shade100,
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          role != "reader"
                              ? "🔥 It’s your turn!"
                              : "⏳ Waiting for ${widget.username}",
                          style: TextStyle(
                            color: role != "reader"
                                ? Colors.white
                                : Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role != "reader"
                              ? "Go ahead, send your next message!"
                              : "They’re typing... hold tight!",
                          style: TextStyle(
                            color: role != "reader"
                                ? Colors.white70
                                : Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                        height: showPrompts
                            ? isKeyboardVisible
                                ? 250
                                : 450
                            : 250,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                        child: ListView.builder(
                            itemCount: 10,
                            shrinkWrap: true,
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.question_answer, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          "Free chat unlocks when you both match 🔓",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
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
                        color: Color.fromRGBO(227, 247, 255, 100),
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
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
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
                                            if (!mounted) return;
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
                        decoration:
                            BoxDecoration(color: Color.fromARGB(50, 0, 0, 0)),
                        child: Center(
                            child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                            minWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          child: Container(
                            // height: 250,
                            // width: 260,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
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
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Connect and talk freely once you match.",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (decisionTimeForBot) {
                                            widget.socket
                                                .emit("decision_answer", {
                                              "userId": widget.myId,
                                              "answer": "yes",
                                              "bot": true,
                                              "conversationId": conversationId
                                            });
                                          } else {
                                            widget.socket
                                                .emit("decision_answer", {
                                              "userId": widget.myId,
                                              "answer": "yes",
                                              "bot": false,
                                              "conversationId": conversationId
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
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.thumb_up,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                // Text(
                                                //   "(${userForFires!.coins.toString()})",
                                                //   style: TextStyle(
                                                //       color: Colors.white,
                                                //       fontSize: 16,
                                                //       fontWeight:
                                                //           FontWeight.bold),
                                                // )
                                              ],
                                            )),
                                      ),
                                      SizedBox(
                                        width: 8,
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
                                  ),
                                  // if (showBuyMoreFireinMatchPrompt)
                                  //   SizedBox(
                                  //     height: 24,
                                  //   ),
                                  // if (showBuyMoreFireinMatchPrompt)
                                  //   InkWell(
                                  //     onTap: () {
                                  //       if (!mounted) return;
                                  //       Navigator.of(context).pushReplacement(
                                  //           MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   WalletPage()));
                                  //     },
                                  //     child: Container(
                                  //         width: 220,
                                  //         height: 40,
                                  //         decoration: BoxDecoration(
                                  //             color: Colors.yellow,
                                  //             borderRadius:
                                  //                 BorderRadius.circular(20)),
                                  //         child: Row(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.center,
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.center,
                                  //           children: [
                                  //             Text("Want more Fires?",
                                  //                 style: TextStyle(
                                  //                     color: Colors.black,
                                  //                     fontSize: 16,
                                  //                     fontWeight:
                                  //                         FontWeight.bold)),
                                  //             SizedBox(
                                  //               width: 8,
                                  //             ),
                                  //             Image.asset(
                                  //               "assets/fire.png",
                                  //               height: 20,
                                  //               width: 20,
                                  //             )
                                  //           ],
                                  //         )),
                                  //   ),
                                  // if (showBuyMoreFireinMatchPrompt)
                                  //   SizedBox(
                                  //     height: 8,
                                  //   ),
                                  // if (showBuyMoreFireinMatchPrompt)
                                  //   Padding(
                                  //     padding: const EdgeInsets.all(4.0),
                                  //     child: Text(
                                  //       "You need more Fires to match!",
                                  //       style: TextStyle(
                                  //           color: Colors.red,
                                  //           fontSize: 16,
                                  //           fontWeight: FontWeight.bold),
                                  //     ),
                                  //   )
                                ],
                              ),
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
          "role": role,
          "conversationId": conversationId,
          "peerId": widget.partnerId,
          "fcmTokens": userModel!.fcmToken,
          "interestedGender": userModel!.interestedGender,
          "myId": widget.myId,
          "username": widget.username
        });

        if (messageApiCount <= 1) {
          //first check that is the conversationId already got created by partner?
          var isConversationMade = await MessagesAPI()
              .getConversationId(widget.partnerId, widget.myId);
          if (isConversationMade == "null") {
            if (widget.isBot) {
              var conId = await MessagesAPI().createConversation(message, time,
                  widget.partnerId, widget.myId, imagepath, "true", "seen");
              setState(() {
                conversationId = conId;
              });
            } else {
              var conId = await MessagesAPI().createConversation(message, time,
                  widget.partnerId, widget.myId, imagepath, "false", "seen");
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

          print("pehle mein ");
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
          "role": role,
          "conversationId": conversationId,
          "peerId": widget.partnerId,
          "fcmTokens": userModel!.fcmToken,
          "interestedGender": userModel!.interestedGender,
          "myId": widget.myId
        });

        if (messageApiCount <= 1) {
          //first check that is the conversationId already got created by other device?
          var isConversationMade = await MessagesAPI()
              .getConversationId(widget.myId, widget.partnerId);
          if (isConversationMade == "null") {
            var conId = await MessagesAPI().createConversation(message, time,
                widget.myId, widget.partnerId, imagepath, "true", "seen");
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
          //   //no need to check just update the conversation cause we already got the conversationId here.
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
      if (!mounted) return;
      timeStart();
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
      }

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
      if (!chatAlreadyCanceled) {
        alertForChatCancel();
      }
    });

    widget.socket.on("role_reverse", (data) {
      print("role reversing here , ${data["role"]}");
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
        if (widget.isBot) {
          print("yay bottttts u matched");
          await BotUserAPI().updateBot(widget.myId, widget.partnerId);
          await BotStatusApi().createBotStatus(widget.myId, widget.partnerId);
        }

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
                  profilePic: widget.profilePic,
                  isBot: widget.isBot.toString(),
                  token: userModel!.fcmToken,
                  isItcomingFromMessagePage: false,
                )));
      } else {
        if (!alreadyPoppedNoNeedForMatchResult) {
          // AdService().showInterstitialAd();
          print("nnnnnnnnnnnnnnnnnnoooooooooooooooooooooooooooooooooooooooo");
          //not matched this time prompt
          deleteConversationFirst();
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Sorry Other user left")));
          Navigator.of(context).pop();
        }
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
    chatAlreadyCanceled = true;
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
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              deleteConversationFirst();
              if (!mounted) return false;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              return true;
            },
            child: AlertDialog(
              title: Text("Sorry!"),
              content: Text("The other person has left the chat Room"),
              actions: [okButton],
            ),
          );
        });
  }

  void alertOnDecisionNo() async {
    // if (!mounted) return;
    // Widget okButton = TextButton(
    //     onPressed: () async {
    //       widget.socket.emit("decision_answer", {
    //         "userId": widget.myId,
    //         "answer": "No",
    //         "conversationId": conversationId
    //       });
    //       await MessagesAPI().deleteConversation(widget.partnerId, widget.myId);
    //       Navigator.of(context).pop();
    //     },
    //     child: Text("Ok"));

    // Widget cancelButton = TextButton(
    //     onPressed: () {
    //       Navigator.of(context).pop();
    //     },
    //     child: Text("Cancel"));

    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text("Do you really want to not Match?"),
    //         actions: [okButton, cancelButton],
    //       );
    //     });
    alreadyPoppedNoNeedForMatchResult = true;
    widget.socket.emit("decision_answer", {
      "userId": widget.myId,
      "answer": "No",
      "conversationId": conversationId
    });
    await MessagesAPI().deleteConversation(widget.partnerId, widget.myId);
    if (!mounted) return;

    Navigator.of(context).pop();
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
    showAlerts = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Dialog(
              child: Container(
                  height: 320,
                  width: 300,
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
        timeLeft = 10;
      });
    }
    chatWaitTimer?.cancel();
    counterTimer?.cancel();
    chatWaitTimer = Timer.periodic(Duration(seconds: 60), (timer) {
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
      if (timeLeft == 0 && !navigatoForwardFromTimer) {
        navigatoForwardFromTimer = true;
        counterTimer?.cancel();
        if (showAlerts) {
          //delete conversation here
          print("dddddeeelint");
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }

          // delay next pop slightly to let previous close cleanly
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted && Navigator.of(context).canPop()) {
              try {
                Navigator.of(context).pop();
              } catch (e) {
                print("⚠️ Safe catch: $e");
              }
            }
          });
        } else {
          print(" dpooohaaaa. dddddeeelint");
          if (mounted && Navigator.of(context).canPop()) {
            try {
              Navigator.of(context).pop();
            } catch (e) {
              print("⚠️ Safe catch: $e");
            }
          }
        }
      }
    });
  }
}
