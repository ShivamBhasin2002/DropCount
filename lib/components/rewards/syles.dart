import 'package:flutter/material.dart';

class AppColors {
  static Color orangeAccent = Color.fromARGB(255, 235, 179, 61);
  static Color orangeAccentButtonColor = Color.fromARGB(255, 228, 228, 228);
  static Color orangeAccentLight = Color.fromARGB(255, 23, 94, 116);
  static Color redAccent = Color.fromARGB(255, 235, 179, 61);
  static Color grey = Color.fromARGB(255, 161, 159, 159);
}

class Styles {
  static TextStyle text(double size, Color color, bool bold, {double? height}) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      height: height,
      fontFamily: "Poppins",
    );
  }
}
