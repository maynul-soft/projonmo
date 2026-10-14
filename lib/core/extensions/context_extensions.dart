import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  // Theme & Styling
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Direct Colors Access
  Color get primaryColor => AppColors.primary;
  Color get backgroundColor => AppColors.background;
  Color get surfaceColor => AppColors.surface;
  Color get cardColor => AppColors.cardBg;
  Color get textPrimaryColor => AppColors.textPrimary;
  Color get textSecondaryColor => AppColors.textSecondary;
  Color get textMutedColor => AppColors.textMuted;
  Color get borderColor => AppColors.border;
  Color get accentGold => AppColors.accentGold;

  // Screen Dimensions & Queries
  Size get screenSize => MediaQuery.sizeOf(this);
  double get width => screenSize.width;
  double get height => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  // Quick navigation shortcuts
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  // Snackbar / Toast helpers
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppColors.accentRed : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
