// import 'dart:ui';

// import 'package:ironsource_mediation/ironsource_mediation.dart';

// class LevelPlayRewardCustom extends LevelPlayRewardedAdListener {
//   final VoidCallback onRewarded;
//   final VoidCallback onRewardLoad;
//   final VoidCallback changeRewardFlag;

//   LevelPlayRewardCustom(
//       {required this.onRewarded,
//       required this.onRewardLoad,
//       required this.changeRewardFlag});

//   @override
//   void onAdClicked(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdClicked
//     changeRewardFlag();
//   }

//   @override
//   void onAdClosed(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdClosed
//     changeRewardFlag();
//   }

//   @override
//   void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdDisplayFailed
//     changeRewardFlag();
//     print("addisplay failed $adInfo and error is $error");
//   }

//   @override
//   void onAdDisplayed(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdDisplayed
//     print("on ad displayed $adInfo");
//     changeRewardFlag();
//   }

//   @override
//   void onAdInfoChanged(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdInfoChanged
//     print(" adinfo  $adInfo");
//     changeRewardFlag();
//   }

//   @override
//   void onAdLoadFailed(LevelPlayAdError error) {
//     // TODO: implement onAdLoadFailed
//     print("❌ reward in unity failed $error");
//     changeRewardFlag();
//   }

//   @override
//   void onAdLoaded(LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdLoaded
//     print("✅ reward in unity loaded Level play, showing now...");
//     onRewardLoad();
//   }

//   @override
//   void onAdRewarded(LevelPlayReward reward, LevelPlayAdInfo adInfo) {
//     // TODO: implement onAdRewarded
//     print("rewarded has done");
//     onRewarded();
//   }
// }
