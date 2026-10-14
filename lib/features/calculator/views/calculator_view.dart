import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../product/controllers/product_controller.dart';
import '../../product/models/product_model.dart';
import '../controllers/calculator_controller.dart';

class CalculatorView extends GetView<CalculatorController> {
  const CalculatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final productCtrl = Get.find<ProductController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.calculatorTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CalculatorShimmerView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.pleaseEnterTeamSize,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // B, C, D Team Inputs
                  Row(
                    children: [
                      _buildTeamInput('B', controller.bController),
                      const SizedBox(width: 10),
                      _buildTeamInput('C', controller.cController),
                      const SizedBox(width: 10),
                      _buildTeamInput('D', controller.dController),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Product Dropdown Selector
                  const Text(
                    AppStrings.selectProduct,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProductModel>(
                        value: controller.selectedProduct.value,
                        isExpanded: true,
                        items: productCtrl.products.map((p) {
                          return DropdownMenuItem<ProductModel>(
                            value: p,
                            child: Row(
                              children: [
                                Text(
                                  p.code,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '• ${CurrencyFormatter.format(p.price)} (Daily: ${CurrencyFormatter.format(p.dailyIncome)})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newProduct) {
                          if (newProduct != null) {
                            controller.selectedProduct.value = newProduct;
                            controller.calculate();
                          }
                        },
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Calculate Button
                  ElevatedButton(
                    onPressed: controller.calculate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      AppStrings.calculateNow,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calculation Results
            Obx(() {
              final res = controller.result.value;
              if (res == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.yourDailyTeamEarnings,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Level B, C, D formula rows
                    _buildFormulaLine(
                      'B',
                      '${res.productDailyIncome} * 10% * ${res.countB}',
                      CurrencyFormatter.format(res.bEarnings),
                    ),
                    _buildFormulaLine(
                      'C',
                      '${res.productDailyIncome} * 5% * ${res.countC}',
                      CurrencyFormatter.format(res.cEarnings),
                    ),
                    _buildFormulaLine(
                      'D',
                      '${res.productDailyIncome} * 2% * ${res.countD}',
                      CurrencyFormatter.format(res.dEarnings),
                    ),
                    const Divider(height: 16),
                    _buildTotalLine(
                      'Daily Total:',
                      '${CurrencyFormatter.format(res.bEarnings, showSymbol: false)} + ${CurrencyFormatter.format(res.cEarnings, showSymbol: false)} + ${CurrencyFormatter.format(res.dEarnings, showSymbol: false)} = ',
                      CurrencyFormatter.format(res.dailyTotal),
                    ),
                    const SizedBox(height: 16),

                    // Monthly Income Block
                    const Text(
                      AppStrings.yourTeamMonthlyIncome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildHighlightedBlock(
                      '${CurrencyFormatter.format(res.dailyTotal, showSymbol: false)} * 30 days =',
                      CurrencyFormatter.format(res.monthlyTotal),
                      const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 16),

                    // Total Contract Income Block
                    const Text(
                      AppStrings.yourTeamTotalIncome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildHighlightedBlock(
                      '${CurrencyFormatter.format(res.dailyTotal, showSymbol: false)} * ${res.validityDays} days =',
                      CurrencyFormatter.format(res.contractTotal),
                      const Color(0xFFD97706),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    }));
  }

  Widget _buildTeamInput(String label, TextEditingController textCtrl) {
    return Expanded(
      child: Column(
        children: [
          TextField(
            controller: textCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: InputDecoration(
              prefixText: '$label: ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            onChanged: (_) => controller.calculate(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaLine(String level, String formula, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$level: $formula =',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              result,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLine(String label, String formula, String total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            total,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightedBlock(String formula, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              formula,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
