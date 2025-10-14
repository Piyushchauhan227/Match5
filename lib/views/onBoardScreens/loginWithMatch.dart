import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/notification_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/auth.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/home_screen.dart';
import 'package:match5/views/onBoardScreens/first_questionaire.dart';
import 'package:match5/views/onBoardScreens/signup_with_match.dart';
import 'package:provider/provider.dart';

class LoginWithMatch extends StatefulWidget {
  const LoginWithMatch({super.key});

  @override
  State<LoginWithMatch> createState() => _LoginWithMatchState();
}

class _LoginWithMatchState extends State<LoginWithMatch> {
  bool obscureText = true;
  TextEditingController email = TextEditingController();
  TextEditingController pwd = TextEditingController();
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/login_bg_last_again.png"),
                    fit: BoxFit.cover)),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 32),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.arrow_back)),
                      SizedBox(
                        width: 24,
                      ),
                      Text(
                        "Log in",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email"),
                        SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 127, 127, 127)),
                              enabledBorder: OutlineInputBorder(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password"),
                        SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: pwd,
                          obscureText: obscureText,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    print("ttr");
                                    obscureText = !obscureText; // 👈 toggle
                                  });
                                },
                                icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              labelText: "password",
                              labelStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 127, 127, 127)),
                              enabledBorder: OutlineInputBorder(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        Align(
                          alignment: AlignmentGeometry.bottomRight,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isClicked = true;
                                });
                                loginWithMatch();
                              },
                              style: TextButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                backgroundColor:
                                    Colors.blue, // Background color
                                foregroundColor: Colors.white, // Text color
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Rounded corners
                                ),
                              ),
                              child: isClicked
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text("Login")),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => SignupWithMatch()));
                            },
                            child: Text("Don't have an account? Sign up")),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loginWithMatch() async {
    var dateformat = DateFormat("d MMMM y").format(DateTime.now());
    var dateArr = dateformat.split(" ");
    var timeToSend =
        ("${dateArr[0]} ${dateArr[1]}, ${DateTime.now().hour}:${DateTime.now().minute}");

    if (email.text.trim().isEmpty || pwd.text.trim().isEmpty) {
      setState(() {
        isClicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all the fields")));
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text.trim())) {
      setState(() {
        isClicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Email format")));
    } else {
      final cred = await AuthService()
          .loginWithMatch(email.text.trim(), pwd.text.trim(), context);
      print("credentials aaye hai $cred");

      if (cred != null) {
        var res = await OnBoardConnection().loginInMongo(email.text.trim());

        print(res.user.id);
        if (res.result == 200) {
          await Helper.saveLoginInfo();
          await Helper.saveLoginId(res.user.id);

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
          if (!mounted) return;
          Provider.of<UserProvider>(context, listen: false).setUser(res.user);

          await NotificationService.init();
          // await NotificationService.askForPermissions();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (builder) => HomeScreen(user: res.user)),
              (Route<dynamic> route) => false);
        } else {
          //somehow data got deleted in mongo but present in firebase that is why signup again
          var name = cred.user!.displayName;
          var res =
              await OnBoardConnection().signupInMongo(name, email.text.trim());
          print(res.user);
          if (res.result == 200) {
            await Helper.saveLoginInfo();
            await Helper.saveLoginId(res.user.id);

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

            await NotificationService.init();
            // await NotificationService.askForPermissions();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (builder) =>
                        Firstquestionaire(idIncoming: res.user.id)),
                (Route<dynamic> route) => false);
            print("not working neeche");
          }
        }
      } else {
        setState(() {
          isClicked = false;
        });
      }
    }
  }
}
