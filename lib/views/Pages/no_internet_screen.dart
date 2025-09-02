import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // WiFi / No Internet Icon
                Icon(
                  Icons.wifi_off_sharp,
                  size: 100,
                  color: Colors.orange.shade400,
                ),
                const SizedBox(height: 30),

                // Title
                Text(
                  "You're Offline",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "It looks like you’ve lost your connection.\n"
                  "Please check your internet and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Retry Button
              ],
            ),
          ),
        ),
      ),
    );
  }
}
