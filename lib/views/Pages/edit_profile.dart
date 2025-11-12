import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Services/auth.dart';
import 'package:match5/views/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EditProfile extends StatefulWidget {
  const EditProfile({required this.user, super.key});

  final UserModel? user;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String genderValue = 'Male';
  String interestedGenderValue = "Male";
  List<String> genderList = ["Male", "Female", "Non-Binary"];
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController aboutTextEditingController =
      TextEditingController();

  @override
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    genderValue = widget.user!.gender;
    interestedGenderValue = widget.user!.interestedGender;
    textEditingController.text = widget.user!.username;
    aboutTextEditingController.text = widget.user!.about;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton(
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      value: "Delete Account",
                      child: TextButton.icon(
                        onPressed: () {
                          showDialogForDeletAccount();
                        },
                        label: Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.red),
                        ),
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ))
                ];
              })
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name"),
                    SizedBox(
                      height: 4,
                    ),
                    TextField(
                      controller: textEditingController,
                      decoration: InputDecoration(
                          labelText: widget.user!.username,
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(255, 127, 127, 127)),
                          enabledBorder: OutlineInputBorder(),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Email"),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.user!.email,
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Gender"),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton(
                            value: genderValue,
                            icon: const SizedBox.shrink(),
                            items: genderList.map((String text) {
                              return DropdownMenuItem(
                                child: Text(text),
                                value: text,
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                genderValue = newValue!;
                              });
                            })),
                    SizedBox(
                      height: 16,
                    ),
                    Text("Interested Gender"),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton(
                          value: interestedGenderValue,
                          icon: const SizedBox.shrink(),
                          items: genderList.map((String text) {
                            return DropdownMenuItem(
                                value: text, child: Text(text));
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              interestedGenderValue = value!;
                            });
                          }),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Text("About"),
                    SizedBox(
                      height: 4,
                    ),
                    TextField(
                      controller: aboutTextEditingController,
                      maxLines: 5, // You can increase this for more height
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: 'Type about yourself...',
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            tz.initializeTimeZones();
                            final localTz = tz.local.name;
                            //print(textEditingController.text);
                            if ((widget.user!.username !=
                                        textEditingController.text &&
                                    textEditingController.text
                                        .trim()
                                        .isNotEmpty) ||
                                widget.user!.gender != genderValue ||
                                widget.user!.interestedGender !=
                                    interestedGenderValue ||
                                widget.user!.about !=
                                    aboutTextEditingController.text) {
                              //update here

                              var res = await OnBoardConnection().updateUser(
                                  widget.user!.id,
                                  genderValue,
                                  interestedGenderValue,
                                  textEditingController.text,
                                  widget.user!.userProfile,
                                  aboutTextEditingController.text,
                                  localTz.toString());

                              if (res.result == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Profile updated"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );

                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .updateUser(res.user);

                                Navigator.of(context).pop();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Please add correct details"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: Text("Save"),
                        ),
                        TextButton(
                          onPressed: () {
                            if (!mounted) return;
                            showDialogForLogout();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red, // Background color
                            foregroundColor: Colors.white, // Text color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: Text("Log out"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogForLogout() {
    Widget ok = ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: StadiumBorder(),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        onPressed: () async {
          //delet all the users info here from shareprefs like tokens,userinfo,delete from mongo db then firebase storage

          //delete all the shared preferences
          var prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          signOutFromFirebase();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (Route<dynamic> route) => false,
          );
        },
        child: Text("okay"));

    Widget cancel = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("cancel"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text("Do you really want to Log out?"),
            // actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [cancel, ok],
          );
        });
  }

  void showDialogForDeletAccount() {
    Widget ok = ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: StadiumBorder(),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
        onPressed: () async {
          //delet all the users info here from shareprefs like tokens,userinfo,delete from mongo db then firebase storage

          //delete all the shared preferences
          var prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          signOutFromFirebase();

          deleteUserAccount();

          if (Navigator.canPop(context)) ;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (Route<dynamic> route) => false,
          );
        },
        child: Text("Delete Account"));

    Widget cancel = ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("Cancel"));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Delete Account",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'This action is permanent and cannot be undone.\n\n'
              'All your data, chats, and profile information will be permanently deleted.',
            ),
            // actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [cancel, ok],
          );
        });
  }

  void signOutFromFirebase() async {
    await FirebaseMessaging.instance.deleteToken();
    await OnBoardConnection().deletFcmTokens(widget.user!.id);
    await AuthService().signOutFromGoogle();
  }

  void deleteUserAccount() async {
    print("chki Delete");
    await OnBoardConnection().deleteUserAccount(widget.user!.id);
  }
}
