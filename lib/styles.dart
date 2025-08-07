import 'package:flutter/material.dart';

class AppStyles {
  static const Color headerColor = Color(0xFF25334A);
  static const Color whiteColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color blueGrey = Colors.blueGrey;
  static Color? blue_50 = Colors.blue[50];

  static const TextStyle headingStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor);
  static const TextStyle bodyStyle = TextStyle(fontSize: 16, color: textColor);

  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: headerColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    elevation: 5,
  );
  static ButtonStyle cancelButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    elevation: 5,
  );
}
