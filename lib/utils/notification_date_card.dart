import 'package:flutter/material.dart';

class NotificationDateCard extends StatelessWidget {
  const NotificationDateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Today",
          style: TextStyle(color: Colors.grey),
        )
      ],
    );
  }
}
