import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/const.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/Pages/user_profile.dart';
import 'package:match5/views/Pages/connect_screen.dart';
import 'package:match5/Models/main_screen_model.dart';
import 'package:match5/utils/main_screen_card.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.user, super.key});

  final UserModel user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<MainScreenModel> mainScreenList = [
    MainScreenModel(
        imageUrl: "assets/truth_rush_bg.png",
        title: "Truth Rush",
        details:
            "Connect with someone new and take turns answering 5 fun questions. If you both feel the vibe, tap 'Match' and keep the convo going."),
    MainScreenModel(
        imageUrl: "assets/icebreaker_sparks_bg.png",
        title: "Icebreaker Sparks",
        details:
            "Dare to get real. 5 flirty questions. If the tension’s mutual, tap match."),
    // MainScreenModel(
    //     imageUrl: "assets/extreme_main.jpg",
    //     title: "Extreme",
    //     details:
    //         "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s"),
  ];

  UserModel? userhere;
  String? fcmToken = "";
  String? deviceId = "";

  @override
  void initState() {
    // getUserDetails();
    //getFCMTokenDetails();
    userhere = widget.user;

    super.initState();
    print(userhere);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: true).user;
    print("welcome ${userhere!.username}");

    return Scaffold(
      body: userhere == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color(0xFFFFDC00), // your main yellow
                Color(0xFFFFE766),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 18, left: 20, right: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Match5",
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                              Text(
                                "Hey, ${user!.username}",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // _navigateAndDisplaySelection(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                          user: user,
                                        )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding:
                                  EdgeInsets.zero, // Remove internal padding
                              fixedSize:
                                  Size(55, 55), // Size of the circular button
                              elevation: 10,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                '$BASE_URL/profile_pics/${user.userProfile}',
                                fit: BoxFit.cover,
                                width: 55,
                                height: 55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.only(
                            top: 20, left: 0, right: 0, bottom: 0),
                        color: Colors.white,
                        elevation: 20,
                        shape: const Border(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Center(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Pick any Category",
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text(
                                        "5 Questions, 1 match, Endless vibes",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: ListView.builder(
                                      itemCount: 2,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            if (!mounted) return;
                                            ruleDialog(
                                                mainScreenList[index].title);
                                          },
                                          child: MainScreenCard(
                                            imageString:
                                                mainScreenList[index].imageUrl,
                                            title: mainScreenList[index].title,
                                            details:
                                                mainScreenList[index].details,
                                          ),
                                        );
                                      }))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
    );
  }

  void ruleDialog(String title) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 5,
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
            child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rules",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "You Choose $title",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please stay within your limits and be respectful. Avoid giving inappropriate or offensive answers. This helps keep the experience fun and safe for everyone. Thank you!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => ConnectScreen(
                                  typeOfGame: title,
                                )));
                      },
                      child: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        child: const Text(
                          'Lets Play',
                          style: TextStyle(color: Colors.white, fontSize: 13.0),
                        ),
                      ),
                    )
                  ],
                )),
          );
        });
  }

  // Future<void> _navigateAndDisplaySelection(BuildContext context) async {
  //   // Navigator.push returns a Future that completes after calling
  //   // Navigator.pop on the Selection Screen.
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => UserProfile(user: userhere)),
  //   );

  //   // When a BuildContext is used from a StatefulWidget, the mounted property
  //   // must be checked after an asynchronous gap.
  //   if (!context.mounted) return;

  //   // After the Selection Screen returns a result, hide any previous snackbars
  //   // and show the new result.
  //   print(result);
  //   if (result == true) {
  //     getDataFromDB(userhere!);
  //   }
  // }

  Future<void> getDataFromDB(UserModel user) async {
    //get id from shared prefs which is in Helper class
    var id = await Helper.getLoginId();
    print("herege");

    //get User from api
    var res = await OnBoardConnection().gettingUserDetails(id);
    var userNow = UserModel(
        id: id,
        name: res.user.name,
        email: res.user.email,
        gender: res.user.gender,
        interestedGender: res.user.interestedGender,
        username: res.user.username,
        fcmToken: res.user.fcmToken,
        coins: res.user.coins,
        userProfile: res.user.userProfile,
        about: res.user.about);
    print(res.user.name);
    print("Dd");
    print(res.user.fcmToken);
    setState(() {
      userhere = userNow;
    });

    //saving data localy;
    Helper.saveHomePageUser(userNow);
  }
}
