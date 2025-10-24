import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/block_user_api.dart';
import 'package:match5/Database/api/bot_status_api.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/notification_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Database/api/report_user_api.dart';
import 'package:match5/Models/message_model.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/Services/resize_helper.dart';
import 'package:match5/Services/socket_service.dart';
import 'package:match5/const.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/utils/message_send.dart';
import 'package:match5/utils/message_with_image.dart';
import 'package:match5/utils/reply_message.dart';
import 'package:match5/utils/reply_with_image.dart';
import 'package:match5/views/Pages/full_screen_image_view.dart';
import 'package:match5/views/Pages/image_view.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:match5/Provider/message_list_provider.dart';

class IndividualLoadedChat extends StatefulWidget {
  const IndividualLoadedChat(
      {required this.username,
      required this.OtherUserId,
      required this.myId,
      required this.profilePic,
      required this.isBot,
      required this.token,
      required this.isItcomingFromMessagePage,
      this.comingFromAd,
      super.key});

  final String username;
  final String OtherUserId;
  final String myId;
  final bool
      isItcomingFromMessagePage; // true if coming from message page false if coming from indiviual page;
  final String profilePic;
  final String isBot;
  final List<dynamic> token;
  final bool? comingFromAd;

  @override
  State<IndividualLoadedChat> createState() => _IndividualLoadedChatState();
}

class _IndividualLoadedChatState extends State<IndividualLoadedChat>
    with WidgetsBindingObserver {
  var messages = [];
  var mm = [];
  late IO.Socket? socket;
  final TextEditingController _textEditingController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  var userStatus = false;
  var isBlocked = "false";
  var blockedByOtherUser = false;
  bool _showEmoji = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? file;
  var conversationId = "";
  //starting page is first so 1
  var page = 1;
  bool limit = false;
  UserModel? myUserModel;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    //initializing interstitial ad;
    print(
        "botting checkig hai ${widget.isBot} and cming from ad is ${widget.comingFromAd} and tokens are ${widget.token}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isItcomingFromMessagePage == false &&
          (widget.comingFromAd == false || widget.comingFromAd == null)) {
        print("hun chal ad");
        AdService().showInterstitialAd();
      } else {
        print("hje ni legenda");
      }
    });

    checkBlockingAtFirst();
    getConversation(page);
    print("ddddddddddd");

    if (!mounted) return;
    myUserModel = Provider.of<UserProvider>(context, listen: false).user;
    print(
        "profile check krenge ${widget.profilePic} and other id is ${widget.OtherUserId}  and my id is ${myUserModel!.id} and token here is ${myUserModel?.fcmToken}");
  }

  @override
  void dispose() {
    print("dispoind");
    WidgetsBinding.instance.removeObserver(this);
    disconnectSocket();
    _textEditingController.dispose();
    _scrollController.dispose();
    socket?.disconnect();
    socket?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("ye chala kua");
      //disconnectSocket();
    } else if (state == AppLifecycleState.resumed) {
      print("pause valaS chala kua");
      // App came to foreground
      print("App is resumed. Reconnecting socket...");
      //socket.connect();
    }
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
            //alertForBack();
            disconnectSocket();
            //Navigator.pop(context, true);
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leadingWidth: 35,
              leading: InkWell(
                  onTap: () {
                    // alertForBack();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  //
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          child: Text(widget.username,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            userStatus == false
                                ? Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.grey,
                                  )
                                : Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: Colors.green,
                                  ),
                            SizedBox(
                              width: 3,
                            ),
                            userStatus == false
                                ? Text(
                                    "offline",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  )
                                : Text(
                                    "online",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                if (blockedByOtherUser == false)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    onSelected: (String value) {},
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                          onTap: () {
                            alertForBlocking();
                          },
                          value: 'true',
                          child: (isBlocked == "false")
                              ? Text('Block this person')
                              : Text("Unblock this person")),
                      PopupMenuItem(
                          onTap: () {
                            deleteConversation();
                          },
                          value: 'true',
                          child: Text("Delete")),
                      PopupMenuItem(
                          onTap: () {
                            report();
                          },
                          value: 'true',
                          child: Text("Report")),
                    ],
                  ),
              ],
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : RefreshIndicator(
                              onRefresh: refresh,
                              child: ListView.builder(
                                  reverse: true,
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
                                          status: messages[index].status,
                                        );
                                      } else {
                                        return MessageWithImage(
                                            path: messages[index].path,
                                            time: messages[index].time,
                                            caption: messages[index].message,
                                            status: messages[index].status);
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
                                          status: messages[index].status,
                                        );
                                      }
                                    }
                                  }),
                            )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          color: Color.fromRGBO(227, 247, 255, 100),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isBlocked == "false"
                                ? Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            filePicker();
                                          },
                                          icon: Icon(Icons
                                              .add_circle_outline_outlined)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      IconButton(
                                          onPressed: () async {
                                            FocusScope.of(context).unfocus();
                                            await Future.delayed(const Duration(
                                                milliseconds: 300));
                                            setState(() {
                                              _showEmoji = !_showEmoji;
                                            });
                                          },
                                          icon: Icon(
                                              Icons.emoji_emotions_outlined)),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _textEditingController,
                                          keyboardType: TextInputType.multiline,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          onTap: () {
                                            if (_showEmoji) {
                                              _showEmoji = !_showEmoji;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              suffixIcon: InkWell(
                                                  onTap: () {
                                                    if (!mounted) return;
                                                    var now = DateTime.now();
                                                    var date = DateFormat(
                                                            'd MMMM y')
                                                        .format(DateTime.now());
                                                    var dateArr =
                                                        date.split(" ");

                                                    print(date);
                                                    var timeToSend =
                                                        ("${dateArr[0]} ${dateArr[1]}, ${now.hour}:${now.minute}");
                                                    sendMessage(
                                                        _textEditingController
                                                            .text,
                                                        timeToSend,
                                                        "",
                                                        false);
                                                    setState(() {
                                                      if (_showEmoji) {
                                                        _showEmoji =
                                                            !_showEmoji;
                                                        _textEditingController
                                                            .clear();
                                                      }
                                                    });

                                                    _scrollController.animateTo(
                                                        0.0,
                                                        duration: Duration(
                                                            milliseconds: 300),
                                                        curve: Curves.bounceIn);
                                                  },
                                                  child: Icon(Icons.send)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  borderSide: BorderSide(
                                                      width: 0,
                                                      style: BorderStyle.none)),
                                              fillColor: Color.fromRGBO(
                                                  247, 247, 255, 100),
                                              filled: true),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        blockedByOtherUser == false
                                            ? Text(
                                                "You have blocked this contact",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Sorry, the other user has blocked you",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                        blockedByOtherUser == false
                                            ? TextButton(
                                                onPressed: () {
                                                  alertForBlocking();
                                                },
                                                child: Text("Undo"))
                                            : Container()
                                      ]),
                          )),
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
            )),
      ),
    );
  }

  void sendMessage(String message, String time, String imagepath,
      bool botReplyOrUser) async {
    //botReplyOrUser is false when user is sending the replies or messages

    var currentFcm = await Helper.getFCMToken();
    print("here wehat it is $currentFcm");
    if (message != "") {
      if (!botReplyOrUser) {
        print("yenhi");
        if (widget.isBot == "false" && !userStatus) {
          NotificationAPI().notificationSend(
              widget.OtherUserId,
              myUserModel!.username,
              message,
              conversationId,
              imagepath,
              widget.isBot,
              myUserModel!.userProfile,
              widget.myId,
              "chat");
          print("han bhai");
        }

        if (userStatus) {
          setMessage("source", message, time, imagepath, "seen");
        } else {
          setMessage("source", message, time, imagepath, "sent");
        }

        _textEditingController.text = "";
        //here in free_message event i am sending fcmtoken of user itself cause if bot is replying it should go to the user itself
        //user sending notification to user is handled differently through notificationSend message
        socket?.emit("free_message", {
          "message": message,
          "time": time,
          "path": imagepath,
          "peerId": widget.OtherUserId,
          "conversationId": conversationId,
          "id": widget.myId,
          "isBot": widget.isBot,
          "limit": limit,
          "fcmTokens": [currentFcm],
          "username": widget.username,
          "myUsername": myUserModel!.username,
          "profilePic": widget.profilePic,
          "whichPage": widget.isItcomingFromMessagePage,
          "interestedGender": myUserModel!
              .interestedGender // true if it coming from messageapage false if its from individualpage
        });

        if (userStatus) {
          limit = await MessagesAPI().updateConversation(
              message,
              time,
              widget.OtherUserId,
              widget.myId,
              conversationId,
              "seen",
              imagepath);

          Provider.of<MessageListProvider>(context, listen: false)
              .updateConversation(conversationId, message, time);
        } else {
          limit = await MessagesAPI().updateConversation(
              message,
              time,
              widget.OtherUserId,
              widget.myId,
              conversationId,
              "sent",
              imagepath);

          Provider.of<MessageListProvider>(context, listen: false)
              .updateConversation(conversationId, message, time);
        }

        if (limit && widget.isBot == "true") {
          print("limit reacher");
          setState(() {
            userStatus = false;
          });
        }
      } else {
        print("in bot era");
        var statusChange = await BotStatusApi()
            .changeBotStatus(myUserModel!.id, widget.OtherUserId, "online");

        if (userStatus) {
          limit = await MessagesAPI().updateConversation(
              message,
              time,
              widget.myId,
              widget.OtherUserId,
              conversationId,
              "seen",
              imagepath);

          if (!mounted) return;

          Provider.of<MessageListProvider>(context, listen: false)
              .updateConversation(conversationId, message, time);
        } else {
          limit = await MessagesAPI().updateConversation(
              message,
              time,
              widget.myId,
              widget.OtherUserId,
              conversationId,
              "sent",
              imagepath);
          if (!mounted) return;
          Provider.of<MessageListProvider>(context, listen: false)
              .updateConversation(conversationId, message, time);
        }
        if (limit) {
          print("limit reacher in bot");
          setState(() {
            userStatus = false;
          });
        }
      }
    }
  }

  void setMessage(
      String s, String msg, String time, String imagepath, String status) {
    print(imagepath);
    if (!mounted) return;
    Provider.of<MessageListProvider>(context, listen: false)
        .updateConversation(conversationId, msg, time);

    MessageModel messageModel = MessageModel(
        type: s, message: msg, time: time, path: imagepath, status: status);
    if (mounted) {
      setState(() {
        messages.insert(0, messageModel);
      });
    }
  }

  void filePicker() async {
    file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (file != null) {
      var bytes = await file!.readAsBytes();

      Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => ImageView(
                path: file!.path,
                onImageSent: onImageSent,
                bytes: bytes,
              )));
    }
  }

  void onImageSent(String path, String time, String caption, bytes) async {
    print("yechla hai");

    print("hey coming here bbbbbbbbbbbbyyyyyyytes");
    print(bytes);

    var currentFcm = await Helper.getFCMToken();
    //final resized = ResizeHelper().resizeJpeg(bytes, 800, 800, 80);

    try {
      final storageRef = FirebaseStorage.instance.ref();

//saving conversationId in storage bucket
      final userBucketRef = storageRef.child(
          "uploads/$conversationId/${DateTime.now().millisecondsSinceEpoch}.jpg");

      await userBucketRef.putFile(File(path));

      String downloadURL = await userBucketRef.getDownloadURL();

      print("photoos hai yaha oe ");
      print(downloadURL);

      if (userStatus) {
        setMessage("source", caption, time, downloadURL, "seen");
      } else {
        setMessage("source", caption, time, downloadURL, "sent");
      }

      socket?.emit("free_message", {
        "message": caption,
        "time": time,
        "path": downloadURL,
        "peerId": widget.OtherUserId,
        "conversationId": conversationId,
        "id": widget.myId,
        "isBot": widget.isBot,
        "limit": limit,
        "fcmTokens": [currentFcm],
        "username": widget.username,
        "myUsername": myUserModel!.username,
        "profilePic": widget.profilePic,
        "whichPage": widget.isItcomingFromMessagePage,
        "interestedGender": myUserModel!.interestedGender
      });

      print("Caption is here" + caption);

      if (userStatus) {
        MessagesAPI().updateConversation(caption, time, widget.OtherUserId,
            widget.myId, conversationId, "seen", downloadURL);
      } else {
        MessagesAPI().updateConversation(caption, time, widget.OtherUserId,
            widget.myId, conversationId, "sent", downloadURL);
      }

      if (widget.isBot == "false" && !userStatus) {
        NotificationAPI().notificationSend(
            widget.OtherUserId,
            myUserModel!.username,
            caption,
            conversationId,
            path,
            widget.isBot,
            myUserModel!.userProfile,
            widget.myId,
            "chat");
      }

      Navigator.of(context).pop();
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void connect() {
    final socketService = SocketService();

    if (socketService.isConnected) {
      socket = socketService.socket;
    } else {
      socketService.connect();
      socket = socketService.socket;
    }

    socket?.connect();
    print("myid is");
    print(socket?.connect());

    socket?.emit("join_conversation", {
      "id": widget.myId,
      "peerId": widget.OtherUserId,
      "isBot": widget.isBot,
      "conversationId": conversationId
    });

    // socket.on("user_status", (data) {

    // });

    socket?.on("free_message", (data) {
      _scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
      print("yhan he aae kuch ");
      print(data);

      setMessage(
          "destination", data["message"], data["time"], data["path"], "sent");

      if (data["botAnswered"] == true) {
        //botreply here
        print("agay hai udhr bhi bit ka answer");
        print(data["message"]);
        sendMessage(data["message"], data["time"], "", true);
      }
    });

    socket?.emit("user_online", {
      "peerId": widget.OtherUserId,
      "conversationId": conversationId,
      "isBot": widget.isBot,
      "userId": widget.myId
    });

    socket?.on("user_status", (data) async {
      final status = data["status"];
      print("other user behaviour is ");
      print(status);

      if (widget.isBot == "false") {
        print("user status 641 line mein haikuc ");
        print(data);
        if (data["status"] == "online") {
          for (var msg in messages) {
            msg.status = "seen";
          }
          if (mounted) {
            setState(() {
              userStatus = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              userStatus = false;
            });
          }
        }
      } else {
        var lim = await MessagesAPI().getlimitInfo(conversationId);
        if (data["status"] == "offline" || lim) {
          for (var msg in messages) {
            msg.status = "seen";
          }
          if (mounted) {
            setState(() {
              limit = lim;
              userStatus = false;
            });
          }
        } else {
          for (var msg in messages) {
            msg.status = "seen";
          }
          if (mounted) {
            setState(() {
              limit = lim;
              userStatus = true;
            });
          }
        }
      }
    });

    socket?.on("block", (data) {
      print("error mate");
      if (mounted) {
        setState(() {
          isBlocked = "true";
          blockedByOtherUser = true;
        });
      }
    });

    socket?.on("unblock", (data) {
      print("error unblock mate");
      if (mounted) {
        setState(() {
          isBlocked = "false";
          blockedByOtherUser = false;
        });
      }
    });
  }

  void getConversation(page) async {
    var isConversationMade =
        await MessagesAPI().getConversationId(widget.OtherUserId, widget.myId);

    conversationId = isConversationMade;

    print("Convos are");
    print(conversationId);
    print(widget.OtherUserId);
    print("minde are");
    print(widget.myId);

    var conversations = await MessagesAPI().getConversationBetweenUsers(
        widget.myId, widget.OtherUserId, page, conversationId);

    if (mounted) {
      setState(() {
        messages.addAll(conversations);
      });
    }

//connect function from main
    //check for limit reached if  bot and userStatus of bot
    // if (widget.isBot == "true") {
    //   var lim = await MessagesAPI().getlimitInfo(conversationId);

    //   print("limit isnfo is ");
    //   print(lim);
    //   if (lim) {
    //     if (!mounted) return;
    //     setState(() {
    //       limit = lim;
    //     });
    //   } else {
    //     if (!mounted) return;
    //     setState(() {
    //       limit = lim;
    //     });
    //   }
    // }

    connect();
    if (!mounted) return;
    Provider.of<MessageListProvider>(context, listen: false)
        .changeStatus(conversationId);

    Provider.of<MessageListProvider>(context, listen: false)
        .getMessageIndicator();
  }

  void disconnectSocket() {
    socket?.emit("user_status", {
      "peerId": widget.OtherUserId,
      "conversationId": conversationId,
      "userId": widget.myId
    });
    //socket.disconnect();
  }

  Future<void> refresh() async {
    page++;
    getConversation(page);
  }

  void blockUser() async {
    var blockCheck = await checkBlocking();

    if (blockCheck == "failed") {
      print("failed vale ch aaya ta hai");
      var block = await BlockUserApi()
          .createBlockItem(widget.myId, widget.OtherUserId, "true");
      if (block != "") {
        setState(() {
          isBlocked = "true";
        });
        //sending other user data so that it can show the blocking thing in async
        socket?.emit("block", {
          "blockingId": widget.myId,
          "blockedId": widget.OtherUserId,
          "isBot": widget.isBot
        });
      }
    } else if (blockCheck == "false") {
      //blocking the item here if it is already present and changing the blockingId;
      print("false vale ch aaya ta hai");
      socket?.emit("block",
          {"blockingId": widget.myId, "blockedId": widget.OtherUserId});
      var block = await BlockUserApi()
          .changeBlocking(widget.myId, widget.OtherUserId, "true");
      if (block != "") {
        setState(() {
          isBlocked = "true";
        });
      }
    } else if (blockCheck == "true") {
      //unblocking the item here
      print("true vale ch aaya ta hai");
      var block = await BlockUserApi()
          .changeBlocking(widget.myId, widget.OtherUserId, "false");
      if (block != "") {
        setState(() {
          isBlocked = "false";
        });
        //socket unblocking for real time
        socket?.emit("unblock", {
          "blockingId": widget.myId,
          "blockedId": widget.OtherUserId,
          "isBot": widget.isBot
        });

        //sending other user data so that it can show the blocking thing in async
        // socket.emit("block",
        //     {"blockingId": widget.myId, "blockedId": widget.OtherUserId});
      }
    }
  }

  Future<String> checkBlocking() async {
    var block =
        await BlockUserApi().checkBlocking(widget.myId, widget.OtherUserId);
    if (block.result == "failed") {
      return "failed";
    } else {
      return block.result;
    }
  }

  void alertForBlocking() {
    Widget okButton = TextButton(
        onPressed: () {
          print("kmd");
          isBlocked == "false" ? blockUser() : unblock();
          Navigator.of(context).pop();
        },
        child: const Text("ok"));

    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text("Cancel"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm"),
            content: isBlocked == "false"
                ? Text("Are you sure you want to block this person")
                : Text("Are you sure you want to unblock this person"),
            actions: [cancelButton, okButton],
          );
        });
  }

  Future<String> checkBlockingAtFirst() async {
    var blockBool =
        await BlockUserApi().checkBlocking(widget.myId, widget.OtherUserId);

    if (blockBool.result == "failed") {
      setState(() {
        isBlocked = "false";
      });
      return "failed";
    } else if (blockBool.result == "false") {
      print("ssssssssssssssssssssssssssssssssssssssssss");
      setState(() {
        isBlocked = "false";
      });
      return blockBool.result;
    } else {
      print("iske andar ddddddddddddddddddddddddddddddddddddddddddddddd");
      if (blockBool.blockingId == widget.myId) {
        setState(() {
          blockedByOtherUser = false;
        });
      } else {
        setState(() {
          blockedByOtherUser = true;
        });
      }
      setState(() {
        isBlocked = "true";
      });
      return blockBool.result;
    }
  }

  void unblock() async {
    var block = await BlockUserApi()
        .changeBlocking(widget.myId, widget.OtherUserId, "false");
    if (block != "") {
      print("inhere");

      setState(() {
        isBlocked = "false";
      });
      socket?.emit("unblock",
          {"blockingId": widget.myId, "blockedId": widget.OtherUserId});
    }
  }

  void deleteConversation() {
    if (!mounted) return;
    Widget okButton = TextButton(
        onPressed: () async {
          var convo = await MessagesAPI()
              .deleteConversation(widget.OtherUserId, widget.myId);
          if (!mounted) return;
          try {
            Provider.of<MessageListProvider>(context, listen: false)
                .deleteConversation(widget.OtherUserId);
          } catch (e, s) {
            debugPrint("⚠️ Provider not available: $e");
            FirebaseCrashlytics.instance.recordError(e, s);
          }
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: Text("Ok"));

    Widget cancelButton = TextButton(
        onPressed: () {
          if (!mounted) return;
          Navigator.of(context).pop();
        },
        child: Text("Cancel"));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete this chat?"),
            content: Text("Are you sure you want to delete this conversation?"),
            actions: [cancelButton, okButton],
          );
        });
  }

  void report() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Wrap(
              children: [
                Center(
                    child: Text(
                  "Report User",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: 16,
                ),
                buildReportTile(widget.OtherUserId, "Harassment / Bullying"),
                buildReportTile(widget.OtherUserId, "Hate Speech"),
                buildReportTile(widget.OtherUserId, "Sexual / Inappropriate"),
                buildReportTile(widget.OtherUserId, "Spam / Scam"),
                buildReportTile(widget.OtherUserId, "Fake Profile"),
                buildReportTile(widget.OtherUserId, "Other"),
              ],
            ),
          );
        });
  }

  Widget buildReportTile(String otherUserId, String s) {
    return ListTile(
      leading: Icon(
        Icons.flag,
        color: Colors.red,
      ),
      title: Text(s),
      onTap: () async {
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Report submitted for a reason $s")));

        //add to db
        await ReportUserApi()
            .reportUser(widget.myId, widget.OtherUserId, s, conversationId);
        var block = await BlockUserApi()
            .createBlockItem(widget.myId, widget.OtherUserId, "true");
        if (block != null) {
          setState(() {
            isBlocked = "true";
          });
        }
      },
    );
  }
}
