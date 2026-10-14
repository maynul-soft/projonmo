import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final double overlayOpacity;
  final Color? overlayColor;
  final bool useSafeArea;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.overlayOpacity = 0.08,
    this.overlayColor,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            AppAssets.scaffoldBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => Container(color: AppColors.background),
          ),

          // Translucent Tint Overlay for Readability
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: overlayOpacity),
          ),

          // Main Body Content
          useSafeArea ? SafeArea(child: body) : body,
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
