import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../product/controllers/product_controller.dart';
import '../../product/models/product_model.dart';

class CalculatorCalculationResult {
  final double level1Earnings;
  final double level2Earnings;
  final double level3Earnings;
  final double dailyTotal;
  final double monthlyTotal;
  final double contractTotal;
  final int validityDays;
  final double productPrice;
  final double productDailyIncome;
  final int countL1;
  final int countL2;
  final int countL3;

  CalculatorCalculationResult({
    required this.level1Earnings,
    required this.level2Earnings,
    required this.level3Earnings,
    required this.dailyTotal,
    required this.monthlyTotal,
    required this.contractTotal,
    required this.validityDays,
    required this.productPrice,
    required this.productDailyIncome,
    required this.countL1,
    required this.countL2,
    required this.countL3,
  });
}

class CalculatorController extends GetxController {
  final l1Controller = TextEditingController(text: '5');
  final l2Controller = TextEditingController(text: '3');
  final l3Controller = TextEditingController(text: '2');

  final selectedProduct = Rx<ProductModel?>(null);
  final result = Rx<CalculatorCalculationResult?>(null);
  final isLoading = true.obs;

  // Dynamic commission rates
  final level1Rate = 10.0.obs;
  final level2Rate = 5.0.obs;
  final level3Rate = 2.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    
    // Fetch dynamic rates
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicCalculatorSettings);
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        level1Rate.value = (data['level1'] as num?)?.toDouble() ?? 10.0;
        level2Rate.value = (data['level2'] as num?)?.toDouble() ?? 5.0;
        level3Rate.value = (data['level3'] as num?)?.toDouble() ?? 2.0;
      }
    } catch (e) {
      debugPrint('[CalculatorController] Error fetching settings: $e');
    }

    final productCtrl = Get.find<ProductController>();
    if (productCtrl.products.isNotEmpty) {
      selectedProduct.value = productCtrl.products.last;
      calculate();
    }
    
    isLoading.value = false;
  }

  void calculate() {
    final product = selectedProduct.value;
    if (product == null) return;

    final countL1 = int.tryParse(l1Controller.text.trim()) ?? 0;
    final countL2 = int.tryParse(l2Controller.text.trim()) ?? 0;
    final countL3 = int.tryParse(l3Controller.text.trim()) ?? 0;

    final price = product.price;

    // Formula: Product Price * (Commission % / 100) * Team Count
    final l1Earnings = price * (level1Rate.value / 100) * countL1;
    final l2Earnings = price * (level2Rate.value / 100) * countL2;
    final l3Earnings = price * (level3Rate.value / 100) * countL3;
    
    final dailyTotal = l1Earnings + l2Earnings + l3Earnings + product.dailyIncome;
    final monthlyTotal = dailyTotal * 30;
    final contractTotal = dailyTotal * product.validityDays;

    result.value = CalculatorCalculationResult(
      level1Earnings: l1Earnings,
      level2Earnings: l2Earnings,
      level3Earnings: l3Earnings,
      dailyTotal: dailyTotal,
      monthlyTotal: monthlyTotal,
      contractTotal: contractTotal,
      validityDays: product.validityDays,
      productPrice: price,
      productDailyIncome: product.dailyIncome,
      countL1: countL1,
      countL2: countL2,
      countL3: countL3,
    );
  }
}
