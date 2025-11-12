// import 'dart:ui';

// import 'package:ironsource_mediation/ironsource_mediation.dart';

// class LevelPlayInterstitialCustom extends LevelPlayInterstitialAdListener {
//   LevelPlayInterstitialCustom(
//       {required this.onAdReady,
//       required this.onAdFailed,
//       required this.changeFlag});

//   final VoidCallback onAdReady;
//   final VoidCallback onAdFailed;
//   final VoidCallback changeFlag;

//   @override
//   void onAdClicked(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdClicked
//     changeFlag();
//   }

//   @override
//   void onAdClosed(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdClosed
//     changeFlag();
//   }

//   @override
//   void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdDisplayFailed
//     changeFlag();
//   }

//   @override
//   void onAdDisplayed(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdDisplayed
//     changeFlag();
//   }

//   @override
//   void onAdInfoChanged(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdInfoChanged
//     changeFlag();
//   }

//   @override
//   void onAdLoadFailed(LevelPlayAdError error) {
//     // TODO: implement onAdLoadFailed
//     print("❌ interstitisl in unity failed $error");
//     onAdFailed();
//   }

//   @override
//   void onAdLoaded(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdLoaded
//     print("✅ interstitial in unity loaded Level play, showing now...");
//     onAdReady();
//   }
// }
