import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../controllers/points_controller.dart';
import '../controllers/profile_controller.dart';

class PointsConvertView extends StatelessWidget {
  const PointsConvertView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PointsController());
    final profileCtrl = Get.find<ProfileController>();

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
          'Convert Points',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Points Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, size: 48, color: Color(0xFFEA580C)),
                  const SizedBox(height: 12),
                  const Text('Total Available Points', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    '${profileCtrl.walletData.value.points}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Conversion Form
            const Text(
              'Enter Points to Convert',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black45, offset: Offset(0, 1))]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller.pointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Min 10',
                      hintStyle: const TextStyle(fontSize: 16, color: AppColors.textMuted, fontWeight: FontWeight.normal, letterSpacing: 0),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      suffixIcon: TextButton(
                        onPressed: () {
                          controller.pointsController.text = profileCtrl.walletData.value.points.toString();
                        },
                        child: const Text('ALL', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Conversion Preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You will receive:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                        Obx(() {
                          if (controller.isPreviewing.value) {
                            return const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2));
                          }
                          return Text(
                            '৳${controller.previewBdtAmount.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isConverting.value ? null : controller.convertPoints,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isConverting.value
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Convert to Balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
