import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:match5/utils/reward_%20model.dart';
import 'package:match5/utils/reward_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<RewardModel> fireIcons = [
    RewardModel(icon: "assets/fire.png", reward: "10", price: "2.99"),
    RewardModel(icon: "assets/double_fire.png", reward: "20", price: "3.99"),
    RewardModel(icon: "assets/triple_fire.png", reward: "30", price: "4.99"),
    RewardModel(icon: "assets/triple_fire.png", reward: "40", price: "5.99"),
    RewardModel(icon: "assets/fire_log.png", reward: "50", price: "6.99"),
    RewardModel(icon: "assets/fire_log.png", reward: "60", price: "7.99")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Column(children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            height: 50,
            // decoration: BoxDecoration(
            //     border: Border(bottom: BorderSide(color: Colors.grey, width: 1))),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 249, 245, 245), // shadow color
                spreadRadius: 1, // how wide the shadow spreads
                blurRadius: 6, // softness of the shadow
                offset: Offset(0, 3),
              )
            ]),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      "Transaction history",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.arrow_forward_ios_sharp),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemBuilder: (context, index) {
            return RewardCard(
              fire: fireIcons[index].icon,
              reward: fireIcons[index].reward,
              price: fireIcons[index].price,
            );
          },
          itemCount: 6,
        ))
      ]),
    );
  }
}
