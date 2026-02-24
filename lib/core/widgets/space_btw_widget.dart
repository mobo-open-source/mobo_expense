import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget spaceBetweenWidget(String title, String data) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(child: Text(title, style: TextStyle(fontSize: 13))),
      Expanded(child: SizedBox()),
      Expanded(
        child: Text(
          data,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
