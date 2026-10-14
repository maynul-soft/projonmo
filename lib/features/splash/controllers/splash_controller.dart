import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    animationController.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Artificial minimum delay for brand presentation
    await Future.delayed(const Duration(milliseconds: 2000));

    final token = await TokenStorage.instance.getToken();
    final hasAuthToken = token != null && token.isNotEmpty;

    if (hasAuthToken) {
      // Ensure AuthController is available
      final auth = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController(), permanent: true);

      // Load cached user profile if exists
      final cachedUserJson = await TokenStorage.instance.getUser();
      if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
        try {
          final userMap = jsonDecode(cachedUserJson) as Map<String, dynamic>;
          auth.currentUser.value = UserModel.fromJson(userMap);
        } catch (_) {}
      }

      // Proactively fetch updated user profile in background
      try {
        final res = await ApiClient.instance.get(ApiEndpoints.customerMe);
        if (res.data != null && res.data is Map) {
          final resMap = Map<String, dynamic>.from(res.data as Map);
          final data = resMap['data'];
          if (data != null && data is Map) {
            final userObj = UserModel.fromJson(Map<String, dynamic>.from(data));
            auth.currentUser.value = userObj;
            await TokenStorage.instance.saveUser(jsonEncode(userObj.toJson()));
          }
        }
      } catch (_) {
        // If offline or network issue, continue with cached session
      }

      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
