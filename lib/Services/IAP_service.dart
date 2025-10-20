import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:match5/Models/user_model.dart';
import 'package:match5/Provider/user_provider.dart';
import 'package:match5/const.dart';

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
  StreamSubscription<List<PurchaseDetails>>? subscription;

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

      subscription?.cancel();
      subscription = _iap.purchaseStream.listen(_handlePurchaseUpdate,
          onError: (error) => print("purchase stream cancelled , $error"));
      await consumeUnfinishedPurchases();
    }
  }

  Future<void> consumeUnfinishedPurchases() async {
    print("🔍 Checking for any unfinished purchases to consume...");

    try {
      // This listens for any owned / unfinished purchases
      await for (final purchaseList in _iap.purchaseStream) {
        for (final purchase in purchaseList) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            try {
              await _iap.completePurchase(purchase);
              print("✅ Consumed leftover purchase: ${purchase.productID}");
            } catch (e) {
              print("⚠️ Error consuming leftover purchase: $e");
            }
          }
        }
        break; // Only handle first emission
      }

      print("✅ Finished checking for stuck purchases.");
    } catch (e, stack) {
      print("⚠️ Error consuming unfinished purchases: $e\n$stack");
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e, stack) {
      print("⚠️ Error querying past purchases: $e and stack strace is $stack");
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    print("checking purchases mate $purchases");
    final androidAddition = InAppPurchase.instance
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

    for (var purchase in purchases) {
      print(
          "purchase idr aaya $purchase and its status is ${purchase.status} and pending one is ${purchase.pendingCompletePurchase}");
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // 🔥 Grant fires here (and ideally verify with backend)

        print("haha paise aae");
        await verifyPurchaseOnServer(purchase);
        try {
          // In debug sandbox, completePurchase sometimes does nothing,
          // so explicitly consume it on Android
          await androidAddition.consumePurchase(purchase);
          print(
              "✅ Explicitly consumed purchase via AndroidAddition: ${purchase.productID}");
        } catch (e) {
          print("⚠️ consumePurchase() failed: $e, trying completePurchase()");
          try {
            await _iap.completePurchase(purchase);
          } catch (err) {
            print("⚠️ completePurchase() also failed: $err");
          }
        }
        print("Purchase successful: ${purchase.productID}");
      } else if (purchase.status == PurchaseStatus.error) {
        print("Purchase error: ${purchase.error}");
      }
      if (purchase.pendingCompletePurchase) {
        print("purchase eh ni chlya kya");
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> buy(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  Future<void> verifyPurchaseOnServer(PurchaseDetails purchase) async {
    print(
        "edr gali bnai aa ${purchase.verificationData.serverVerificationData}");
    try {
      var product = products.firstWhere(
        (p) => p.id == purchase.productID,
        orElse: () => throw Exception("Unknown product"),
      );

      print("product vai product $product");

      final url = Uri.parse("$BASE_URL/playVerify/verifyPurchase");
      print("checking produtc id is ${purchase.productID}");
      print(
          "checking here first ${rewards[purchase.productID]} and userId is ");

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

      dynamic resData;
      try {
        resData = jsonDecode(response.body);
      } catch (_) {
        print("⚠️ Could not decode response JSON");
        return;
      }

      if (response.statusCode == 200 &&
          resData is Map &&
          resData["user"] != null) {
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

        print("✅ Purchase verified for $_userId");
        print("heck kri kera user aaya edr update ke nai ${resData["user"]}");
        _userProvider?.updateUser(updatedUser);

        //
      } else {
        print("❌ Verification failed: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Error verifying purchase: $e");
    }
  }
}
