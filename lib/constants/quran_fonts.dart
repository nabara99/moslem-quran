import 'package:flutter/material.dart';

class QuranFonts {
  static const String uthmanic = 'Uthmanic';

  static TextStyle arabicStyle({
    double fontSize = 28,
    Color? color,
    double height = 2.0,
  }) {
    return TextStyle(
      fontFamily: uthmanic,
      fontSize: fontSize,
      color: color,
      height: height,
    );
  }

  static TextStyle surahNameStyle({
    double fontSize = 24,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: uthmanic,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle bismillahStyle({
    double fontSize = 26,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: uthmanic,
      fontSize: fontSize,
      color: color,
    );
  }
}
