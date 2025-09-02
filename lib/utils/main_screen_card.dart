import 'package:flutter/material.dart';

class MainScreenCard extends StatefulWidget {
  const MainScreenCard(
      {required this.imageString,
      required this.title,
      required this.details,
      super.key});

  final String imageString;
  final String title;
  final String details;

  @override
  State<MainScreenCard> createState() => _MainScreenCardState();
}

class _MainScreenCardState extends State<MainScreenCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              widget.imageString,
              height: 300,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          // Positioned(
          //     bottom: 10,
          //     left: 10,
          //     child: Text(
          //       widget.title,
          //       style: const TextStyle(fontSize: 25, color: Colors.white),
          //     ))

          const SizedBox(
            height: 3,
          ),
          Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Text(
                widget.title,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              )),
          Padding(
            padding:
                const EdgeInsets.only(top: 2, left: 10, right: 6, bottom: 20),
            child: Text(
              widget.details,
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          )
        ],
      ),
    );
  }
}
