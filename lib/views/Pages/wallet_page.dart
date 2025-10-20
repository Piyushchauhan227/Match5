import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:match5/Database/api/user_api.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/Services/IAP_service.dart';
import 'package:match5/Services/ad_service.dart';
import 'package:match5/const.dart';
import 'package:match5/utils/reward_%20model.dart';
import 'package:match5/utils/reward_card.dart';
import 'package:match5/views/Pages/transaction_history.dart';
import 'package:provider/provider.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final IapService iapService = IapService();
  List<ProductDetails>? products;
  RewardedAd? _rewardedAd;
  bool isAdLoaded = false;
  UserProvider? user;
  bool isUnityLoaded = false;
  bool isUnityLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AdService().loadRewardedAd();
    if (!mounted) return;

    products = iapService.products;
    print("Products fetched: $products");

    if (!mounted) return;
    user = Provider.of<UserProvider>(context, listen: false);
    iapService.setUserProvider(user!);
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  List<RewardModel> fireIcons = [
    RewardModel(
        icon: "assets/fire.png",
        reward: "15",
        price: "0.99",
        packName: "Starter Pack",
        isAd: false,
        productId: "fires15"),
    RewardModel(
        icon: "assets/double_fire.png",
        reward: "49",
        price: "2.99",
        packName: "Hot Pack",
        isAd: false,
        productId: "fires49"),
    RewardModel(
        icon: "assets/triple_fire.png",
        reward: "120",
        price: "5.99",
        packName: "Blazing Pack",
        isAd: false,
        productId: "fires120"),
    RewardModel(
        icon: "assets/triple_fire.png",
        reward: "299",
        price: "9.99",
        packName: "Inferno Pack",
        isAd: false,
        productId: "fires299"),
    RewardModel(
        icon: "assets/fire_log.png",
        reward: "999",
        price: "19.99",
        packName: "Ultimate Pack",
        isAd: false,
        productId: "fires999"),
    RewardModel(
        icon: "assets/watch_ad.png",
        reward: "0",
        price: "1",
        packName: "",
        isAd: true)
  ];

  @override
  Widget build(BuildContext context) {
    if (!iapService.available) {
      return Scaffold(body: Center(child: Text("Store not available")));
    }
    if (iapService.products.isEmpty) {
      return Scaffold(body: Center(child: Text("Loading products...")));
    }

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
            child: InkWell(
              onTap: () {
                if (!mounted) return;
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TransactionHistory()));
              },
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
        ),
        Expanded(
            child: GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.83,
          ),
          itemBuilder: (context, index) {
            final reward = fireIcons[index];

            ProductDetails? product;
            try {
              product = products?.firstWhere(
                (p) => p.id == reward.productId,
                orElse: () => throw Exception("Not found"),
              );
            } catch (_) {
              product = null;
            }

            return InkWell(
              onTap: () {
                if (!reward.isAd) {
                  iapService.buy(product!);
                } else {
                  //handle add thing
                  _showRewardedAd();
                }
              },
              child: RewardCard(
                fire: fireIcons[index].icon,
                reward: fireIcons[index].reward,
                price: product?.price ?? fireIcons[index].price,
                packName: fireIcons[index].packName,
                isAd: fireIcons[index].isAd,
              ),
            );
          },
          itemCount: fireIcons.length,
        )),
      ]),
    );
  }

  Future<void> addToDb() async {
    if (!mounted) return;

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
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }

  void _showRewardedAd() {
    AdService().showRewardedAd(onUserReward: () {
      print("loaded and showing now");
      addToDb();
    }, rewardStillLoading: (network) async {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false, // user can't dismiss manually
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.yellow),
        ),
      );
      while (AdService().isRewardedLoaded) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
      if (!mounted) return;
      Navigator.pop(context);
      AdService().showRewardedAd(onUserReward: () {
        print("loaded and showing now");
        addToDb();
      });
    }, ifFailed: () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("No Ads available at the moment, please try again later")));
    });
  }
}
