import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../controllers/vip_salary_controller.dart';
import '../models/vip_level_model.dart';
import '../widgets/salary_status_card.dart';

class WeeklySalaryView extends StatelessWidget {
  const WeeklySalaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VipSalaryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchSalaryDetails('weekly');
      controller.fetchVipLevels();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Weekly Salary',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoadingLevels = controller.isLoading.value;
        final levels = controller.vipLevels.toList();

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.fetchSalaryDetails('weekly'),
              controller.fetchVipLevels(),
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            children: [
              // Top Salary Status & Claim Card
              SalaryStatusCard(
                salary: controller.weeklySalary.value,
                isLoading: controller.isWeeklyLoading.value,
                controller: controller,
                type: 'weekly',
              ),

              // Section Title
              const Padding(
                padding: EdgeInsets.only(bottom: 12, top: 4),
                child: Text(
                  'VIP Levels & Weekly Salary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // VIP Levels List
              if (isLoadingLevels && levels.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else
                ...levels.map((level) => _buildSalaryCard(level)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSalaryCard(VipLevelModel level) {
    final isLocked = !level.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: level.isCurrent
              ? AppColors.primary
              : isLocked
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.3),
          width: level.isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: level.isCurrent
                ? AppColors.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLocked ? AppColors.surfaceMuted : AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline_rounded : Icons.star_rounded,
                      color: isLocked ? AppColors.textMuted : AppColors.primaryDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    level.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? AppColors.textSecondary : AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Text(
                '৳${level.weeklySalary.toStringAsFixed(0)} / Week',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),

          // Status Badges (NO claim button here!)
          if (level.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 15, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Current Tier Active',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
            )
          else if (isLocked)
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Need ${level.remainingToUnlock} more members to unlock (Required: ${level.requiredTeam})',
                    style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 15, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  'Unlocked (${level.requiredTeam} members reached)',
                  style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
