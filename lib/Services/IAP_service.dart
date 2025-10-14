import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/const.dart';
import 'package:provider/provider.dart';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();
  UserProvider? _userProvider;
  String? _userId;

  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
    _userId = userProvider.user!.id;
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  bool available = false;
  List<ProductDetails> products = [];
  late StreamSubscription<List<PurchaseDetails>>? subscription;

  final rewards = {
    "fires15": 15,
    "fires49": 49,
    "fires120": 120,
    "fires299": 299,
    "fires999": 999,
  };

  @override
  void dispose() {
    // TODO: implement dispose
    subscription?.cancel();
  }

  Future<void> initialize() async {
    available = await _iap.isAvailable();
    if (available) {
      const ids = {'fires15', 'fires49', 'fires120', 'fires299', 'fires999'};
      ProductDetailsResponse response = await _iap.queryProductDetails(ids);
      products = response.productDetails;

      subscription = _iap.purchaseStream.listen(_handlePurchaseUpdate,
          onDone: () => subscription?.cancel(),
          onError: (error) => print("purchase stream cancelled , $error"));
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // 🔥 Grant fires here (and ideally verify with backend)
        await verifyPurchaseOnServer(purchase);
        print("Purchase successful: ${purchase.productID}");
      } else if (purchase.status == PurchaseStatus.error) {
        print("Purchase error: ${purchase.error}");
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> verifyPurchaseOnServer(PurchaseDetails purchase) async {
    try {
      var product = products.firstWhere(
        (p) => p.id == purchase.productID,
        orElse: () => throw Exception("Unknown product"),
      );

      print("product vai product $product");

      final url = Uri.parse("$BASE_URL/playVerify/verifyPurchase");
      print("checking produtc id is ${purchase.productID}");
      print("checking here first ${rewards[purchase.productID]}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "purchaseToken": purchase.verificationData.serverVerificationData,
          "productId": purchase.productID,
          "userId": _userId,
          "fires": rewards[purchase.productID], // pass your app’s user ID
          "amount": product.price
        }),
      );
      var resData = jsonDecode(response.body);
      var updatedUser = UserModel(
          id: resData["user"]["_id"],
          name: resData["user"]["name"],
          email: resData["user"]["email"],
          gender: resData["user"]["gender"],
          interestedGender: resData["user"]["interestedGender"],
          username: resData["user"]["username"],
          fcmToken: resData["user"]["fcmToken"],
          coins: resData["user"]["coins"],
          userProfile: resData["user"]["userProfile"],
          about: resData["user"]["about"]);

      if (response.statusCode == 200) {
        print("✅ Purchase verified for $_userId");
        print("heck kri kera user aaya edr update ke nai ${resData["user"]}");
        _userProvider!.updateUser(updatedUser);
        //
      } else {
        print("❌ Verification failed: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error verifying purchase: $e");
    }
  }
}
