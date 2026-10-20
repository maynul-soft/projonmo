import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/wallet_controller.dart';

class WithdrawView extends GetView<WalletController> {
  const WithdrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : Get.put(ProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileCtrl.fetchCustomerProfile();
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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.main);
            }
          },
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Withdrawable Balance Card (docs.txt: 2. Wallet balance)
            _buildBalanceCard(profileCtrl),
            const SizedBox(height: 18),

            // 2. Select Withdrawal Method (docs.txt: 1. Method list)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Receiving Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1))],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.bankAccount),
                  icon: const Icon(Icons.settings_outlined, size: 15, color: Colors.white),
                  label: const Text('Manage Accounts', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(minimumSize: Size.zero, padding: EdgeInsets.zero),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Obx(() => controller.isLoading.value
                ? _buildUserBankCardsShimmer()
                : _buildUserBankCardsList(context)),
            const SizedBox(height: 18),

            // 3. Withdrawal Amount Input
            const Text(
              'Withdrawal Amount (৳)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1))],
              ),
            ),
            const SizedBox(height: 10),
            _buildAmountInputCard(context, profileCtrl),
            const SizedBox(height: 16),

            // 4. Withdrawal Fee & Settlement Summary (A: 10%, B: 5%, C: 2% commission tiers)
            _buildCalculationSummaryCard(context),
            const SizedBox(height: 24),

            // 5. Submit Withdrawal Button
            _buildSubmitButton(context),
            const SizedBox(height: 20),

            // 6. Withdrawal Rules and Notice
            _buildWithdrawRulesCard(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ProfileController profileCtrl) {
    return Obx(() {
      final balance = profileCtrl.walletData.value.balanceWallet;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF0D9488),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance Wallet',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  (controller.isLoading.value || profileCtrl.isLoading.value)
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: AppShimmer(child: ShimmerLine(width: 120, height: 22)),
                        )
                      : Text(
                          CurrencyFormatter.format(balance),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildUserBankCardsShimmer() {
    return Column(
      children: List.generate(
        2,
        (_) => const ShimmerCard(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          borderRadius: 14,
          child: Row(
            children: [
              ShimmerBox(width: 42, height: 42, borderRadius: 12),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShimmerLine(width: 90, height: 14),
                        SizedBox(width: 8),
                        ShimmerBox(width: 48, height: 16, borderRadius: 4),
                      ],
                    ),
                    SizedBox(height: 6),
                    ShimmerLine(width: 150, height: 12),
                  ],
                ),
              ),
              SizedBox(width: 8),
              ShimmerCircle(size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserBankCardsList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildUserBankCardsShimmer();
      }

      if (controller.userBankCards.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Icon(Icons.credit_card_off_rounded, size: 40, color: AppColors.textMuted),
              const SizedBox(height: 8),
              const Text('No withdrawal accounts linked yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.bankAccount),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Manage Withdrawal Accounts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      }

      final selectedId = controller.selectedWithdrawCardId.value;

      return Column(
        children: controller.userBankCards.map((card) {
          final isSelected = selectedId == card.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.selectWithdrawCard(card);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0D9488) : AppColors.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF0D9488).withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.04),
                        blurRadius: isSelected ? 8 : 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D9488) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCardIcon(card.methodName),
                          color: isSelected ? Colors.white : const Color(0xFF0D9488),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.methodName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFF0F766E) : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${card.accountNumber} (${card.accountHolderName})',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                        color: isSelected ? const Color(0xFF0D9488) : AppColors.textMuted,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAmountInputCard(BuildContext context, ProfileController profileCtrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller.withdrawAmountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('৳', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
              hintText: 'Enter amount (min ৳500)',
              hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted, fontWeight: FontWeight.normal),
              suffixIcon: TextButton(
                onPressed: () {
                  final balance = profileCtrl.walletData.value.balanceWallet;
                  controller.withdrawAmountController.text = balance.toInt().toString();
                },
                child: const Text('ALL', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
              ),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final balance = profileCtrl.walletData.value.balanceWallet;
            return Text(
              'Balance Wallet: ৳${balance.toStringAsFixed(2)} | Min: ৳${controller.minWithdrawAmount.toInt()} | Max: ৳${balance.toInt()}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalculationSummaryCard(BuildContext context) {
    return Obx(() {
      final rateA = controller.commissionRateA.value;
      final rateB = controller.commissionRateB.value;
      final rateC = controller.commissionRateC.value;
      final totalPercent = controller.totalDeductionPercent;

      return AnimatedBuilder(
        animation: controller.withdrawAmountController,
        builder: (context, _) {
          final amountText = controller.withdrawAmountController.text.trim();
          final amount = double.tryParse(amountText) ?? 0.0;
          final feeA = amount * (rateA / 100);
          final feeB = amount * (rateB / 100);
          final feeC = amount * (rateC / 100);
          final totalFee = feeA + feeB + feeC;
          final finalWithdraw = amount > totalFee ? amount - totalFee : 0.0;

          return Container(
            padding: const EdgeInsets.all(14),
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
                const Row(
                  children: [
                    Icon(Icons.calculate_outlined, size: 18, color: Color(0xFF0D9488)),
                    SizedBox(width: 8),
                    Text(
                      'Commission Deductions & Settlement',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level A Commission (${controller.formatRate(rateA)}):',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    Text(
                      '৳${feeA.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level B Commission (${controller.formatRate(rateB)}):',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    Text(
                      '৳${feeB.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level C Commission (${controller.formatRate(rateC)}):',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    Text(
                      '৳${feeC.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Deductions (${controller.formatRate(totalPercent)}):',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.accentRed)),
                    Text(
                      '- ৳${totalFee.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.accentRed),
                    ),
                  ],
                ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Final Received Amount:',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text(
                    '৳${finalWithdraw.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Arrival Time:', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  Text('Within 24 Hours', style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
        );
      },
    );
  });
}

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isSubmittingWithdraw.value;

      return SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.submitWithdraw,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text(
                  'Confirm & Request Withdrawal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      );
    });
  }

  Widget _buildWithdrawRulesCard(BuildContext context) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rule_rounded, color: Color(0xFF0D9488), size: 18),
              SizedBox(width: 8),
              Text(
                'Withdrawal Rules & Instructions',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Withdrawals are processed 7 days a week, 10:00 AM – 10:00 PM.\n'
            '2. Minimum withdrawal amount is ৳500 and maximum per request is ৳50,000.\n'
            '3. Please ensure the bKash/Nagad or bank account details are 100% correct.\n'
            '4. Total ${controller.formatRate(controller.totalDeductionPercent)} commission deduction (Level A: ${controller.formatRate(controller.commissionRateA.value)}, Level B: ${controller.formatRate(controller.commissionRateB.value)}, Level C: ${controller.formatRate(controller.commissionRateC.value)}) is applied automatically.\n'
            '5. Funds usually arrive within 10 to 60 minutes after admin approval.',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    ));
  }

  IconData _getCardIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bkash')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('nagad')) return Icons.monetization_on_rounded;
    if (lower.contains('rocket')) return Icons.send_rounded;
    if (lower.contains('bank')) return Icons.account_balance_rounded;
    return Icons.payment_rounded;
  }
}
