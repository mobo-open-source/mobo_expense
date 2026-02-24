import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../constants/constants.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,

  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Container(
            height: 40,
            width: 40,

            decoration: BoxDecoration(
              color: MoboColor.white.withAlpha(100),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(10),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              size: 30,
              color: Colors.white,
            ),
          ),

          SizedBox(width: 20),

          Flexible(
            child: Text(
              message,
              style: MoboText.h4.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 30, left: 10, right: 10),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
