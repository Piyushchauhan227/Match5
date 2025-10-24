import 'package:flutter/material.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/views/onBoardScreens/username.dart';

class SecondQuestionaire extends StatefulWidget {
  const SecondQuestionaire({required this.gender, required this.id, super.key});

  final String gender;
  final String id;

  @override
  State<SecondQuestionaire> createState() => _SecondQuestionaireState();
}

class _SecondQuestionaireState extends State<SecondQuestionaire> {
  bool isSelected = false;
  List<String> genderList = ["Male", "Female", "Non-Binary"];
  List<String> genderImages = [
    "assets/select_female.png",
    "assets/select_male.png",
    "assets/select_non_binary.png"
  ];
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/login_bg_last_again.png",
            fit: BoxFit.cover,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 32,
                    )),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text(
                    "Who makes your Heart",
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const Text(
                    "skip a beat?",
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                isSelected = true;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 8),
                              child: SizedBox(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            color: selectedIndex == index
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey, width: 0)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 233, 233, 233),
                                                child: Center(
                                                  child: Image.asset(
                                                    "${genderImages[index]}",
                                                    height: 25,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                "${genderList[index]}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        selectedIndex == index
                                                            ? Colors.white
                                                            : Colors.black),
                                              )
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ));
                      }),
                ),
              ],
            ),
          ),
          isSelected == true
              ? Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () async {
                      print("D");
                      var list = await OnBoardConnection().getAvatarList();
                      if (!mounted) return;
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => Username(
                                id: widget.id,
                                gender: widget.gender,
                                interestedGender: genderList[selectedIndex],
                              )));
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    elevation: 20,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                )
              : const SizedBox(
                  height: 0,
                ),
        ],
      ),
    );
  }
}
