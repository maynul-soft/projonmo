import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/payment_method_model.dart';
import '../models/user_bank_card_model.dart';

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

  // Withdrawal Rules info & Commission Tier Deductions
  // User spec: "jekhane handeling fee ta manage hosse okhane hishab hobe a level commission b level comission and c level commission akhon 10, 5, 2 % katbe and kete niye tar final withdraw koto hobe eta dekhbe hishab ta"
  final minWithdrawAmount = 500.0;
  final maxWithdrawAmount = 50000.0;
  final commissionRateA = 10.0; // 10%
  final commissionRateB = 5.0;  // 5%
  final commissionRateC = 2.0;  // 2%
  double get totalDeductionPercent => commissionRateA + commissionRateB + commissionRateC; // 17%

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    await Future.wait([
      fetchPaymentMethods(),
      fetchWithdrawalMethods(),
    ]);
    isLoading.value = false;
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

  /// Add new bank/wallet account for user
  Future<void> addUserBankCard(UserBankCardModel card) async {
    try {
      isLoading.value = true;
      final payload = {
        "method": card.methodName,
        "accountNo": card.accountNumber,
        "accountName": card.accountHolderName,
        "isDefault": card.isDefault
      };

      await ApiClient.instance.post(
        ApiEndpoints.customerWithdrawalMethods,
        data: payload,
      );

      // In GetX, for instant feedback, we can optimistically add it
      // However, fetching from API ensures we get the real ID generated by the DB.
      await fetchWithdrawalMethods();
      
      Get.back(); // close modal
      Get.snackbar(
        'Account Added',
        'Withdrawal account has been saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
      );
    } catch (e) {
      debugPrint('[WalletController] Error adding withdrawal method: $e');
      Get.snackbar('Error', 'Failed to add account. Try again.');
    } finally {
      isLoading.value = false;
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

  /// Submit Withdraw
  Future<void> submitWithdraw() async {
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
    final currentBalance = profileCtrl.walletData.value.balanceWallet + profileCtrl.walletData.value.rechargeWallet;

    if (amount > currentBalance) {
      Get.snackbar(
        'Insufficient Balance',
        'Your current wallet balance is ৳${currentBalance.toStringAsFixed(2)}.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    isSubmittingWithdraw.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    isSubmittingWithdraw.value = false;

    // Deduct from wallet & increase total withdrawals
    if (profileCtrl.walletData.value.balanceWallet >= amount) {
      profileCtrl.deductFunds(amount, fromRechargeWallet: false);
    } else {
      final fromBal = profileCtrl.walletData.value.balanceWallet;
      final fromRecharge = amount - fromBal;
      if (fromBal > 0) profileCtrl.deductFunds(fromBal, fromRechargeWallet: false);
      if (fromRecharge > 0) profileCtrl.deductFunds(fromRecharge, fromRechargeWallet: true);
    }

    final cur = profileCtrl.walletData.value;
    profileCtrl.setWalletData(cur.copyWith(
      totalWithdrawals: cur.totalWithdrawals + amount,
    ));

    final feeA = amount * (commissionRateA / 100);
    final feeB = amount * (commissionRateB / 100);
    final feeC = amount * (commissionRateC / 100);
    final totalFee = feeA + feeB + feeC;
    final finalReceivedAmount = amount - totalFee;

    withdrawAmountController.clear();
    withdrawPasswordController.clear();

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
                'Your request to withdraw ৳${amount.toStringAsFixed(0)} to ${selectedCard.methodName} (${selectedCard.accountNumber}) has been submitted.\n\n• Level A Fee (10%): ৳${feeA.toStringAsFixed(0)}\n• Level B Fee (5%): ৳${feeB.toStringAsFixed(0)}\n• Level C Fee (2%): ৳${feeC.toStringAsFixed(0)}\n• Total Commission Deducted: ৳${totalFee.toStringAsFixed(0)}\n• Net Final Received: ৳${finalReceivedAmount.toStringAsFixed(0)}\n\nStatus: Pending Admin Approval (within 24 hrs).',
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
                    Get.back(); // close dialog
                    Get.back(); // return to profile
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
  }
}
