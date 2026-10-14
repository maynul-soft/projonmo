import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/check_in_controller.dart';
import '../models/vip_reward_model.dart';

class CheckInView extends GetView<CheckInController> {
  const CheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    final userVip = Get.find<AuthController>().currentUser.value?.vipLevel ?? 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.checkIn,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CheckInShimmerView();
        }

        return Column(
          children: [
            // Header info
            Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        AppStrings.checkInTitle,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your Current Level: VIP $userVip',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // VIP Rewards Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.membershipLevel,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        Text(
                          AppStrings.reward,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Table Items
                  Expanded(
                    child: Obx(() => ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: controller.rewards.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, indent: 8, endIndent: 8),
                      itemBuilder: (ctx, idx) {
                        final item = controller.rewards[idx];
                        final isCurrent = item.level == userVip;
                        return _buildRewardRow(item, isCurrent);
                      },
                    )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Receive Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() => ElevatedButton(
              onPressed: controller.isCheckedInToday.value ? null : controller.claimReward,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                controller.isCheckedInToday.value
                    ? 'Claimed Today ✓'
                    : AppStrings.receiveRewardBtn,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )),
          ),
        ],
      );
    }));
  }

  Widget _buildRewardRow(VipRewardModel item, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: isCurrent ? AppColors.goldGradient : null,
                    color: isCurrent ? null : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isCurrent ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${CurrencyFormatter.format(item.dailyReward)} ${AppStrings.perDay}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
                color: isCurrent ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
