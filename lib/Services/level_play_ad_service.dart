import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'package:match5/Services/level_play_interstitial.dart';
import 'package:match5/Services/level_play_reward.dart';
import 'package:match5/const.dart';

class LevelPlayService extends LevelPlayInitListener {
  LevelPlayService._internal();
  static final LevelPlayService _instance = LevelPlayService._internal();
  factory LevelPlayService() => _instance;

  var isRewardedLoaded = ValueNotifier<bool>(false);
  var isInterstitialLoaded = ValueNotifier<bool>(false);
  var hasRewardedLoadBegin = ValueNotifier<bool>(false);

  LevelPlayRewardedAd? _rewardedAd;
  LevelPlayInterstitialAd? _interstitialAd;

  ValueListenable<bool> get rewardedAvailable => isRewardedLoaded;
  ValueListenable<bool> get interstitialAvailable => isInterstitialLoaded;

  Future<void> init() async {
    final appKey = LEVEL_KEY_ANDROID;
    //final userId = '[YOUR_USER_ID]';
    try {
      // LevelPlay.setAdaptersDebug(true);
      List<AdFormat> legacyAdFormats = [
        AdFormat.BANNER,
        AdFormat.REWARDED,
        AdFormat.INTERSTITIAL,
        AdFormat.NATIVE_AD
      ];
      final initRequest = LevelPlayInitRequest.builder(appKey)
          .withLegacyAdFormats(legacyAdFormats)
          .build();
      await LevelPlay.setConsent(true);
      await LevelPlay.init(initRequest: initRequest, initListener: this);
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    // TODO: implement onInitFailed

    print("❌ Init failed: $error");
  }

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    // TODO: implement onInitSuccess
    print("✅ SDK ready");
  }

  Future<void> loadRewardedAds({
    required VoidCallback onRewardGranted,
  }) async {
    print("chc ${isRewardedLoaded.value}");
    if (isRewardedLoaded.value == true) return;
    hasRewardedLoadBegin.value = true;
    _rewardedAd = LevelPlayRewardedAd(adUnitId: LEVEL_REWARD)
      ..setListener(LevelPlayRewardCustom(changeRewardFlag: () {
        isRewardedLoaded.value = false;
        hasRewardedLoadBegin.value = false;
      }, onRewardLoad: () {
        print("Reward load from level play and ");
        isRewardedLoaded.value = true;
        hasRewardedLoadBegin.value = false;
      }, onRewarded: () {
        onRewardGranted();
        print("Reward should be here");
        isRewardedLoaded.value = false;
        loadRewardedAds(onRewardGranted: onRewardGranted);
      }))
      ..loadAd();
  }

  Future<void> showRewardedAd(
      {required VoidCallback onRewardGranted,
      required VoidCallback showProgressDialog}) async {
    print("chc neeche ${await _rewardedAd!.isAdReady()}");
    if (_rewardedAd != null && await _rewardedAd!.isAdReady()) {
      await _rewardedAd!.showAd();
      return;
    } else if (isRewardedLoaded.value == false &&
        hasRewardedLoadBegin.value == false) {
      loadRewardedAds(onRewardGranted: onRewardGranted);
      return;
    } else if (hasRewardedLoadBegin.value == true) {
      print("show progress bar here");
      showProgressDialog();
      return;
    } else {
      print('No rewarded ad available or not initialized yet');
    }
  }

  Future<void> loadInterstitial() async {
    if (isInterstitialLoaded.value) return;
    _interstitialAd = LevelPlayInterstitialAd(adUnitId: LEVEL_INTERSTITIAL)
      ..setListener(LevelPlayInterstitialCustom(onAdFailed: () {
        isInterstitialLoaded.value = false;
      }, onAdReady: () {
        isInterstitialLoaded.value = true;
      }, changeFlag: () {
        isInterstitialLoaded.value = false;
      }))
      ..loadAd();
  }

  Future<void> showInterstitial() async {
    print(
        "intersitial check $_interstitialAd and value of ${isInterstitialLoaded.value}");
    if (_interstitialAd != null && isInterstitialLoaded.value) {
      isInterstitialLoaded.value = false;
      await _interstitialAd!.showAd();
      return;
    } else {
      print("⚠️ Interstitial not ready, loading now...");
      loadInterstitial();
    }
  }
}
