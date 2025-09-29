import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsProvider with ChangeNotifier {
  FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalytics? get analytics => _analytics;

  Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(
        screenName: screenName, screenClass: screenName);
  }

  Future<void> logEvent(String name, {Map<String, Object>? param}) async {
    await _analytics.logEvent(name: name, parameters: param);
  }
}
