import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/salary_model.dart';
import '../models/vip_level_model.dart';

class VipSalaryController extends GetxController {
  final isLoading = true.obs;
  final vipLevels = <VipLevelModel>[].obs;

  // Specific Salary Models by Type
  final weeklySalary = Rxn<SalaryModel>();
  final monthlySalary = Rxn<SalaryModel>();
  final annualSalary = Rxn<SalaryModel>();

  final isWeeklyLoading = false.obs;
  final isMonthlyLoading = false.obs;
  final isAnnualLoading = false.obs;

  // Claiming in progress
  final isClaiming = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVipLevels();
  }

  Future<void> fetchVipLevels() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.customerVipLevels);
      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> dataList = response.data['data'] ?? [];
        vipLevels.value = dataList.map((json) => VipLevelModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('[VipSalaryController] Error fetching VIP levels: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSalaryDetails(String type) async {
    final cleanType = type.trim().toLowerCase();
    try {
      if (cleanType == 'weekly') isWeeklyLoading.value = true;
      if (cleanType == 'monthly') isMonthlyLoading.value = true;
      if (cleanType == 'annual') isAnnualLoading.value = true;

      final path = cleanType == 'monthly'
          ? ApiEndpoints.customerSalaryMonthly
          : cleanType == 'annual'
              ? ApiEndpoints.customerSalaryAnnual
              : ApiEndpoints.customerSalaryWeekly;

      final response = await ApiClient.instance.get(path);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null && resMap['data'] is Map) {
          final model = SalaryModel.fromJson(Map<String, dynamic>.from(resMap['data'] as Map));
          if (cleanType == 'weekly') weeklySalary.value = model;
          if (cleanType == 'monthly') monthlySalary.value = model;
          if (cleanType == 'annual') annualSalary.value = model;
        }
      }
    } catch (e) {
      debugPrint('[VipSalaryController] Error fetching $cleanType salary: $e');
    } finally {
      if (cleanType == 'weekly') isWeeklyLoading.value = false;
      if (cleanType == 'monthly') isMonthlyLoading.value = false;
      if (cleanType == 'annual') isAnnualLoading.value = false;
    }
  }

  SalaryModel? getSalaryByType(String type) {
    final cleanType = type.trim().toLowerCase();
    if (cleanType == 'monthly') return monthlySalary.value;
    if (cleanType == 'annual') return annualSalary.value;
    return weeklySalary.value;
  }

  bool isSalaryLoadingByType(String type) {
    final cleanType = type.trim().toLowerCase();
    if (cleanType == 'monthly') return isMonthlyLoading.value;
    if (cleanType == 'annual') return isAnnualLoading.value;
    return isWeeklyLoading.value;
  }

  Future<void> claimSalary(String type) async {
    final cleanType = type.trim().toLowerCase();
    if (isClaiming.value) return;

    try {
      isClaiming.value = true;
      final response = await ApiClient.instance.post(
        ApiEndpoints.customerSalaryClaim,
        data: {'type': cleanType},
      );

      final resData = response.data;
      if (resData is Map && resData['success'] == true) {
        Get.snackbar(
          'Success',
          resData['message']?.toString() ?? '${cleanType.capitalizeFirst} salary claimed successfully!',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );

        // Refresh salary and VIP levels
        await Future.wait([
          fetchSalaryDetails(cleanType),
          fetchVipLevels(),
        ]);

        // Refresh user profile if registered
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchCustomerProfile();
        }
      } else {
        final msg = resData is Map ? resData['message']?.toString() : null;
        throw ApiException(message: msg ?? 'Failed to claim salary');
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Notice',
        e.message,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not claim salary: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      );
    } finally {
      isClaiming.value = false;
    }
  }
}
