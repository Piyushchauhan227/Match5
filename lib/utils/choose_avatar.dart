import 'package:flutter/material.dart';
import 'package:match5/const.dart';

class ChooseAvatar extends StatefulWidget {
  const ChooseAvatar({required this.avatarName, super.key});

  final String avatarName;
  // final bool isSelected;

  @override
  State<ChooseAvatar> createState() => _ChooseAvatarState();
}

class _ChooseAvatarState extends State<ChooseAvatar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipOval(
        child: Image.network(
          "$BASE_URL/profile_pics/${widget.avatarName}",
          fit: BoxFit.fill,
          height: 80,
          width: 80,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person);
          },
        ),
      ),
    );
  }
}
