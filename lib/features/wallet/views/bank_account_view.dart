import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../controllers/wallet_controller.dart';
import '../models/user_bank_card_model.dart';

class BankAccountView extends GetView<WalletController> {
  const BankAccountView({super.key});

  @override
  Widget build(BuildContext context) {
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
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Bank / Wallet Accounts',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Add Account',
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 26),
            onPressed: () => _showAddMethodModal(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const BankAccountShimmerView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Info Header Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked Withdrawal Accounts',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Add and manage your bKash, Nagad, and Bank accounts for instant withdrawals.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Accounts List Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Receiving Accounts',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1))],
                  ),
                ),
                Obx(() => Text(
                  '${controller.userBankCards.length} Accounts',
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                )),
              ],
            ),
            const SizedBox(height: 10),

            // Accounts List
            Obx(() {
              if (controller.userBankCards.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No Accounts Added Yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add your bKash, Nagad, or Bank account to receive withdrawals.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () => _showAddMethodModal(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Account Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: controller.userBankCards.map((card) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCardIcon(card.methodName),
                                color: AppColors.primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        card.methodName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                      ),
                                      if (card.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    card.accountNumber,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Delete Account',
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed, size: 20),
                              onPressed: () => _confirmDeleteAccount(card),
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Holder: ${card.accountHolderName}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),

            // Bottom Add Account Button
            ElevatedButton.icon(
              onPressed: () => _showAddMethodModal(context),
              icon: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
              label: const Text(
                'Add New Withdrawal Account',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    }));
  }

  void _confirmDeleteAccount(UserBankCardModel card) {
    Get.defaultDialog(
      title: 'Remove Account',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'Are you sure you want to remove ${card.methodName} (${card.accountNumber})?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
      textCancel: 'Cancel',
      textConfirm: 'Remove',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.accentRed,
      onConfirm: () {
        Get.back(); // close the dialog first
        controller.deleteUserBankCard(card.id);
      },
    );
  }

  void _showAddMethodModal(BuildContext context) {
    final methodId = 'bkash'.obs;
    final accountNumController = TextEditingController();
    final holderNameController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Withdrawal Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Select Gateway Type', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  _buildTypeChip('bKash', 'bkash', methodId),
                  const SizedBox(width: 8),
                  _buildTypeChip('Nagad', 'nagad', methodId),
                  const SizedBox(width: 8),
                  _buildTypeChip('Rocket', 'rocket', methodId),
                ],
              )),
              const SizedBox(height: 16),
              TextField(
                controller: accountNumController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Account / Wallet Number',
                  hintText: 'e.g. 018XXXXXXXX',
                  prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: holderNameController,
                decoration: const InputDecoration(
                  labelText: 'Account Holder Full Name',
                  hintText: 'As registered on wallet/bank',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 12),
              // OTP Field
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller.addAccountOtpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'OTP Code',
                        hintText: '6-digit OTP',
                        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Obx(() {
                      final isSending = controller.isSendingAddAccountOtp.value;
                      return SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSending ? null : () => controller.sendAddAccountOtp(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceMuted,
                            foregroundColor: AppColors.primaryDark,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isSending
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Send OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final number = accountNumController.text.trim();
                  final holder = holderNameController.text.trim();
                  final otp = controller.addAccountOtpController.text.trim();
                  if (number.isEmpty || holder.isEmpty) {
                    Get.snackbar('Missing Info', 'Please enter account number and holder name.');
                    return;
                  }
                  if (otp.length < 6) {
                    Get.snackbar('Invalid OTP', 'Please enter a valid 6-digit OTP code.');
                    return;
                  }
                  final newCard = UserBankCardModel(
                    id: 'card_${DateTime.now().millisecondsSinceEpoch}',
                    methodId: methodId.value,
                    methodName: '${methodId.value.capitalizeFirst} Personal',
                    accountNumber: number,
                    accountHolderName: holder,
                    isDefault: controller.userBankCards.isEmpty,
                  );
                  controller.addUserBankCard(newCard, otp);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Save Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeChip(String label, String id, RxString selected) {
    final isSel = selected.value == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => selected.value = id,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSel ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCardIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bkash')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('nagad')) return Icons.payments_rounded;
    if (lower.contains('rocket')) return Icons.flash_on_rounded;
    return Icons.account_balance_rounded;
  }
}
