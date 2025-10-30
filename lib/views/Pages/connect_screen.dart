import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:match5/Database/api/bot_status_api.dart';
import 'package:match5/Database/api/bot_user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Services/socket_service.dart';
import 'package:match5/const.dart';
import 'package:match5/questions.dart';
import 'package:match5/views/Pages/individual_chat_page.dart';
import 'package:match5/views/onBoardScreens/username.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen(
      {required this.typeOfGame,
      super.key,
      this.accent = const Color(0xFFFFDC00)});

  final String typeOfGame;

  final Color accent;

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late IO.Socket socket;
  bool isNavigateForward = false;
  Timer? _waitTime;
  var botUser = "";
  late AnimationController _ctrl;
  late Animation<double> _glow;
  UserModel? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    user = Provider.of<UserProvider>(context, listen: false).user;
    final socketService = SocketService();
    socketService.connect();
    socket = socketService.socket;
    connect();
    print("in here matre");
    startWaitingForUser();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _glow = Tween<double>(begin: 10, end: 28).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    onCancelWaiting();
    if (!isNavigateForward) {
      print("kardo scoket cancel");
      socket.disconnect();
    }
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.accent.withOpacity(0.12);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Title + subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "Finding your match…",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Hang tight, someone is joining soon 💬",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Ripple + Glow + Avatar
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value; // 0..1
                return SizedBox(
                  height: 240,
                  width: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 3 ripples phased out
                      _RippleCircle(radius: _wave(80, t, 0.00), color: bg),
                      _RippleCircle(radius: _wave(80, t, 0.33), color: bg),
                      _RippleCircle(radius: _wave(80, t, 0.66), color: bg),
                      // Glow + avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withOpacity(0.55),
                              blurRadius: _glow.value,
                              spreadRadius: _glow.value * 0.7,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                              "$BASE_URL/profile_pics/${user!.userProfile}"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void connect() {
    socket.emit("matching", {
      "id": user?.id,
      "username": user!.username,
      "userProfile": user!.userProfile
    });
    socket.connect();

    socket.on("chat_start", (data) {
      print(data);
      if (!mounted) return;

      isNavigateForward = true;

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (builder) => IndividualChatPage(
              socket: socket,
              username: data["name"],
              myId: user!.id,
              partnerId: data["partnerId"],
              profilePic: data["userProfile"],
              role: data["role"],
              isBot: false)));
    });

    socket.on("bot_chat_start", (data) async {
      if (mounted) {
        setState(() {
          isNavigateForward = true;
        });
      }
      if (!mounted) return;

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (builder) => IndividualChatPage(
                socket: socket,
                username: data["name"],
                myId: user!.id,
                partnerId: botUser,
                profilePic: data["userProfile"],
                role: data["role"],
                isBot: true,
              )));
    });

    socket.onConnect((data) {
      print("connected is coming or not");
    });

    print("hi");
    print(socket.connected);
  }

  void startWaitingForUser() {
    _waitTime?.cancel();

    _waitTime = Timer(Duration(seconds: 5), () {
      connectToBot();
    });
  }

  void onCancelWaiting() {
    _waitTime?.cancel();
  }

  void connectToBot() async {
    var randomIndex = 0;
    var botUserComing = await BotUserAPI().getBots(user!.id, user!.gender);

    if (botUserComing.isNotEmpty) {
      randomIndex = Random().nextInt(botUserComing.length);
      print("Ranodm $randomIndex");

      print("botusers is here botUserComing");
      print(botUserComing);
      if (!mounted) return;
      setState(() {
        botUser = botUserComing[randomIndex]["_id"];
      });

      print("checking conect screen botstatus creation ${user!.id}");

      //emitting that the bot chat has initialized
      socket.emit("bot_chat_initializing", {
        "name": botUserComing[randomIndex]["username"],
        "botId": botUserComing[randomIndex]["_id"],
        "userProfile": botUserComing[randomIndex]["userProfile"],
      });
    } else {
      //create a new bot here
      var userName = "UG";
      if (user!.interestedGender == "Female") {
        print("femaee");
        userName = generateRandomNameFemale();
      } else if (user!.interestedGender == "Male") {
        print("maleee");
        userName = generateRandomNameMale();
      } else {
        var random = Random();
        print("else mein");
        var topick = random.nextBool();
        if (topick) {
          print("maleee random $topick");
          userName = generateRandomNameFemale();
        } else {
          print("female random $topick");
          userName = generateRandomNameMale();
        }
      }

      print("checking conect screen botstatus creation  at else${user!.id}");
      var newBot = await BotUserAPI()
          .createBot(userName, user!.interestedGender, user!.gender);
      if (!mounted) return;
      if (newBot == null || newBot["_id"] == null) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          return;
        }
      }
      setState(() {
        botUser = newBot["_id"];
      });

//creating botstatus here

      socket.emit("bot_chat_initializing", {
        "name": newBot["username"],
        "botId": newBot["_id"],
        "userProfile": newBot["userProfile"],
      });
    }
  }

  double _wave(double maxR, double t, double phase) {
    // shift/loop with phase; 0..1
    final v = (t + phase) % 1.0;
    // ease out so it slows as it grows
    final eased = Curves.easeOut.transform(v);
    // start small to avoid popping
    return 30 + eased * maxR;
  }
}

class _RippleCircle extends StatelessWidget {
  final double radius;
  final Color color;
  const _RippleCircle({required this.radius, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
