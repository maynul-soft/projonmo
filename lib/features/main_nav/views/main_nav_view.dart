import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../home/views/home_view.dart';
import '../../post/views/post_list_view.dart';
import '../../product/views/product_list_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_nav_controller.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      HomeView(),
      ProductListView(),
      PostListView(),
      ProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Global Scaffold Background Image
          Image.asset(
            AppAssets.scaffoldBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => Container(color: AppColors.background),
          ),
          // Soft protective overlay for contrast
          Container(
            color: Colors.black.withValues(alpha: 0.08),
          ),
          // Navigation Pages
          Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: pages,
          )),
        ],
      ),
      bottomNavigationBar: Obx(() => ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: AppGlass.bottomNavDecoration,
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.black87,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: Colors.black87),
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: AppStrings.navProduct,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_outlined),
              activeIcon: Icon(Icons.dynamic_feed_rounded),
              label: AppStrings.navPost,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: AppStrings.navMe,
            ),
          ],
        ),
      )),
    )));
  }
}
