import 'package:flutter/material.dart';

/// Centralized color palette for the Valhalla Android application.
/// These colors are extracted from the original application design.
class AppColors {
  // Primary brand colors from original design
  static const Color primary = Color.fromRGBO(129, 134, 213, 1);
  static const Color secondary = Color.fromRGBO(73, 76, 162, 1);
  static const Color background = Color.fromRGBO(243, 243, 255, 1);
  static const Color surface = Color.fromRGBO(198, 203, 239, 1);
  static const Color surfaceVariant = Color.fromRGBO(198, 203, 239, 0.5);
  
  // Authentication specific colors
  static const Color authBackground = Color.fromRGBO(129, 134, 213, 1);
  static const Color authButton = Color.fromRGBO(73, 76, 162, 1);
  
  // Text colors
  static const Color textPrimary = Color.fromRGBO(243, 243, 255, 1);
  static const Color textSecondary = Color.fromRGBO(200, 200, 255, 1);
  static const Color textDark = Color.fromRGBO(33, 37, 41, 1);
  static const Color textMuted = Color.fromRGBO(108, 117, 125, 1);
  
  // Common colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  
  // Status colors
  static const Color success = Color.fromRGBO(40, 167, 69, 1);
  static const Color warning = Color.fromRGBO(255, 193, 7, 1);
  static const Color error = Color.fromRGBO(220, 53, 69, 1);
  static const Color info = Color.fromRGBO(23, 162, 184, 1);
  
  // Neutral colors
  static const Color grey50 = Color.fromRGBO(248, 249, 250, 1);
  static const Color grey100 = Color.fromRGBO(233, 236, 239, 1);
  static const Color grey200 = Color.fromRGBO(222, 226, 230, 1);
  static const Color grey300 = Color.fromRGBO(206, 212, 218, 1);
  static const Color grey400 = Color.fromRGBO(173, 181, 189, 1);
  static const Color grey500 = Color.fromRGBO(108, 117, 125, 1);
  static const Color grey600 = Color.fromRGBO(73, 80, 87, 1);
  static const Color grey700 = Color.fromRGBO(52, 58, 64, 1);
  static const Color grey800 = Color.fromRGBO(33, 37, 41, 1);
  static const Color grey900 = Color.fromRGBO(13, 27, 42, 1);
  
  // Shadow and overlay colors
  static const Color shadow = Color.fromRGBO(76, 72, 28, 0.25);
  static const Color overlay = Color.fromRGBO(0, 0, 0, 0.5);
  
  // Navigation colors
  static const Color navSelected = Color.fromRGBO(48, 51, 146, 1);
  static const Color navUnselected = Color.fromRGBO(108, 117, 125, 1);
  
  // Card and container colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color.fromRGBO(0, 0, 0, 0.1);
  
  // Button colors
  static const Color buttonPrimary = Color.fromRGBO(73, 76, 162, 1);
  static const Color buttonSecondary = Color.fromRGBO(108, 117, 125, 1);
  static const Color buttonSuccess = Color.fromRGBO(40, 167, 69, 1);
  static const Color buttonDanger = Color.fromRGBO(220, 53, 69, 1);
  
  // Input field colors
  static const Color inputBackground = Colors.white;
  static const Color inputBorder = Color.fromRGBO(206, 212, 218, 1);
  static const Color inputFocusedBorder = Color.fromRGBO(73, 76, 162, 1);
  static const Color inputErrorBorder = Color.fromRGBO(220, 53, 69, 1);
}