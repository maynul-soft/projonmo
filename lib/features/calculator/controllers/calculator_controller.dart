import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../product/controllers/product_controller.dart';
import '../../product/models/product_model.dart';

class CalculatorCalculationResult {
  final double bEarnings;
  final double cEarnings;
  final double dEarnings;
  final double dailyTotal;
  final double monthlyTotal;
  final double contractTotal;
  final int validityDays;
  final double productDailyIncome;
  final int countB;
  final int countC;
  final int countD;

  CalculatorCalculationResult({
    required this.bEarnings,
    required this.cEarnings,
    required this.dEarnings,
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.contractTotal,
    required this.validityDays,
    required this.productDailyIncome,
    required this.countB,
    required this.countC,
    required this.countD,
  });
}

class CalculatorController extends GetxController {
  final bController = TextEditingController(text: '5');
  final cController = TextEditingController(text: '3');
  final dController = TextEditingController(text: '2');

  final selectedProduct = Rx<ProductModel?>(null);
  final result = Rx<CalculatorCalculationResult?>(null);
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
    final productCtrl = Get.find<ProductController>();
    if (productCtrl.products.isNotEmpty) {
      // Default to A9 or highest as shown in video
      selectedProduct.value = productCtrl.products.last;
      calculate();
    }
  }

  void calculate() {
    final product = selectedProduct.value;
    if (product == null) return;

    final countB = int.tryParse(bController.text.trim()) ?? 0;
    final countC = int.tryParse(cController.text.trim()) ?? 0;
    final countD = int.tryParse(dController.text.trim()) ?? 0;

    final daily = product.dailyIncome;

    // Formula:
    // B Level: 10%
    // C Level: 5%
    // D Level: 2%
    final bEarnings = daily * 0.10 * countB;
    final cEarnings = daily * 0.05 * countC;
    final dEarnings = daily * 0.02 * countD;
    final dailyTotal = bEarnings + cEarnings + dEarnings;
    final monthlyTotal = dailyTotal * 30;
    final contractTotal = dailyTotal * product.validityDays;

    result.value = CalculatorCalculationResult(
      bEarnings: bEarnings,
      cEarnings: cEarnings,
      dEarnings: dEarnings,
      dailyTotal: dailyTotal,
      monthlyTotal: monthlyTotal,
      contractTotal: contractTotal,
      validityDays: product.validityDays,
      productDailyIncome: daily,
      countB: countB,
      countC: countC,
      countD: countD,
    );
  }


}
