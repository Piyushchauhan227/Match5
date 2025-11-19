import 'package:flutter/rendering.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class AppoDealService {
  AppoDealService._internal();
  static final AppoDealService _instance = AppoDealService._internal();
  factory AppoDealService() => _instance;

  Function? onRewardEarned;
  bool isRewardReady = false;
  bool isRequesting = false;

  Future<void> init() async {
    ConsentInformation.instance.reset();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        print("✅ Consent info updated");

        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadAndShowConsentFormIfRequired(
            (FormError? error) {
              if (error != null) {
                print("❌ CMP Error → ${error.message}");
                initAppodeal();
              } else {
                print("🎉 Consent form displayed");
                initAppodeal();
              }
            },
          );
        } else {
          print("🌍 Consent form NOT required in this region");
          initAppodeal(); // START ADS IMMEDIATELY
        }
      },
      (FormError error) => print("❌ Consent update ERROR: ${error.message}"),
    );
  }

  Future<void> loadRewarded() async {
    if (isRequesting) return;
    isRequesting = true;
    try {
      await Appodeal.cache(AppodealAdType.RewardedVideo);
      print("📦 Rewarded ad requested");
    } catch (e) {
      debugPrint("error loading rewarded ad");
      isRequesting = false;
    }
  }

  Future<void> showRewardedAd({Function()? stillLoading}) async {
    print("▶ requesting  ad $isRequesting");
    bool isLoaded = await Appodeal.isLoaded(AppodealAdType.RewardedVideo);
    if (isLoaded) {
      Appodeal.show(AppodealAdType.RewardedVideo);
      print("▶ Showing rewarded ad");
    } else if (isRequesting) {
      stillLoading?.call();
    } else {
      print("❌ Rewarded not loaded yet");

      loadRewarded();
    }
  }

  Future<void> loadInterstitial() async {
    await Appodeal.cache(AppodealAdType.Interstitial);
    print("📦 Interstitial ad requested");
  }

  Future<void> showInterstitial() async {
    bool isLoaded = await Appodeal.isLoaded(AppodealAdType.Interstitial);

    if (isLoaded) {
      Appodeal.show(AppodealAdType.Interstitial);
      print("▶ Showing interstitial");
    } else {
      print("❌ Interstitial not loaded yet");
      loadInterstitial();
    }
  }

  void initAppodeal() async {
    print("🚀 Initializing Appodeal AFTER consent…");

    Appodeal.setLogLevel(Appodeal.LogLevelVerbose);

    await Appodeal.initialize(
      appKey: "d83a289d3b7dbb2903c6bebdaa0a1b8bf16c76d7b28b8585",
      adTypes: [
        AppodealAdType.Banner,
        AppodealAdType.Interstitial,
        AppodealAdType.RewardedVideo,
      ],
      onInitializationFinished: (errors) =>
          print("🎯 APP INIT FINISHED → $errors"),
    );

    Appodeal.setRewardedVideoCallbacks(
      onRewardedVideoFinished: (amount, reward) {
        print("reward");
        if (onRewardEarned != null) {
          onRewardEarned?.call();
        }
      },
      onRewardedVideoLoaded: (bool isPrecache) {
        isRewardReady = true;
        isRequesting = false;
        print("✅ Rewarded READY");
      },
      onRewardedVideoFailedToLoad: (error) {
        isRewardReady = false;
        isRequesting = false;
        print("❌ Reward failed → $error");
      },
      onRewardedVideoClosed: (bool isPrecache) {
        print("👋 CLOSED — RELOAD NEXT AD");
        isRewardReady = false;
        loadRewarded();
      },
      onRewardedVideoExpired: () {
        print("⏳ EXPIRED → RELOAD");
        isRewardReady = false;
        loadRewarded();
      },
    );
  }

//   void loadConsentForm() {
//     Appodeal.ConsentForm.load(
//       appKey: "d83a289d3b7dbb2903c6bebdaa0a1b8bf16c76d7b28b8585",
//       onConsentFormLoadSuccess: (status) {},
//       onConsentFormLoadFailure: (error) {},
//     );

// // Show consent window
//     Appodeal.ConsentForm.show(
//       onConsentFormDismissed: (error) {},
//     );
//   }
}
