import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/network.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../models/dashboard_wallet_model.dart';

class ProfileController extends GetxController {
  final activeTab = 'service'.obs; // 'service' or 'svip'
  final walletData = Rx<DashboardWalletModel>(DashboardWalletModel());
  final telegramLink = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadWalletData();
    fetchTelegramSettings();

    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
    });
  }

  Future<void> _loadWalletData() async {
    try {
      final cachedUser = await TokenStorage.instance.getUser();
      if (cachedUser != null && cachedUser.isNotEmpty) {
        final map = jsonDecode(cachedUser) as Map<String, dynamic>;
        walletData.value = DashboardWalletModel.fromJson(map);
      }
    } catch (_) {}

    // Fetch the latest customer /me data
    await fetchCustomerProfile();
  }

  Future<void> fetchCustomerProfile() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.customerMe);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final dataMap = Map<String, dynamic>.from(resMap['data'] as Map);

          // Update Wallet model
          walletData.value = DashboardWalletModel.fromJson(dataMap);

          // Update AuthController's user model and cache it
          final userModel = UserModel.fromJson(dataMap);
          Get.find<AuthController>().setUser(userModel);
          await TokenStorage.instance.saveUser(jsonEncode(userModel.toJson()));
        }
      }
    } catch (e) {
      debugPrint('[ProfileController] Error fetching profile /me: $e');
    }
  }

  /// Fetch Telegram settings from GET /public/telegram
  Future<void> fetchTelegramSettings() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicTelegram);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['data'] != null && resMap['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(resMap['data'] as Map);
          final link = dataMap['telegramChannelLink']?.toString() ??
              dataMap['telegram_channel_link']?.toString() ??
              dataMap['channel']?.toString() ??
              dataMap['link']?.toString() ??
              '';
          if (link.isNotEmpty) {
            telegramLink.value = link;
          }
        }
      }
    } catch (e) {
      debugPrint('[ProfileController] Error fetching telegram settings: $e');
    }
  }

  /// Method to easily inject API response
  void setWalletData(DashboardWalletModel data) {
    walletData.value = data;
  }

  void deductFunds(double amount, {required bool fromRechargeWallet}) {
    final current = walletData.value;
    if (fromRechargeWallet) {
      walletData.value = current.copyWith(
        rechargeWallet: current.rechargeWallet - amount,
      );
    } else {
      walletData.value = current.copyWith(
        balanceWallet: current.balanceWallet - amount,
      );
    }
  }

  void addEarnings(double amount) {
    final current = walletData.value;
    walletData.value = current.copyWith(
      balanceWallet: current.balanceWallet + amount,
      totalEarnings: current.totalEarnings + amount,
      incomeToday: current.incomeToday + amount,
    );
  }

  void addRecharge(double amount) {
    final current = walletData.value;
    walletData.value = current.copyWith(
      rechargeWallet: current.rechargeWallet + amount,
    );
  }

  Future<void> openTelegramChannel() async {
    var link = telegramLink.value;
    if (link.isEmpty) {
      link = walletData.value.telegramChannelUrl;
    }
    if (link.isEmpty) {
      link = 'https://t.me/example';
    }

    await Clipboard.setData(ClipboardData(text: link));

    Get.snackbar(
      AppStrings.telegramChannel,
      'Link copied to clipboard: $link',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0088CC),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.copy_rounded, color: Colors.white),
    );
  }

  void showSignOutConfirmation() {
    Get.defaultDialog(
      title: AppStrings.confirmSignOut,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      radius: 16,
      content: const Text(
        AppStrings.confirmSignOutMsg,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          foregroundColor: AppColors.textSecondary,
        ),
        child: const Text(AppStrings.cancel),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentRed,
        ),
        onPressed: () {
          Get.back();
          Get.find<AuthController>().logout();
        },
        child: const Text(AppStrings.signOut, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
