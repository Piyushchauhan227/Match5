//import 'package:in_app_purchase/in_app_purchase.dart';

class RewardModel {
  // ProductDetails productDetails;
  final String icon;
  final String reward;
  final String price;
  final String packName;
  final bool isAd;
  final String? productId;

  RewardModel(
      {required this.icon,
      required this.reward,
      required this.price,
      required this.packName,
      required this.isAd,
      this.productId});
}
