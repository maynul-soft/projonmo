import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Banner Card
              _buildUserHeaderCard(context, authController),
              const SizedBox(height: 14),

              // Action Buttons: Recharge & Withdraws
              _buildTopActionButtons(context),
              const SizedBox(height: 14),

              // Professional Dashboard Stats Grid
              _buildDashboardStatsGrid(context),
              const SizedBox(height: 16),

              // Services Grid (Directly displays the service items without the service/svip toggle tab)
              _buildServicesGrid(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard(BuildContext context, AuthController auth) {
    return Obx(() {
      final user = auth.currentUser.value;
      final phone = user?.phone ?? '8801609157849';
      final memberId = user?.memberId ?? '702426';
      final isLoading = controller.isLoading.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Shield Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          AppAssets.appLogo,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.eco_rounded, color: AppColors.primary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isLoading
                          ? AppShimmer(
                              baseColor: Colors.white.withValues(alpha: 0.3),
                              highlightColor: Colors.white.withValues(alpha: 0.7),
                              child: Container(
                                width: 110,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            )
                          : Text(
                              phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                      const SizedBox(height: 4),
                      isLoading
                          ? AppShimmer(
                              baseColor: Colors.white.withValues(alpha: 0.2),
                              highlightColor: Colors.white.withValues(alpha: 0.5),
                              child: Container(
                                width: 75,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : Text(
                              '${AppStrings.memberIdPrefix}$memberId',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                    ],
                  ),
                ),
                // VIP Shield Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white54, width: 1.5),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'VIP 1',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Management Team Banner Tag
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.myTeams),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.groups_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppStrings.managementTeam,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTopActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.recharge),
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.white),
            label: const Text(AppStrings.rechargeBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.withdraw),
            icon: const Icon(Icons.payments_rounded, size: 18, color: Colors.white),
            label: const Text(AppStrings.withdrawBtn),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488), // Refined Teal
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStatsGrid(BuildContext context) {
    return Obx(() {
      final data = controller.walletData.value;
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  AppStrings.rechargeWallet,
                  CurrencyFormatter.format(data.rechargeWallet),
                  const Color(0xFF10B981),
                  Icons.account_balance_wallet_outlined,
                  onTap: () => Get.toNamed(AppRoutes.recharge),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  AppStrings.balanceWallet,
                  CurrencyFormatter.format(data.balanceWallet),
                  const Color(0xFF059669),
                  Icons.savings_outlined,
                  onTap: () => Get.toNamed(AppRoutes.fundingDetails),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  AppStrings.totalEarnings,
                  CurrencyFormatter.format(data.totalEarnings),
                  const Color(0xFF0D9488),
                  Icons.trending_up_rounded,
                  onTap: () => Get.toNamed(AppRoutes.fundingDetails),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  AppStrings.totalWithdrawals,
                  CurrencyFormatter.format(data.totalWithdrawals),
                  const Color(0xFF2563EB),
                  Icons.outbox_rounded,
                  onTap: () => Get.toNamed(AppRoutes.withdraw),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  AppStrings.teamIncome,
                  CurrencyFormatter.format(data.teamIncome),
                  const Color(0xFF7C3AED),
                  Icons.groups_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  AppStrings.incomeToday,
                  CurrencyFormatter.format(data.incomeToday),
                  const Color(0xFFD97706),
                  Icons.today_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  AppStrings.yesterdaysEarnings,
                  CurrencyFormatter.format(data.yesterdaysEarnings),
                  const Color(0xFF047857),
                  Icons.history_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  AppStrings.points,
                  '${data.points} Pts',
                  const Color(0xFFEA580C),
                  Icons.stars_rounded,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildMetricCard(String label, String value, Color accentColor, IconData icon, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 6),
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: AppShimmer(child: ShimmerLine(width: 65, height: 15)),
              );
            }
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            );
          }),
        ],
      ),
    ),
    ),
    );
  }



  Widget _buildServicesGrid(BuildContext context) {
    final services = [
      {'title': AppStrings.myProducts, 'icon': Icons.inventory_2_outlined, 'action': () => Get.toNamed(AppRoutes.myProducts)},
      {'title': AppStrings.fundingDetails, 'icon': Icons.receipt_long_outlined, 'action': () => Get.toNamed(AppRoutes.fundingDetails)},
      // {'title': AppStrings.redeemBonus, 'icon': Icons.card_giftcard_outlined, 'action': () => Get.snackbar('Redeem Bonus', 'Enter promotional code to redeem bonus.')},
      {'title': AppStrings.bankAccount, 'icon': Icons.account_balance_outlined, 'action': () => Get.toNamed(AppRoutes.bankAccount)},
      // {'title': AppStrings.checkIn, 'icon': Icons.event_available_outlined, 'action': () => Get.toNamed(AppRoutes.checkIn)},
      // {'title': AppStrings.contract, 'icon': Icons.description_outlined, 'action': () => Get.snackbar('Contract', 'Projonmo VIP Investment Certificate.')},
      {'title': AppStrings.password, 'icon': Icons.lock_reset_outlined, 'action': () => Get.toNamed(AppRoutes.changePassword)},
      {'title': AppStrings.calculator, 'icon': Icons.calculate_outlined, 'action': () => Get.toNamed(AppRoutes.calculator)},
      {'title': AppStrings.telegramChannel, 'icon': Icons.send_rounded, 'action': controller.openTelegramChannel},
      {'title': AppStrings.signOut, 'icon': Icons.logout_rounded, 'action': controller.showSignOutConfirmation},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 8,
          childAspectRatio: 0.78,
        ),
        itemCount: services.length,
        itemBuilder: (ctx, idx) {
          final s = services[idx];
          final isSignOut = s['title'] == AppStrings.signOut;

          return InkWell(
            onTap: s['action'] as VoidCallback,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isSignOut
                        ? AppColors.accentRed.withValues(alpha: 0.1)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    s['icon'] as IconData,
                    size: 22,
                    color: isSignOut ? AppColors.accentRed : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: isSignOut ? AppColors.accentRed : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
