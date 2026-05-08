import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundTop = Color(0xFF0D0D14);
  static const Color backgroundBottom = Color(0xFF1A1A2E);
  static const Color accentLime = Color(0xFFD6FF4B);
  
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFA1A1AA);
  
  static const Color purpleGradientStart = Color(0xFFA855F7);
  static const Color purpleGradientEnd = Color(0xFFEC4899);

  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  static const LinearGradient globalBackground = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purpleCardGradient = LinearGradient(
    colors: [purpleGradientStart, purpleGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
