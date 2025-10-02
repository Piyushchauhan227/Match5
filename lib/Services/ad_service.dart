import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:match5/const.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool isInterstitialLoaded = false;

  Future<void> init() async {
    await MobileAds.instance.initialize();
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
      print("Interstitial ad is not ready");
    }
  }

  void loadInterstitialAndShow() async {
    await InterstitialAd.load(
      adUnitId: INTERSTITIAL_AD_UNIT,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("✅ Interstitial loaded, showing now...");
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              //loadInterstitialAndShow(); // preload next one in background
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );

          ad.show(); // 👈 auto-show immediately when loaded
          _interstitialAd = null;
        },
        onAdFailedToLoad: (error) {
          debugPrint("❌ Failed to load interstitial: $error");
          _interstitialAd = null;
        },
      ),
    );
  }

  void disposeInterstitial() {
    _interstitialAd?.dispose();
  }
}
