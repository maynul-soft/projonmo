import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/network.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/purchased_product_model.dart';

class MyProductsController extends GetxController {
  final activeTab = 'unexpired'.obs; // 'unexpired' or 'expired'
  final currentTime = DateTime.now().obs;
  final claimingProductId = ''.obs;
  Timer? _timer;

  final purchasedProducts = <PurchasedProductModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshMyProducts();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentTime.value = DateTime.now();
    });
  }

  Future<void> refreshMyProducts() async {
    isLoading.value = true;
    await _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(
        '/customer/products/mine',
      );

      dynamic rawList;
      if (response.data != null) {
        if (response.data is List) {
          rawList = response.data;
        } else if (response.data is Map) {
          final resMap = Map<String, dynamic>.from(response.data as Map);
          if (resMap['data'] is List) {
            rawList = resMap['data'];
          } else if (resMap['products'] is List) {
            rawList = resMap['products'];
          }
        }
      }

      if (rawList is List) {
        final List<PurchasedProductModel> fetched = [];
        for (final item in rawList) {
          if (item is Map) {
            try {
              fetched.add(PurchasedProductModel.fromJson(Map<String, dynamic>.from(item)));
            } catch (e) {
              debugPrint('[MyProductsController] Error parsing product item: $e');
            }
          }
        }
        purchasedProducts.assignAll(fetched);
      }
    } catch (e) {
      debugPrint('[MyProductsController] Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<PurchasedProductModel> get unexpiredList =>
      purchasedProducts.where((p) => !p.isExpired).toList();

  List<PurchasedProductModel> get expiredList =>
      purchasedProducts.where((p) => p.isExpired).toList();

  double get incomeToday {
    return purchasedProducts.fold(0.0, (sum, p) => sum + p.dailyIncome);
  }

  double get totalEarningsReceived {
    return purchasedProducts.fold(0.0, (sum, p) => sum + p.alreadyReceived);
  }

  /// Hook for API response
  void setPurchasedProducts(List<PurchasedProductModel> list) {
    purchasedProducts.assignAll(list);
  }

  void addProduct(PurchasedProductModel product) {
    purchasedProducts.insert(0, product);
  }

  String formatCountdown(PurchasedProductModel p) {
    if (p.isExpired) return 'Expired';
    if (!p.canReceive && p.lastClaimedAt == null && p.isClaimed) {
      return AppStrings.alreadyReceived;
    }
    final remaining = p.remainingTime;
    if (remaining == Duration.zero) return AppStrings.receiveBtn;
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds ${AppStrings.receiveBtn}';
  }

  Future<void> receiveIncome(PurchasedProductModel product) async {
    if (product.isExpired) {
      Get.snackbar(
        'Expired',
        'This product contract has ended.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!product.canReceive) {
      Get.snackbar(
        'Notice',
        'You have already received today\'s income for this product.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      claimingProductId.value = product.id;

      // POST API call using endpoint design
      // Endpoint: /api/v1/customer/products/{product_id}/claim-income
      final response = await ApiClient.instance.post('/customer/products/${product.id}/claim-income');

      final resData = response.data;
      if (resData is Map && resData['success'] == true) {
        final data = resData['data'] ?? {};
        final double claimedAmount = (data['claimedAmount'] as num?)?.toDouble() ?? product.dailyIncome;

        // Find and update the specific product locally
        final index = purchasedProducts.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          final updated = product.copyWith(
            alreadyReceived: product.alreadyReceived + claimedAmount,
            daysPassed: product.daysPassed + 1,
            lastClaimedAt: DateTime.now(),
            isClaimed: true,
            totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? product.totalEarnings,
          );
          purchasedProducts[index] = updated;

          // Credit wallet in local profile controller for UI updates
          final profileCtrl = Get.find<ProfileController>();

          if (data['currentBalance'] != null) {
            final newBalance = (data['currentBalance'] as num).toDouble();
            final curWallet = profileCtrl.walletData.value;
            profileCtrl.setWalletData(curWallet.copyWith(
              balanceWallet: newBalance,
              totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? curWallet.totalEarnings,
            ));
          } else {
            profileCtrl.addEarnings(claimedAmount);
          }

          Get.snackbar(
            AppStrings.success,
            resData['message']?.toString() ?? '${AppStrings.claimIncomeSuccess} +৳$claimedAmount',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
          );
        }
      } else {
        throw ApiException(message: resData['message']?.toString() ?? 'Failed to claim daily income');
      }
    } on ApiException catch (e) {
      Get.snackbar('Notice', e.message, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim income: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      claimingProductId.value = '';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
