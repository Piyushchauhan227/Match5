import 'package:flutter/material.dart';
import 'package:match5/views/onBoardScreens/second_questionare.dart';

class Firstquestionaire extends StatefulWidget {
  const Firstquestionaire({required this.idIncoming, super.key});

  final String idIncoming;

  @override
  State<Firstquestionaire> createState() => _FirstquestionaireState();
}

class _FirstquestionaireState extends State<Firstquestionaire> {
  List<String> genderList = ["Male", "Female", "Non-Binary"];
  List<String> genderImages = [
    "assets/select_female.png",
    "assets/select_male.png",
    "assets/select_non_binary.png"
  ];
  int selectedIndex = -1;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            "assets/login_bg_last_again.png",
            fit: BoxFit.cover,
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text(
                  "Let's get to know you",
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Better",
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "What's best describes your Gender",
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 16,
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
                                              color: Colors.white, width: 0)),
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
                                                  color: selectedIndex == index
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
                    },
                  ),
                ),
              ],
            ),
          ),
          isSelected == true
              ? Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (builder) => SecondQuestionaire(
                                gender: genderList[selectedIndex],
                                id: widget.idIncoming,
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
