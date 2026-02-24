import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

class analyticCardWidget extends StatelessWidget {
  final String title;
  final String amount;
  final bool dollar;
  final String sub;
  final Color color;

  const analyticCardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.dollar,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(right: 8, top: 10, bottom: 10, left: 3),
      child: Container(
        width: 250,

        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.11) : Colors.white,
          borderRadius: BorderRadius.circular(MoboRadius.card),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.shade200,
              blurRadius: 3,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),

            Text(
              "${dollar ? "≈" : " "} $amount",
              style: MoboText.h2.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
