import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

Widget businessCardWidget({
  required BuildContext context,
  required String title,
  required String amount,
  required String subtitle,
  required Widget icon,
  required Color bgColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
      borderRadius: BorderRadius.circular(MoboRadius.card),
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.grey.shade200,
          blurRadius: 3,
          spreadRadius: 3,
        ),
      ],
    ),

    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  maxLines: 1,
                  amount,
                  style: MoboText.h2.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: isDark ? Colors.grey : Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: isDark ? Colors.grey : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: icon,
          ),
        ],
      ),
    ),
  );
}
