import 'dart:ui';
import 'package:flutter/material.dart';

class AppGlass {
  AppGlass._();

  /// Authentic iOS translucent frosted glass fill color
  static Color get fillColor => Colors.white.withValues(alpha: 0.72);

  /// Ultra-subtle hairline border color matching iOS navigation bar
  static Color get borderColor => const Color(0x33000000); // 20% black hairline

  /// Frosted glass flexibleSpace for AppBar with iOS vibrancy blur and bottom hairline
  static Widget get flexibleSpace => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
      child: Container(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: 0.5,
            ),
          ),
        ),
      ),
    ),
  );

  /// Frosted glass decoration for BottomNavigationBar with iOS blur and top hairline
  static BoxDecoration get bottomNavDecoration => BoxDecoration(
    color: fillColor,
    border: Border(
      top: BorderSide(
        color: borderColor,
        width: 0.5,
      ),
    ),
  );
}
