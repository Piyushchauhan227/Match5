import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/notification_api.dart';
import 'package:match5/Services/auth.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Services/notification_service.dart';

import 'package:match5/views/home_screen.dart';
import 'package:match5/views/onBoardScreens/first_questionaire.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/onBoardScreens/loginWithMatch.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _auth = AuthService();
  var userCredentials;
  bool toNextScreen = false;
  bool progressIndicator = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("inhere");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              "assets/login_bg_last_again.png",
              fit: BoxFit.cover,
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          child:
                              Image(image: AssetImage("assets/login_icon.png")),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Text(
                          "Match5",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Text("Find your Match in 5",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 8,
                        ),
                        // Text("in 5",
                        //     style: TextStyle(
                        //         fontSize: 26, fontWeight: FontWeight.bold)),
                        Text("Quick, Fun, Real connections.",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            loginWithGoogle();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 10,
                                color: Colors.transparent,
                                child: Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width - 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: progressIndicator == true
                                      ? const Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator()
                                          ],
                                        )
                                      : Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CircleAvatar(
                                                radius: 30,
                                                child: Image.asset(
                                                    "assets/google_icon.png"),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Text(
                                              "Continue with Google",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: "Lato",
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        InkWell(
                          onTap: () {
                            loginWithMatch();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Card(
                                elevation: 10,
                                color: Colors.transparent,
                                child: Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width - 50,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipOval(
                                          child: Image.asset("assets/icon.png"),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 22,
                                      ),
                                      const Text(
                                        "Continue with Match5",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "By registering, you accept our Terms and Conditions of Use and our Privacy Policy "),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void loginWithGoogle() async {
    var dateformat = DateFormat("d MMMM y").format(DateTime.now());
    var dateArr = dateformat.split(" ");
    var timeToSend =
        ("${dateArr[0]} ${dateArr[1]}, ${DateTime.now().hour}:${DateTime.now().minute}");
    setState(() {
      progressIndicator = true;
    });
    print("user aagya osto upr");
    userCredentials = await _auth.signInWithGoogle();
    if (userCredentials == null) {
      if (!mounted) return;
      setState(() {
        progressIndicator = false;
      });
    }

    print("user aagya hai but $userCredentials");

    if (userCredentials != null) {
      var newUser = userCredentials.additionalUserInfo.isNewUser;
      var name = userCredentials.user.displayName;
      var email = userCredentials.additionalUserInfo.profile["email"];

      if (newUser) {
        var res = await OnBoardConnection().signupInMongo(name, email);
        print("new everythinf");
        print(res.user);
        if (res.result == 200) {
          await Helper.saveLoginInfo();
          await Helper.saveLoginId(res.user.id);
          if (!mounted) return;
          setState(() {
            progressIndicator = false;
          });

          //add welcome notification
          await NotificationAPI().createUserNotification(
              res.user.id,
              "Welcome to Match5!",
              "You’re all set. Start matching and spark real connections ",
              "welcome",
              timeToSend);

          await NotificationAPI().createUserNotification(
              res.user.id,
              "5 Bonus Fires just for joining!",
              "Use fires to start meaningful conversations 🔥 Let the connections begin.",
              "welcome",
              timeToSend);

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (builder) =>
                  Firstquestionaire(idIncoming: res.user.id)));
        } else {
          print("not working");
        }
      } else {
        print("res");
        var res = await OnBoardConnection().loginInMongo(email);

        print(res.user.id);
        if (res.result == 200) {
          await Helper.saveLoginInfo();
          await Helper.saveLoginId(res.user.id);
          if (!mounted) return;
          setState(() {
            progressIndicator = false;
          });
          print("idhr");

          await NotificationAPI().createUserNotification(
              res.user.id,
              "Welcome to Match5!",
              "You’re all set. Start matching and spark real connections ",
              "welcome",
              timeToSend);

          await NotificationAPI().createUserNotification(
              res.user.id,
              "5 Bonus Fires just for joining!",
              "Use fires to start meaningful conversations 🔥 Let the connections begin.",
              "welcome",
              timeToSend);

          Provider.of<UserProvider>(context, listen: false).setUser(res.user);

          await NotificationService.init();

          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (builder) => HomeScreen(user: res.user)));
        } else {
          //somehow data got deleted in mongo but present in firebase that is why signup again
          var res = await OnBoardConnection().signupInMongo(name, email);
          print(res.user);
          if (res.result == 200) {
            await Helper.saveLoginInfo();
            await Helper.saveLoginId(res.user.id);
            setState(() {
              progressIndicator = false;
            });

            await NotificationAPI().createUserNotification(
                res.user.id,
                "Welcome to Match5!",
                "You’re all set. Start matching and spark real connections ",
                "welcome",
                timeToSend);

            await NotificationAPI().createUserNotification(
                res.user.id,
                "5 Bonus Fires just for joining!",
                "Use fires to start meaningful conversations 🔥 Let the connections begin.",
                "welcome",
                timeToSend);

            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (builder) =>
                    Firstquestionaire(idIncoming: res.user.id)));
            print("not working neeche");
          }
        }
      }
    }
  }

  void loginWithMatch() {
    if (!mounted) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginWithMatch()));
  }
}
