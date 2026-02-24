import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

Widget submitButton({
  required VoidCallback? onclick,
  required String title,
  bool active = true,
  Color? color,
  Widget? leading,
}) {
  return Container(
    constraints: const BoxConstraints(minWidth: 400, minHeight: 45),
    child: TextButton(
      key: Key("button_container"),

      onPressed: active ? onclick : null,
      style: TextButton.styleFrom(
        backgroundColor: active ? (color ?? MoboColor.redColor) : Colors.grey,
        disabledBackgroundColor: Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: leading ?? SizedBox.shrink(),
          ),

          Text(
            title,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}
