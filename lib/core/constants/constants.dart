import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoboText {
  static TextStyle logo = TextStyle(
    fontFamily: "MyFont",
    fontSize: 30,
    color: Colors.white,
  );

  static TextStyle title = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle nav = GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle h2 = GoogleFonts.manrope(
    fontSize: 21,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  static TextStyle h3 = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static TextStyle h4 = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle body = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle normal = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF131927),
  );
  static TextStyle normalBold = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF131927),
  );

  static TextStyle button = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class MoboRadius {
  static const double button = 16.0;
  static const double card = 14.0;
  static const double input = 12.0;
  static const double circle = 100.0;
}

class MoboColor {
  static Color redColor = Color(0xFFC03355);
  static Color white = Color(0xFFF7F7F7);
}

class MoboShadows {
  static final soft = BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 10,
    offset: const Offset(6, 6),
  );

  static final medium = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 18,
    offset: const Offset(0, 8),
  );
}

class MoboPadding {
  static const EdgeInsetsGeometry pagePadding = EdgeInsets.all(20);
}

String logoImg = 'assets/expenses-logo.png';
String authBgImg = 'assets/auth_bg_img.jpg';
String profile = 'assets/profile.jpg';
String category = 'assets/images.jpeg';
