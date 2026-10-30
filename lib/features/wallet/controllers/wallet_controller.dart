import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../../routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/payment_method_model.dart';
import '../models/user_bank_card_model.dart';
import '../models/withdrawal_preview_model.dart';
import '../models/withdrawal_record_model.dart';

class WalletController extends GetxController {
  // Admin created deposit payment gateways
  final depositMethods = <PaymentMethodModel>[].obs;

  // Selected deposit payment method & ID
  final selectedDepositMethod = Rxn<PaymentMethodModel>();
  final selectedDepositMethodId = ''.obs;

  // Quick preset recharge amounts
  final presetAmounts = <double>[500, 1000, 2000, 5000, 10000, 20000];

  // Deposit Form Controllers
  final depositAmountController = TextEditingController();
  final senderPhoneController = TextEditingController();
  final transactionIdController = TextEditingController();
  final isSubmittingDeposit = false.obs;

  // Selected withdrawal source wallet: 'balance' or 'recharge'
  final selectedWithdrawWallet = 'balance'.obs;

  // User created withdrawal payment methods / accounts (docs.txt: User withdraw korar janno multiple payment method create and update korte parbe)
  final userBankCards = <UserBankCardModel>[
    UserBankCardModel(
      id: 'card_1',
      methodId: 'bkash',
      methodName: 'bKash Personal',
      accountNumber: '01812998877',
      accountHolderName: 'Maynul Hasan',
      isDefault: true,
    ),
    UserBankCardModel(
      id: 'card_2',
      methodId: 'nagad',
      methodName: 'Nagad Personal',
      accountNumber: '01711882233',
      accountHolderName: 'Maynul Hasan',
      isDefault: false,
    ),
  ].obs;

  // Selected withdrawal method & ID (Re-using depositMethods list for gateways)
  final selectedWithdrawMethod = Rxn<PaymentMethodModel>();
  final selectedWithdrawMethodId = ''.obs;

  // Withdrawal Form Controllers
  final withdrawAmountController = TextEditingController();
  final withdrawAccountController = TextEditingController();
  final withdrawPasswordController = TextEditingController();
  final isSubmittingWithdraw = false.obs;

  // Shimmer loading state (2 seconds)
  final isLoading = true.obs;

  // Withdrawal Rules info & Dynamic Commission Tier Deductions
  final minWithdrawAmount = 500.0;
  final maxWithdrawAmount = 50000.0;
  final commissionRateA = 7.0.obs;
  final commissionRateB = 2.0.obs;
  final commissionRateC = 1.0.obs;
  final isCommissionSettingsLoaded = false.obs;

  // Withdrawal Preview
  final withdrawalPreview = Rxn<WithdrawalPreviewModel>();
  final isPreviewLoading = false.obs;
  final previewError = RxnString();
  Timer? _withdrawDebounce;
  double? _lastPreviewAmount;

  // Withdrawal History
  final withdrawalHistory = <WithdrawalRecordModel>[].obs;
  final isHistoryLoading = false.obs;

  // Withdrawal OTP Cooldown & Double Submission Guard
  final withdrawOtpCountdown = 0.obs;
  Timer? _withdrawOtpTimer;
  DateTime? _lastWithdrawSubmitTime;

  double get totalDeductionPercent =>
      commissionRateA.value + commissionRateB.value + commissionRateC.value;

  String formatRate(double rate) {
    if (rate == rate.toInt()) {
      return '${rate.toInt()}%';
    }
    return '${rate.toStringAsFixed(1)}%';
  }

  @override
  void onInit() {
    super.onInit();
    withdrawAmountController.addListener(_onWithdrawAmountChanged);
    _initData();
  }

  @override
  void onClose() {
    _withdrawDebounce?.cancel();
    _withdrawOtpTimer?.cancel();
    withdrawAmountController.removeListener(_onWithdrawAmountChanged);
    super.onClose();
  }

  void _onWithdrawAmountChanged() {
    if (_withdrawDebounce?.isActive ?? false) {
      _withdrawDebounce!.cancel();
    }
    final text = withdrawAmountController.text.trim();
    if (text.isEmpty) {
      withdrawalPreview.value = null;
      previewError.value = null;
      return;
    }

    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      withdrawalPreview.value = null;
      previewError.value = null;
      return;
    }

    _withdrawDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchWithdrawalPreview(amount);
    });
  }

  Future<void> fetchWithdrawalPreview(double amount) async {
    _lastPreviewAmount = amount;
    try {
      isPreviewLoading.value = true;
      previewError.value = null;

      final response = await ApiClient.instance.get(
        ApiEndpoints.customerWithdrawalPreview,
        queryParameters: {'amount': amount},
      );

      if (_lastPreviewAmount != amount) return;

      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          withdrawalPreview.value = WithdrawalPreviewModel.fromJson(
            Map<String, dynamic>.from(resMap['data'] as Map),
          );
        } else {
          withdrawalPreview.value = null;
          previewError.value = resMap['message']?.toString() ?? 'Failed to preview fees';
        }
      }
    } catch (e) {
      if (_lastPreviewAmount != amount) return;
      debugPrint('[WalletController] Error previewing withdrawal: $e');
      withdrawalPreview.value = null;
      previewError.value = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
    } finally {
      if (_lastPreviewAmount == amount) {
        isPreviewLoading.value = false;
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    fetchCommissionSettings();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    await Future.wait([
      fetchPaymentMethods(),
      fetchWithdrawalMethods(),
      fetchCommissionSettings(),
      fetchWithdrawalHistory(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      isHistoryLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.customerWithdrawals);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final listRaw = resMap['data'];
          if (listRaw is List) {
            final fetched = listRaw.map((item) {
              if (item is Map) {
                return WithdrawalRecordModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            }).whereType<WithdrawalRecordModel>().toList();

            withdrawalHistory.assignAll(fetched);
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletController] Error fetching withdrawal history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> fetchCommissionSettings() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicCalculatorSettings);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final data = Map<String, dynamic>.from(resMap['data'] as Map);
          final stageA = (data['level1'] ?? data['A'] ?? data['teamStages']?['A'] as num?)?.toDouble();
          final stageB = (data['level2'] ?? data['B'] ?? data['teamStages']?['B'] as num?)?.toDouble();
          final stageC = (data['level3'] ?? data['C'] ?? data['teamStages']?['C'] as num?)?.toDouble();
          if (stageA != null) commissionRateA.value = stageA;
          if (stageB != null) commissionRateB.value = stageB;
          if (stageC != null) commissionRateC.value = stageC;
          isCommissionSettingsLoaded.value = true;
        }
      }
    } catch (e) {
      debugPrint('[WalletController] Error fetching commission settings: $e');
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.customerPaymentMethods);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final listRaw = resMap['data'];
          if (listRaw is List) {
            final fetched = listRaw.map((item) {
              if (item is Map) {
                return PaymentMethodModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            }).whereType<PaymentMethodModel>().toList();
            
            depositMethods.assignAll(fetched);
            
            if (depositMethods.isNotEmpty) {
              selectedDepositMethod.value = depositMethods.first;
              selectedDepositMethodId.value = depositMethods.first.id;

              selectedWithdrawMethod.value = depositMethods.first;
              selectedWithdrawMethodId.value = depositMethods.first.id;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletController] Error fetching payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void triggerLoading() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }



  void selectDepositMethod(PaymentMethodModel method) {
    selectedDepositMethod.value = method;
    selectedDepositMethodId.value = method.id;
  }

  void setDepositAmount(double amount) {
    depositAmountController.text = amount.toStringAsFixed(0);
  }

  // Selected withdrawal method card & ID
  final selectedWithdrawCard = Rxn<UserBankCardModel>();
  final selectedWithdrawCardId = ''.obs;

  void selectWithdrawCard(UserBankCardModel card) {
    selectedWithdrawCard.value = card;
    selectedWithdrawCardId.value = card.id;
  }

  final addAccountOtpController = TextEditingController();
  final isSendingAddAccountOtp = false.obs;
  final isAddingBankCard = false.obs;

  Future<void> sendAddAccountOtp() async {
    try {
      isSendingAddAccountOtp.value = true;
      // As per requirement: POST /api/v1/customer/withdrawal-methods/send-otp
      await ApiClient.instance.post('${ApiEndpoints.customerWithdrawalMethods}/send-otp');
      Get.snackbar('OTP Sent', 'Please check your phone for the 6-digit OTP code.', backgroundColor: Colors.white);
    } catch (e) {
      Get.snackbar('Failed to Send OTP', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSendingAddAccountOtp.value = false;
    }
  }

  /// Add new bank/wallet account for user
  Future<void> addUserBankCard(UserBankCardModel card, String otp) async {
    if (isAddingBankCard.value) return;

    try {
      isAddingBankCard.value = true;
      isLoading.value = true;

      // Close bottom sheet if open so background list shows loading shimmer immediately
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      final payload = {
        "method": card.methodName,
        "accountNo": card.accountNumber,
        "accountName": card.accountHolderName,
        "isDefault": card.isDefault,
        "otp": otp
      };

      await ApiClient.instance.post(
        ApiEndpoints.customerWithdrawalMethods,
        data: payload,
      );

      // In GetX, for instant feedback, we can optimistically add it
      // However, fetching from API ensures we get the real ID generated by the DB.
      await fetchWithdrawalMethods();
      addAccountOtpController.clear();
      
      Get.snackbar(
        'Account Added',
        'Withdrawal account has been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
    } catch (e) {
      debugPrint('[WalletController] Error adding withdrawal method: $e');
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      isAddingBankCard.value = false;
    }
  }

  Future<void> deleteUserBankCard(String id) async {
    try {
      isLoading.value = true;
      // In GetX, it's better to manually remove it from the observable list for instant UI feedback
      userBankCards.removeWhere((c) => c.id == id);
      
      await ApiClient.instance.delete(ApiEndpoints.customerDeleteWithdrawalMethod(id));
      await fetchWithdrawalMethods();
      Get.snackbar(
        'Account Removed', 
        'Withdrawal account deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('[WalletController] Error deleting withdrawal method: $e');
      Get.snackbar('Error', 'Failed to delete account. Try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setBankCardAsDefault(UserBankCardModel card) async {
    try {
      isLoading.value = true;
      // Depending on API, you might need a separate endpoint or just PUT/PATCH the same creation endpoint.
      // Assuming a generic update pattern:
      final payload = {
        "method": card.methodName,
        "accountNo": card.accountNumber,
        "accountName": card.accountHolderName,
        "isDefault": true
      };
      
      // We will attempt to POST/PATCH it to update. If backend doesn't support this specific ID based update, you'd need the exact endpoint.
      // Assuming POST handles upsert or there is a PUT:
      await ApiClient.instance.post(ApiEndpoints.customerWithdrawalMethods, data: payload);
      await fetchWithdrawalMethods();
      Get.snackbar('Default Updated', '${card.methodName} is now your default account.');
    } catch (e) {
      debugPrint('[WalletController] Error updating default: $e');
      Get.snackbar('Error', 'Failed to set default. Try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWithdrawalMethods() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.customerWithdrawalMethods);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final listRaw = resMap['data'];
          if (listRaw is List) {
            final fetched = listRaw.map((item) {
              if (item is Map) {
                return UserBankCardModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            }).whereType<UserBankCardModel>().toList();

            userBankCards.assignAll(fetched);

            if (fetched.isNotEmpty) {
              final defaultCard = fetched.firstWhere((c) => c.isDefault, orElse: () => fetched.first);
              selectedWithdrawCard.value = defaultCard;
              selectedWithdrawCardId.value = defaultCard.id;
            } else {
              selectedWithdrawCard.value = null;
              selectedWithdrawCardId.value = '';
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[WalletController] Error fetching withdrawal methods: $e');
    }
  }

  /// Submit Deposit to /api/v1/customer/deposits
  Future<void> submitDeposit() async {
    final amountText = depositAmountController.text.trim();
    final trxId = transactionIdController.text.trim();

    if (amountText.isEmpty) {
      Get.snackbar('Invalid Amount', 'Please specify or select a deposit amount.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid numeric deposit amount.');
      return;
    }

    final selectedMethod = selectedDepositMethod.value;
    if (selectedMethod == null) {
      Get.snackbar('Missing Payment Method', 'Please select a payment method.');
      return;
    }

    if (amount < selectedMethod.minAmount) {
      Get.snackbar('Minimum Deposit', 'Minimum deposit is ৳${selectedMethod.minAmount.toStringAsFixed(0)}');
      return;
    }

    if (trxId.isEmpty) {
      Get.snackbar('Missing TrxID', 'Please enter the transaction ID (TrxID) from your payment receipt.');
      return;
    }

    try {
      isSubmittingDeposit.value = true;
      
      final payload = {
        "amount": amount.toStringAsFixed(2), // can be string or number based on API
        "method": selectedMethod.id,
        "txnId": trxId,
        "proofUrl": ""
      };

      final response = await ApiClient.instance.post(
        ApiEndpoints.customerDeposits,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        depositAmountController.clear();
        transactionIdController.clear();
        
        // Let user know it's pending review
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 50),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Deposit Submitted!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your deposit of ৳${amount.toStringAsFixed(0)} with TrxID "$trxId" has been submitted successfully and is pending review by Admin.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back(); // close dialog
                        Get.back(); // close recharge view
                      },
                      child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      debugPrint('[WalletController] Error submitting deposit: $e');
      Get.snackbar(
        'Submission Failed', 
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSubmittingDeposit.value = false;
    }
  }

  void _startWithdrawOtpCooldown([int seconds = 60]) {
    withdrawOtpCountdown.value = seconds;
    _withdrawOtpTimer?.cancel();
    _withdrawOtpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (withdrawOtpCountdown.value > 0) {
        withdrawOtpCountdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Submit Withdraw
  Future<void> submitWithdraw() async {
    // 1. Strict double-click & in-flight request guard
    if (isSubmittingWithdraw.value) return;

    final now = DateTime.now();
    if (_lastWithdrawSubmitTime != null &&
        now.difference(_lastWithdrawSubmitTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastWithdrawSubmitTime = now;

    final selectedCard = selectedWithdrawCard.value;
    if (selectedCard == null) {
      Get.snackbar('Select Account', 'Please select or add a withdrawal payment method.');
      return;
    }

    final amountText = withdrawAmountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Invalid Amount', 'Please enter the amount you want to withdraw.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter a valid numeric amount.');
      return;
    }

    if (amount < minWithdrawAmount) {
      Get.snackbar('Minimum Withdrawal', 'Minimum withdrawal amount is ৳${minWithdrawAmount.toStringAsFixed(0)}.');
      return;
    }

    final profileCtrl = Get.find<ProfileController>();
    final balanceWallet = profileCtrl.walletData.value.balanceWallet;

    if (amount > balanceWallet) {
      Get.snackbar(
        'Insufficient Balance',
        'Your wallet balance is ৳${balanceWallet.toStringAsFixed(2)}. You can withdraw a maximum of ৳${balanceWallet.toStringAsFixed(2)}.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmittingWithdraw.value = true;
      Get.closeAllSnackbars();

      // Request OTP from server
      await ApiClient.instance.post(ApiEndpoints.customerWithdrawalSendOtp);

      // Start 60-second cooldown timer for resending OTP
      _startWithdrawOtpCooldown(60);

      // Only navigate to OTP verification view when OTP was successfully sent
      Get.toNamed(AppRoutes.withdrawOtp, arguments: {
        'amount': amount,
        'selectedCard': selectedCard,
      });
    } on ApiException catch (e) {
      debugPrint('[WalletController] send-otp ApiException: ${e.message}');
      Get.snackbar(
        'OTP Request Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      debugPrint('[WalletController] send-otp Error: $e');
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
      Get.snackbar(
        'OTP Request Failed',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSubmittingWithdraw.value = false;
    }
  }

  final isResendingOtp = false.obs;
  Future<void> resendWithdrawOtp() async {
    if (isResendingOtp.value || withdrawOtpCountdown.value > 0) return;

    try {
      isResendingOtp.value = true;
      Get.closeAllSnackbars();

      await ApiClient.instance.post(ApiEndpoints.customerWithdrawalSendOtp);
      _startWithdrawOtpCooldown(60);

      Get.snackbar(
        'OTP Sent',
        'A new verification code has been sent to your mobile.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Failed to Resend OTP',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
      Get.snackbar(
        'Failed to Resend OTP',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isResendingOtp.value = false;
    }
  }

  final withdrawOtpController = TextEditingController();

  Future<void> verifyAndSubmitWithdraw(double amount, UserBankCardModel selectedCard) async {
    if (isSubmittingWithdraw.value) return;

    final otp = withdrawOtpController.text.trim();
    if (otp.length < 6) {
      Get.snackbar('Invalid OTP', 'Please enter a valid 6-digit OTP code.');
      return;
    }

    try {
      isSubmittingWithdraw.value = true;
      
      final payload = {
        "amount": amount,
        "methodId": selectedCard.id,
        "otp": otp,
      };

      await ApiClient.instance.post(ApiEndpoints.customerWithdrawals, data: payload);

      final profileCtrl = Get.find<ProfileController>();
      
      // Deduct from available balance / balance wallet locally
      profileCtrl.deductFunds(amount, fromRechargeWallet: false);

      final cur = profileCtrl.walletData.value;
      profileCtrl.setWalletData(cur.copyWith(
        availableEarnings: (cur.availableEarnings - amount).clamp(0.0, double.infinity),
        balanceWallet: (cur.balanceWallet - amount).clamp(0.0, double.infinity),
        totalWithdrawals: cur.totalWithdrawals + amount,
      ));

      // Re-fetch profile and withdrawal history from API to synchronize
      await Future.wait([
        profileCtrl.fetchCustomerProfile(),
        fetchWithdrawalHistory(),
      ]);

      final preview = withdrawalPreview.value;
      final rateA = preview?.levelA?.rate ?? commissionRateA.value;
      final rateB = preview?.levelB?.rate ?? commissionRateB.value;
      final rateC = preview?.levelC?.rate ?? commissionRateC.value;
      final feeA = preview?.levelA?.fee ?? (amount * (rateA / 100));
      final feeB = preview?.levelB?.fee ?? (amount * (rateB / 100));
      final feeC = preview?.levelC?.fee ?? (amount * (rateC / 100));
      final totalRate = preview?.totalFeeRate ?? totalDeductionPercent;
      final totalFee = preview?.totalFeeAmount ?? (feeA + feeB + feeC);
      final finalReceivedAmount = preview?.netAmount ?? (amount - totalFee);

      withdrawAmountController.clear();
      withdrawOtpController.clear();
      withdrawPasswordController.clear();
      withdrawalPreview.value = null;

      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFF0D9488), size: 50),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Withdrawal Requested!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your request to withdraw ৳${amount.toStringAsFixed(0)} to ${selectedCard.methodName} (${selectedCard.accountNumber}) has been submitted.\n\n• Level A Fee (${formatRate(rateA)}): ৳${feeA.toStringAsFixed(0)}\n• Level B Fee (${formatRate(rateB)}): ৳${feeB.toStringAsFixed(0)}\n• Level C Fee (${formatRate(rateC)}): ৳${feeC.toStringAsFixed(0)}\n• Total Fee Deducted (${formatRate(totalRate)}): ৳${totalFee.toStringAsFixed(0)}\n• Net Final Received: ৳${finalReceivedAmount.toStringAsFixed(0)}\n\nStatus: Pending Admin Approval (within 24 hrs).',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.45),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.main); // go to main to reset stack, or Get.back if profile is previous
                    },
                    child: const Text('Back to Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      Get.snackbar('Verification Failed', e.toString().replaceAll('Exception: ', ''), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSubmittingWithdraw.value = false;
    }
  }
}
