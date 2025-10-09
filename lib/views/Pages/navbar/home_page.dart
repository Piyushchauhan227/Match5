import 'package:flutter/material.dart';
import 'package:match5/Database/api/messages_api.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/message_list_provider.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/const.dart';
import 'package:match5/utils/login_helper.dart';
import 'package:match5/views/Pages/user_profile.dart';
import 'package:match5/views/Pages/connect_screen.dart';
import 'package:match5/Models/main_screen_model.dart';
import 'package:match5/utils/main_screen_card.dart';
import 'package:match5/views/Pages/wallet_page.dart';
import 'package:provider/provider.dart';
import 'package:match5/Provider/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  String? fcmToken = "";
  String? deviceId = "";
  AdService adService = AdService();

  @override
  void initState() {
    // getUserDetails();
    //getFCMTokenDetails();

    super.initState();

    loadRewardAd();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: true).user;

    return Scaffold(
      body: user == null
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
                      onPressed: () async {
                        var provider =
                            Provider.of<UserProvider>(context, listen: false);
                        var fires = provider.user!.coins;

                        if (!mounted) return;
                        print("fires are checking $fires");
                        if (fires <= 0) {
                          showNoFirePopup();
                        } else {
                          print("do bari");
                          provider.decreaseFires();
                          await OnBoardConnection()
                              .updateUserFires(-1, provider.user!.id);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (builder) => ConnectScreen(
                                    typeOfGame: title,
                                  )));
                        }
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

  // Future<void> getDataFromDB(UserModel user) async {
  //   //get id from shared prefs which is in Helper class
  //   var id = await Helper.getLoginId();
  //   print("herege");

  //   //get User from api
  //   var res = await OnBoardConnection().gettingUserDetails(id);
  //   var userNow = UserModel(
  //       id: id,
  //       name: res.user.name,
  //       email: res.user.email,
  //       gender: res.user.gender,
  //       interestedGender: res.user.interestedGender,
  //       username: res.user.username,
  //       fcmToken: res.user.fcmToken,
  //       coins: res.user.coins,
  //       userProfile: res.user.userProfile,
  //       about: res.user.about);
  //   print(res.user.name);
  //   print("Dd");
  //   print(res.user.fcmToken);
  //   setState(() {
  //     user = userNow;
  //   });

  //   //saving data localy;
  //   Helper.saveHomePageUser(userNow);
  // }

  void showNoFirePopup() {
    if (!mounted) return;
    Navigator.of(context).pop();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(20)),
            elevation: 10,
            backgroundColor: const Color(0xFFFFF59D),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        "assets/fire.png",
                        width: 40,
                      )),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "Oops! You need more Fires",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You don't have enough fires.\nWatch an ad to earn fires.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _pulsePlay(
                    adService: adService,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => WalletPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                      elevation: 8,
                      shadowColor: Colors.deepOrangeAccent,
                    ),
                    child: const Text(
                      "Buy more Fires",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void loadRewardAd() async {
    adService.loadRewardedAd();
  }
}

class _pulsePlay extends StatefulWidget {
  const _pulsePlay({required this.adService, super.key});

  final AdService adService;

  @override
  State<_pulsePlay> createState() => __pulsePlayState();
}

class __pulsePlayState extends State<_pulsePlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  UserProvider? user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    user = Provider.of<UserProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          elevation: 10,
          shadowColor: Colors.deepOrangeAccent,
        ),
        onPressed: () {
          //Navigator.pop(context);
          // TODO: Show rewarded ad
          widget.adService.showRewardedAd(onUserReward: () {
            print("loaded and showing now");
            addToDb();
          }, rewardStillLoading: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return const Dialog(
                      backgroundColor: Colors.transparent,
                      child: Center(child: CircularProgressIndicator()));
                });
            while (widget.adService.isRewardedLoaded) {
              await Future.delayed(const Duration(milliseconds: 200));
            }
            if (mounted) Navigator.of(context).pop();
            if (widget.adService.rewardedAd != null) {
              widget.adService.showRewardedAd(); // 👈 now we can show
              widget.adService.rewardedAd = null;
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No ads available right now")),
              );
            }
          });
        },
        icon: const Icon(
          Icons.play_circle_fill,
          color: Colors.white,
          size: 26,
        ),
        label: const Text(
          "Watch an Ad",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void addToDb() async {
    await OnBoardConnection().updateUserFires(5, user!.user!.id);
    user!.increaseFires();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        title: Text("Success 🎉"),
        content: Text("You earned 5 free Fires!"),
      ),
    );

    // Auto close after 1.5 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }
}
