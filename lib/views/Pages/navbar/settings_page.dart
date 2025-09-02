import 'package:flutter/material.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/views/Pages/blocked_users.dart';
import 'package:match5/views/Pages/edit_profile.dart';
import 'package:match5/views/Pages/user_profile.dart';
import 'package:provider/provider.dart';

class Setting_page extends StatefulWidget {
  const Setting_page({super.key});

  @override
  State<Setting_page> createState() => _Setting_pageState();
}

class _Setting_pageState extends State<Setting_page> {
  UserModel? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Provider.of<UserProvider>(context, listen: false).user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text("Settings",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  openProfilePage(context);
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 35,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "Accounts Settings",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              //privacy section
              const SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  privacyBlockedContacts();
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          size: 35,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Privacy & Safety",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text("Blocked Users",
                                style: TextStyle(
                                    color: Color.fromARGB(200, 51, 51, 51),
                                    fontSize: 14)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration:
                      BoxDecoration(color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              //payment section
              const SizedBox(
                height: 8,
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.payment_rounded,
                        size: 35,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Payment and Subscriptions",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                purchaseHistory();
                              },
                              child: Container(
                                width: double.infinity,
                                child: Text("Purchase history",
                                    style: TextStyle(
                                        color: Color.fromARGB(200, 51, 51, 51),
                                        fontSize: 14)),
                              ),
                            ),
                            // const SizedBox(
                            //   height: 8,
                            // ),
                            // InkWell(
                            //   onTap: () {
                            //     promocode();
                            //   },
                            //   child: Container(
                            //     width: double.infinity,
                            //     child: Text("Promo Codes",
                            //         style: TextStyle(
                            //             color: Color.fromARGB(200, 51, 51, 51),
                            //             fontSize: 14)),
                            //   ),
                            // ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              //Help and support
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.help,
                      size: 35,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Help and Support",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              //contact and uspport
                              contactAndSupport();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("Contact Support",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              reportBug();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("Report a bug",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              //LEGAL
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.plagiarism_rounded,
                      size: 35,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Legal",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              termsOfServices();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("Terms of services",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              privacyPolicy();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("Privacy policy",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              //Extras
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.extension_sharp,
                      size: 35,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Extras",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              inviteFriends();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("Invite a friend",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          InkWell(
                            onTap: () {
                              rateUs();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Text("App Feedback/ Rate us",
                                  style: TextStyle(
                                      color: Color.fromARGB(200, 51, 51, 51),
                                      fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 1,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color.fromARGB(100, 224, 224, 224)),
                ),
              ),

              // SizedBox(
              //   height: 16,
              // ),
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     backgroundColor: Colors.red, // Background color
              //     foregroundColor: Colors.white, // Text color
              //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8), // Rounded corners
              //     ),
              //   ),
              //   child: Text("Log out"),
              // )
            ],
          ),
        ),
      ),
    );
  }

  void openProfilePage(context) {
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => UserProfile(
                user: user,
              )));
    });
  }

  void privacyBlockedContacts() {
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (builder) => BlockedUsers(
                id: user!.id,
              )));
    });
  }

  void purchaseHistory() {}

  void promocode() {}

  void reportBug() {}

  void contactAndSupport() {}

  void termsOfServices() {}

  void privacyPolicy() {}

  void inviteFriends() {}

  void rateUs() {}
}
