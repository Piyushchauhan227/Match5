import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:match5/Database/api/notification_api.dart' show NotificationAPI;
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Services/auth.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/onBoardScreens/first_questionaire.dart';

class SignupWithMatch extends StatefulWidget {
  const SignupWithMatch({super.key});

  @override
  State<SignupWithMatch> createState() => _SignupWithMatchState();
}

class _SignupWithMatchState extends State<SignupWithMatch> {
  bool obscureText = true;
  bool confirmTextObscure = true;
  TextEditingController email = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  bool clicked = false;

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
                        "Sign up",
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
                        Text("Name"),
                        SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: name,
                          decoration: InputDecoration(
                              labelText: "Name",
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
                          controller: password,
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(" Confirm Password"),
                        SizedBox(
                          height: 8,
                        ),
                        TextField(
                          controller: confirmPassword,
                          obscureText: confirmTextObscure,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    print("ttr");
                                    confirmTextObscure =
                                        !confirmTextObscure; // 👈 toggle
                                  });
                                },
                                icon: Icon(
                                  confirmTextObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 127, 127, 127)),
                              enabledBorder: OutlineInputBorder(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Align(
                      alignment: AlignmentGeometry.bottomRight,
                      child: TextButton(
                          onPressed: () {
                            signUpWithMatch();
                            setState(() {
                              clicked = true;
                            });
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.blue, // Background color
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: clicked
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text("Sign up")),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void signUpWithMatch() async {
    var dateformat = DateFormat("d MMMM y").format(DateTime.now());
    var dateArr = dateformat.split(" ");
    var timeToSend =
        ("${dateArr[0]} ${dateArr[1]}, ${DateTime.now().hour}:${DateTime.now().minute}");
    if (email.text.trim().isEmpty ||
        name.text.trim().isEmpty ||
        password.text.trim().isEmpty ||
        confirmPassword.text.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        clicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all the fields")));
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text.trim())) {
      if (!mounted) return;
      setState(() {
        clicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid Email format")));
    } else if (password.text.trim() != confirmPassword.text.trim()) {
      if (!mounted) return;
      setState(() {
        clicked = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Passwords dont match")));
    } else if (password.text.trim().length < 6) {
      if (!mounted) return;
      setState(() {
        clicked = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password should be more than 6 characters")));
    } else {
      final cred = await AuthService().signUpWithMatch(
          email.text.trim(), password.text.trim(), context, name.text.trim());

      if (cred != null) {
        var res = await OnBoardConnection()
            .signupInMongo(name.text.trim(), email.text.trim());
        print("new everythinf");
        print(res.user);
        if (res.result == 200) {
          await Helper.saveLoginInfo();
          await Helper.saveLoginId(res.user.id);

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

          await NotificationService.init();

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (builder) =>
                      Firstquestionaire(idIncoming: res.user.id)),
              (Route<dynamic> route) => false);
        } else {
          print("not working");
        }
      } else {
        setState(() {
          clicked = false;
        });
      }
    }
  }
}
