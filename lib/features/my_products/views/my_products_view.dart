import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../controllers/my_products_controller.dart';
import '../models/purchased_product_model.dart';

class MyProductsView extends GetView<MyProductsController> {
  const MyProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshMyProducts();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.myProducts,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MyProductsShimmerView();
        }

        return Column(
          children: [
            // Top Summary Banner Card
            _buildSummaryHeader(context),

            // Unexpired vs Expired Tab Toggle
            _buildTabSelector(context),

            // Product List
            Expanded(
              child: Obx(() {
                final isUnexpired = controller.activeTab.value == 'unexpired';
                final claimingId = controller.claimingProductId.value;
                final tick = controller.currentTime.value;
                final list = isUnexpired ? controller.unexpiredList : controller.expiredList;

                // Fallback to purchasedProducts if unexpired list is empty
                final displayList = (list.isEmpty && isUnexpired && controller.purchasedProducts.isNotEmpty)
                    ? controller.purchasedProducts
                    : list;

                if (displayList.isEmpty) {
                  return const Center(
                    child: Text(
                      AppStrings.noMoreData,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: displayList.length,
                  itemBuilder: (ctx, idx) => _buildPurchasedCard(context, displayList[idx]),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildHeaderItem(AppStrings.incomeToday, CurrencyFormatter.format(controller.incomeToday))),
          Container(width: 1, height: 40, color: Colors.white24),
          Expanded(child: _buildHeaderItem(AppStrings.totalEarnings, CurrencyFormatter.format(controller.totalEarningsReceived))),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String title, String amount) {
    return Column(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector(BuildContext context) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(AppStrings.unexpiredProduct, 'unexpired'),
          _buildTabItem(AppStrings.expiredProduct, 'expired'),
        ],
      ),
    ));
  }

  Widget _buildTabItem(String label, String value) {
    final isSelected = controller.activeTab.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.activeTab.value = value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasedCard(BuildContext context, PurchasedProductModel product) {
    final canClaim = product.canReceive;
    final isExpired = product.isExpired;
    final countdownText = controller.formatCountdown(product);
    final isClaiming = controller.claimingProductId.value == product.id;

    IconData buttonIcon;
    if (isExpired) {
      buttonIcon = Icons.event_busy_rounded;
    } else if (canClaim) {
      buttonIcon = Icons.download_done_rounded;
    } else {
      buttonIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.eco_rounded, size: 36, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    _buildRow(AppStrings.price, CurrencyFormatter.format(product.price)),
                    _buildRow(AppStrings.everyDayIncome, CurrencyFormatter.format(product.dailyIncome)),
                    _buildRow(AppStrings.validityPeriod, '${product.daysPassed}/${product.validityDays}'),
                    _buildRow(AppStrings.totalEarnings, CurrencyFormatter.format(product.totalEarnings)),
                    _buildRow(AppStrings.alreadyReceived, CurrencyFormatter.format(product.alreadyReceived), isHighlight: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 24h Countdown & Receive Button with Loading and Inactive States
          ElevatedButton(
            onPressed: isExpired || isClaiming || !canClaim ? null : () => controller.receiveIncome(product),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: canClaim && !isClaiming ? AppColors.primary : AppColors.surfaceMuted,
              foregroundColor: canClaim && !isClaiming ? Colors.white : AppColors.textSecondary,
              disabledBackgroundColor: AppColors.surfaceMuted,
              disabledForegroundColor: AppColors.textSecondary,
              elevation: canClaim && !isClaiming ? 2 : 0,
              side: canClaim && !isClaiming ? null : const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: isClaiming
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        buttonIcon,
                        size: 18,
                        color: canClaim ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            countdownText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: canClaim ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isHighlight ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
