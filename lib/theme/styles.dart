import 'package:flutter/material.dart';

class AppStyles {
  static const double cardRadius = 24.0;
  static const double elementRadius = 16.0;
  static const double buttonRadius = 12.0;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static EdgeInsets get screenPadding => const EdgeInsets.all(20.0);
  static EdgeInsets get cardPadding => const EdgeInsets.all(20.0);
}
