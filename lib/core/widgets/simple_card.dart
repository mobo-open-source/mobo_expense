import 'package:flutter/material.dart';

import '../constants/constants.dart';

class simpleCardWidget extends StatelessWidget {
  Widget child;

  simpleCardWidget(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.withOpacity(0.11) : Colors.white,
        borderRadius: BorderRadius.circular(MoboRadius.card),
        boxShadow: [MoboShadows.soft],
      ),
      child: Padding(padding: MoboPadding.pagePadding, child: child),
    );
  }
}
