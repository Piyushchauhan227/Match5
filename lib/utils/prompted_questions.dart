import 'package:flutter/material.dart';
import 'package:match5/questions.dart';

class PromptedQuestions extends StatefulWidget {
  const PromptedQuestions(
      {required this.question, required this.color, super.key});

  final String question;
  final Color? color;

  @override
  State<PromptedQuestions> createState() => _PromptedQuestionsState();
}

class _PromptedQuestionsState extends State<PromptedQuestions> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: widget.color,
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        shadowColor: Colors.black.withOpacity(0.2),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text("${widget.question}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
