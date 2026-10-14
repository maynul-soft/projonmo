import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Primaries
  static const Color primary = Color(0xFF1B8754); // Sophisticated Emerald Green
  static const Color primaryDark = Color(0xFF125B38);
  static const Color primaryLight = Color(0xFFE8F5E9);
  static const Color primaryAccent = Color(0xFF22C55E);

  // Secondary & Accents
  static const Color accentGold = Color(0xFFF59E0B); // Amber / Gold
  static const Color accentGoldLight = Color(0xFFFEF3C7);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC); // Modern Off-white / light slate
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color cardBg = Colors.white;
  static Color get glassFill => Colors.white.withValues(alpha: 0.85);
  static Color get glassBorder => border.withValues(alpha: 0.6);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Colors.white;

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderActive = Color(0xFF1B8754);

  // Dashboard Stats Card Colors (Clean, Professional Palette)
  static const Color statCardGreen = Color(0xFF10B981);
  static const Color statCardEmerald = Color(0xFF059669);
  static const Color statCardTeal = Color(0xFF0D9488);
  static const Color statCardAmber = Color(0xFFD97706);
  static const Color statCardBlue = Color(0xFF2563EB);
  static const Color statCardIndigo = Color(0xFF4F46E5);
  static const Color statCardRose = Color(0xFFE11D48);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1B8754), Color(0xFF157347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientGreen = LinearGradient(
    colors: [Color(0xFF1E824C), Color(0xFF145A32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerOverlay = LinearGradient(
    colors: [Colors.black54, Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
}
