import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/constants.dart';

Widget summaryCardWidget() {
  return Container(
    height: 100,
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.all(20),
    width: double.infinity,

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(MoboRadius.card),
      boxShadow: [
        BoxShadow(color: Colors.grey.shade200, blurRadius: 3, spreadRadius: 3),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Follow  Up on OverDue invoices", style: MoboText.h4),
              Text("mitchel admin", style: MoboText.normal),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(MoboRadius.input),
          ),
          padding: EdgeInsets.all(8),
          child: Text(
            "high",
            style: GoogleFonts.manrope(fontSize: 10, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
