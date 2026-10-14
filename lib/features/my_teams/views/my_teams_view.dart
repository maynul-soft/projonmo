import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../controllers/team_controller.dart';

class MyTeamsView extends GetView<TeamController> {
  const MyTeamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.myTeamsTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const TeamsShimmerView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Top Summary Card
            _buildTopSummaryCard(context),
            const SizedBox(height: 14),

            // Level B, C, D Counts & Commission Rules Box
            _buildLevelsAndRulesCard(context),
            const SizedBox(height: 14),

            // Action Buttons: Daily commission details & Calculator
            _buildActionButtons(context),
            const SizedBox(height: 16),

            // Team (B+C+D) statistics Grid
            _buildBcdStatisticsGrid(context),
            const SizedBox(height: 16),

            // Level Tabs: B-10% (0) | C-5% (0) | D-2% (0)
            _buildLevelTabs(context),
            const SizedBox(height: 10),

            // Member Validity Tabs: Valid member | Invalid member
            _buildMemberTypeTabs(context),
            const SizedBox(height: 12),

            // Members Table Card
            _buildMembersTable(context),
            const SizedBox(height: 24),
          ],
        ),
      );
    }),
  );
  }

  Widget _buildTopSummaryCard(BuildContext context) {
    return Obx(() {
      final s = controller.teamStats.value;
      return Container(
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
        child: Column(
          children: [
            _buildHeaderRow(AppStrings.totalTeamIncome, CurrencyFormatter.format(s.totalTeamIncome)),
            const Divider(color: Colors.white24, height: 16),
            _buildHeaderRow(AppStrings.validMember, '${s.validMembersCount} ${AppStrings.people}'),
            const Divider(color: Colors.white24, height: 16),
            _buildHeaderRow(AppStrings.teamCumulativeRecharge, CurrencyFormatter.format(s.teamCumulativeRecharge)),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelsAndRulesCard(BuildContext context) {
    return Obx(() {
      final s = controller.teamStats.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Left: A, B, C count pills
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildLevelPill('A', s.countA),
                  const SizedBox(height: 8),
                  _buildLevelPill('B', s.countB),
                  const SizedBox(height: 8),
                  _buildLevelPill('C', s.countC),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(width: 1, height: 100, color: AppColors.border),
            const SizedBox(width: 14),
            // Right: Commission Rules
            const Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.commissionRules,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                  ),
                  SizedBox(height: 6),
                  Text('Stage A: 10%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  SizedBox(height: 4),
                  Text('Stage B: 5%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  SizedBox(height: 4),
                  Text('Stage C: 2%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLevelPill(String level, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.textMuted),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$count ${AppStrings.people}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => Get.toNamed(AppRoutes.dailyCommission),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            backgroundColor: AppColors.accentGold,
            foregroundColor: Colors.white,
          ),
          child: const Text(
            AppStrings.dailyCommissionDetails,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.calculator),
          icon: const Icon(Icons.calculate_outlined, size: 18),
          label: const Text(AppStrings.calculator),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(46),
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildBcdStatisticsGrid(BuildContext context) {
    return Obx(() {
      final s = controller.teamStats.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.teamBcdStatistics,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildBcdStatBox(
                    'A=${s.todayNewA}, B=${s.todayNewB}, C=${s.todayNewC}',
                    AppStrings.todaysNewMembers,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBcdStatBox(
                    'A=${s.yesterdayNewA}, B=${s.yesterdayNewB}, C=${s.yesterdayNewC}',
                    AppStrings.yesterdaysNewMembers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildBcdStatBox(
                    CurrencyFormatter.format(s.todayTopUpAmount),
                    AppStrings.todaysTopUpAmount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBcdStatBox(
                    CurrencyFormatter.format(s.yesterdayRechargeAmount),
                    AppStrings.yesterdaysRechargeAmount,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildBcdStatBox(
                    CurrencyFormatter.format(s.thisMonthRechargeAmount),
                    AppStrings.thisMonthsRechargeAmount,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildBcdStatBox(
                    CurrencyFormatter.format(s.lastMonthRechargeAmount),
                    AppStrings.lastMonthsRechargeAmount,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBcdStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelTabs(BuildContext context) {
    return Obx(() {
      final s = controller.teamStats.value;
      return Row(
        children: [
          _buildPillTab('A-10% (${s.countA})', 'A'),
          const SizedBox(width: 8),
          _buildPillTab('B-5% (${s.countB})', 'B'),
          const SizedBox(width: 8),
          _buildPillTab('C-2% (${s.countC})', 'C'),
        ],
      );
    });
  }

  Widget _buildPillTab(String label, String value) {
    final isSelected = controller.selectedLevelTab.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedLevelTab.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTypeTabs(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildValiditySubTab(AppStrings.validMember, 'valid'),
          _buildValiditySubTab(AppStrings.invalidMember, 'invalid'),
        ],
      ),
    ));
  }

  Widget _buildValiditySubTab(String label, String value) {
    final isSelected = controller.selectedMemberType.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedMemberType.value = value,
        child: Container(
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

  Widget _buildMembersTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(child: Center(child: Text('Max product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Expanded(child: Align(alignment: Alignment.centerRight, child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
              ],
            ),
          ),
          Obx(() {
            final list = controller.filteredMembers;
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Text(AppStrings.noMoreData, style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final m = list[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          m.account,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            m.maxProduct,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.primary),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            m.contact,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.accentBlue),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
