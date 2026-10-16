import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import 'profile_controller.dart';

class PointsController extends GetxController {
  final pointsController = TextEditingController();
  
  final isPreviewing = false.obs;
  final previewBdtAmount = 0.0.obs;
  
  final isConverting = false.obs;
  
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    pointsController.addListener(_onPointsChanged);
  }

  void _onPointsChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final pointsStr = pointsController.text.trim();
      final points = int.tryParse(pointsStr) ?? 0;
      if (points >= 10) {
        _previewConversion(points);
      } else {
        previewBdtAmount.value = 0.0;
      }
    });
  }

  Future<void> _previewConversion(int points) async {
    try {
      isPreviewing.value = true;
      final response = await ApiClient.instance.post(
        ApiEndpoints.customerPointsConvert,
        data: {'points': points},
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        previewBdtAmount.value = (data['bdtAmount'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      debugPrint('[PointsController] Preview Error: $e');
      previewBdtAmount.value = 0.0;
    } finally {
      isPreviewing.value = false;
    }
  }

  Future<void> convertPoints() async {
    final pointsStr = pointsController.text.trim();
    final points = int.tryParse(pointsStr) ?? 0;

    if (points < 10) {
      Get.snackbar('Invalid Amount', 'Minimum 10 points required to convert.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final profileCtrl = Get.find<ProfileController>();
    if (points > profileCtrl.walletData.value.points) {
      Get.snackbar('Insufficient Points', 'You do not have enough points.', backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isConverting.value = true;
      final response = await ApiClient.instance.post(
        ApiEndpoints.customerPointsRedeem,
        data: {'points': points},
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        final convertedBdt = (data['convertedBdt'] as num?)?.toDouble() ?? previewBdtAmount.value;
        final newBalance = (data['newBalance'] as num?)?.toDouble() ?? (profileCtrl.walletData.value.balanceWallet + convertedBdt);
        final newPoints = (data['newPointsBalance'] as num?)?.toInt() ?? (profileCtrl.walletData.value.points - points);

        // Update Wallet locally
        final curWallet = profileCtrl.walletData.value;
        profileCtrl.setWalletData(curWallet.copyWith(
          points: newPoints,
          balanceWallet: newBalance,
        ));

        pointsController.clear();
        previewBdtAmount.value = 0.0;

        Get.back();
        Get.snackbar(
          'Conversion Successful',
          'Successfully converted $points points to ৳${convertedBdt.toStringAsFixed(2)}.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw Exception(response.data?['message'] ?? 'Conversion failed.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isConverting.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    pointsController.dispose();
    super.onClose();
  }
}
