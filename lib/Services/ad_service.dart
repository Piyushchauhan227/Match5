import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:match5/const.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdService {
  AdService._internal();

  static final AdService _instance = AdService._internal();

  factory AdService() => _instance;

  InterstitialAd? _interstitialAd;
  bool isInterstitialLoaded = false;
  RewardedAd? rewardedAd;
  bool isRewardedLoaded = false;
  bool isUnityLoading = false;
  bool isUnityLoaded = false;
  bool isUnityInterstitialLoaded = false;
  bool isUnityInterstitialLoading = false;
  bool _adsInitialized = false;

  Future<void> init() async {
    if (_adsInitialized) return;
    _adsInitialized = true;

    Future.microtask(() async {
      try {
        await MobileAds.instance.initialize();

        final isUnityReady = await UnityAds.isInitialized();
        print("unity vala scene $isUnityReady");
        if (!isUnityReady) {
          await UnityAds.init(
            gameId: UNITY_GAME_ID,
            onComplete: () => print('✅ Unity Ads initialized'),
            onFailed: (error, message) =>
                print('❌ Unity Init Failed: $message'),
          );
        }

        print("✅ Ads initialized");
      } catch (e) {
        print("⚠️ AdMob init error: $e");
      }
    });
  }

  void loadInterstitialAd() async {
    isInterstitialLoaded = false;
    await InterstitialAd.load(
        adUnitId: INTERSTITIAL_AD_UNIT,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialLoaded = true;
          print("interstitial Ad Loaded");
        }, onAdFailedToLoad: (error) {
          print("Failed to load interstitial Ad");
          isInterstitialLoaded = false;
          loadUnityInterstitial();
        }));
  }

  void showInterstitialAd() {
    print("interstitial $isInterstitialLoaded and $_interstitialAd");
    if (isInterstitialLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        loadInterstitialAd();
      });

      _interstitialAd!.show();
      _interstitialAd = null;
      isInterstitialLoaded = false;
    } else {
      showUnityInterstitial();
    }
  }

  // void loadInterstitialAndShow() async {
  //   await InterstitialAd.load(
  //     adUnitId: INTERSTITIAL_AD_UNIT,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         debugPrint("✅ Interstitial loaded, showing now...");
  //         _interstitialAd = ad;

  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdDismissedFullScreenContent: (ad) {
  //             ad.dispose();
  //             _interstitialAd = null;
  //             //loadInterstitialAndShow(); // preload next one in background
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             ad.dispose();
  //             _interstitialAd = null;
  //           },
  //         );

  //         ad.show(); // 👈 auto-show immediately when loaded
  //         _interstitialAd = null;
  //       },
  //       onAdFailedToLoad: (error) {
  //         debugPrint("❌ Failed to load interstitial: $error");
  //         _interstitialAd = null;
  //         loadUnityInterstitial();
  //       },
  //     ),
  //   );
  // }

  void disposeInterstitial() {
    _interstitialAd?.dispose();
  }

  void loadRewardedAd() {
    print("rewaRD LOADED");
    if (isRewardedLoaded || rewardedAd != null) return;

    isRewardedLoaded = true;

    RewardedAd.load(
        adUnitId: REWARD_AD_UNIT,
        request: const AdRequest(),
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          print("✅ Rewarded Ad Loaded");
          rewardedAd = ad;
          isRewardedLoaded = false;
        }, onAdFailedToLoad: (LoadAdError error) {
          print("❌ Failed to load rewarded ad: $error");
          rewardedAd = null;
          isRewardedLoaded = false;
          loadUnityRewardAd();
        }));
  }

  void showRewardedAd(
      {Function()? onUserReward,
      Function(String network)? rewardStillLoading,
      Function()? ifFailed}) {
    if (rewardedAd != null) {
      rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        print("🎁 User earned: ${reward.amount} ${reward.type}");
        //addToDb();

        onUserReward!();
      });

      // Dispose old ad and load a new one
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardedAd();
        },
      );

      rewardedAd = null;
    } else if (isRewardedLoaded) {
      print("try this mate");
      rewardStillLoading!("admob");
    } else if (isUnityLoading) {
      print("try this mate in unity");
      rewardStillLoading!("unity");
    } else if (isUnityLoaded) {
      print("hun ede ch");
      UnityAds.showVideoAd(
        placementId: REWARD_DIRECT_WALLET,
        onComplete: (placementId) {
          print("hoya com");
          onUserReward!();
          loadRewardedAd();
        },
        onSkipped: (placementId) {
          print('⚠️ Ad skipped, no reward');
        },
        onFailed: (placementId, error, message) {
          // retry later
          print("failed unity v $error");
        },
      );
    } else {
      ifFailed!();
    }
  }

  void loadUnityRewardAd() {
    isUnityLoading = true;
    UnityAds.load(
        placementId: REWARD_DIRECT_WALLET,
        onComplete: (placementId) {
          isUnityLoaded = true;
          isUnityLoading = false;
          print("✅ Rewarded Ad preloaded from Unity");
        },
        onFailed: (placementId, error, message) {
          isUnityLoaded = false;
          isUnityLoading = false;
          print('❌ Failed to preload: $message');
        });
  }

  void showUnityAd() {
    print("🎯 Attempting to show Unity rewarded ad...");
  }

  void loadUnityInterstitial() {
    if (isUnityInterstitialLoading) return;
    isUnityInterstitialLoaded = false;
    isUnityInterstitialLoading = true;
    UnityAds.load(
      placementId: INTERSTITIAL_DIRECT_LOADED_CHAT,
      onComplete: (placementId) {
        print("✅ Unity Interstitial loaded: $placementId");
        isUnityInterstitialLoaded = true;
        isUnityInterstitialLoading = false;
      },
      onFailed: (placementId, error, message) {
        print("❌ Failed to load Unity Interstitial: $error - $message");
        isUnityInterstitialLoaded = false;
        isUnityInterstitialLoading = false;
      },
    );
  }

  void showUnityInterstitial() async {
    if (!isUnityInterstitialLoaded) {
      loadUnityInterstitial();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));
      UnityAds.showVideoAd(
        placementId: INTERSTITIAL_DIRECT_LOADED_CHAT,
        onStart: (placementId) {
          print("🎥 Unity Interstitial started");
        },
        onComplete: (placementId) {
          print("✅ Unity Interstitial completed");

          isUnityInterstitialLoaded = false;
          Future.delayed(Duration(seconds: 1), () {
            loadInterstitialAd(); // preload next
            // loadUnityInterstitial();
          });
        },
        onSkipped: (placementId) {
          print("⚠️ Unity Interstitial skipped");

          isUnityInterstitialLoaded = false;
          Future.delayed(Duration(seconds: 1), () {
            loadInterstitialAd(); // preload next
            //loadUnityInterstitial();
          });
        },
        onFailed: (placementId, error, message) {
          print("❌ Unity Interstitial failed to show: $error - $message");

          isUnityInterstitialLoaded = false;
          Future.delayed(Duration(seconds: 1), () {
            loadInterstitialAd(); // preload next
            //loadUnityInterstitial();
          });
        },
      );
    }
  }
}
