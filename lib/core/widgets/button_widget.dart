import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/constants.dart';

Widget buttonWidget({
  required VoidCallback onclick,
  required String title,
  required bool clickable,
  required bool isLoading,
  Color? color,
}) {
  return Container(
    constraints: const BoxConstraints(
      minWidth: 400,
      maxWidth: 600,
      minHeight: 45,
    ),
    child: TextButton(
      onPressed: clickable ? onclick : () {},
      style: TextButton.styleFrom(
        backgroundColor: clickable ? Colors.black : Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 10),
          isLoading
              ? LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 20,
                )
              : SizedBox(),
        ],
      ),
    ),
  );
}
