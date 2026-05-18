import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> get ambient => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get nav => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
