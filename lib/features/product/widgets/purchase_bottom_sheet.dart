import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class PurchaseBottomSheet extends GetView<ProductController> {
  final ProductModel product;

  const PurchaseBottomSheet({super.key, required this.product});

  static void show(BuildContext context, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseBottomSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    AppStrings.choosePaymentWallet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // We are forcing the user to ONLY use Balance Wallet as requested
            Obx(() {
              // Force selected wallet to be balance behind the scenes
              controller.selectedWallet.value = 'balance';
              final isSelected = true; // since it's the only option now
              final balance = profileController.walletData.value.balanceWallet;
              return _buildWalletOption(
                title: AppStrings.balanceWallet,
                balance: balance,
                isSelected: isSelected,
                onTap: () {}, // Do nothing, it's always selected
              );
            }),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    AppStrings.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.format(product.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    AppStrings.theAmountActuallyPaid,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.format(product.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Dynamic Action Button
            Obx(() {
              if (controller.isPurchasing.value) {
                return ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                );
              }

              final isRechargeWallet = controller.selectedWallet.value == 'recharge';
              final currentBalance = isRechargeWallet
                  ? profileController.walletData.value.rechargeWallet
                  : profileController.walletData.value.balanceWallet;

              final shortfall = product.price - currentBalance;
              final bool needsRecharge = shortfall > 0;

              // If user does not have enough balance
              if (needsRecharge) {
                return ElevatedButton(
                  onPressed: () {
                    Get.back(); // close the bottom sheet
                    // Navigate to Recharge View (pass amount if needed)
                    Get.toNamed(AppRoutes.recharge, arguments: {'amount': shortfall.toString()});
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Recharge ${CurrencyFormatter.format(shortfall)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                );
              }

              // Otherwise, they have enough balance
              return ElevatedButton(
                onPressed: () => controller.purchaseProduct(product),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  isRechargeWallet ? 'Buy with Recharge' : 'Buy with Balance',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletOption({
    required String title,
    required double balance,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(balance),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
