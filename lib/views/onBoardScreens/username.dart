import 'dart:math';

import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/notification_service.dart';
import 'package:match5/questions.dart';
import 'package:match5/utils/choose_avatar.dart';
import 'package:match5/views/home_screen.dart';
import 'package:provider/provider.dart';

//name of the file was Username before now it changed to choose_avattar but not the class name
class Username extends StatefulWidget {
  const Username(
      {required this.id,
      required this.gender,
      required this.interestedGender,
      super.key});

  final String id;
  final String gender;
  final String interestedGender;

  @override
  State<Username> createState() => _UsernameState();
}

class _UsernameState extends State<Username> {
  bool isSelected = false;
  TextEditingController username = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(225, 225, 225, 1)),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/login_bg_last_again.png",
            fit: BoxFit.cover,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 32,
                    )),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    "Enter Username",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                    child: TextField(
                  onTap: () {
                    setState(() {
                      isSelected = true;
                    });
                  },
                  controller: username,
                  decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 127, 127, 127)),
                      enabledBorder: OutlineInputBorder(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                )),
                SizedBox(
                  height: 16,
                ),
                // SizedBox(
                //   height: 550,
                //   child: GridView.builder(
                //       itemCount: widget.listOfImges.length,
                //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //           crossAxisCount: 4),
                //       itemBuilder: (context, index) {
                //         return GestureDetector(
                //             onTap: () {
                //               setState(() {
                //                 isSelected = true;
                //                 selectedIndex = index;
                //               });
                //             },
                //             child: Stack(
                //               children: [
                //                 ChooseAvatar(
                //                   avatarName: widget.listOfImges[index],
                //                 ),
                //                 (isSelected == true && selectedIndex == index)
                //                     ? Positioned.fill(
                //                         child: ClipOval(
                //                           child: Image.asset(
                //                             "assets/selected_profile_pic.png",
                //                             fit: BoxFit.fill,
                //                             height: 80,
                //                             width: 80,
                //                           ),
                //                         ),
                //                       )
                //                     : SizedBox(
                //                         height: 0,
                //                       )
                //               ],
                //             ));
                //       }),
                // )
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  if (!mounted) return;
                  final userProvider =
                      Provider.of<UserProvider>(context, listen: false);

                  var random = Random();
                  var picnmbr = random.nextInt(27) + 1;
                  var picname = "pic_${picnmbr}.png";
                  print("picnames are here $picname");

                  if (!username.text.trim().isEmpty) {
                    var res = await OnBoardConnection()
                        .updateUser(
                            widget.id,
                            widget.gender,
                            widget.interestedGender,
                            username.text.trim(),
                            picname,
                            "")
                        .then((onValue) async {
                      print("then andar");
                      if (onValue.result == 200) {
                        print("200 ayaa");

                        final userData = onValue.user;
                        if (userData == null) {
                          debugPrint(
                              "⚠️ onValue.user is null — skipping setUser");
                        } else {
                          userProvider.setUser(userData);
                        }

                        // await NotificationService.askForPermissions();
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (builder) => HomeScreen(
                                    user: onValue.user,
                                  )),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Network Error"),
                        ));
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please Enter username"),
                    ));
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 20,
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                ),
              ),
            )
        ],
      ),
    );
  }
}
