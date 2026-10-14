import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../models/salary_model.dart';

class SalaryController extends GetxController {
  final weeklySalary = Rxn<SalaryModel>();
  final monthlySalary = Rxn<SalaryModel>();
  final annualSalary = Rxn<SalaryModel>();

  final isWeeklyLoading = true.obs;
  final isMonthlyLoading = true.obs;
  final isAnnualLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWeeklySalary();
    fetchMonthlySalary();
    fetchAnnualSalary();
  }

  Future<void> fetchWeeklySalary() async {
    try {
      isWeeklyLoading.value = true;
      final response = await ApiClient.instance.get('/customer/salary/weekly');
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          weeklySalary.value = SalaryModel.fromJson(Map<String, dynamic>.from(resMap['data'] as Map));
        }
      }
    } catch (e) {
      debugPrint('[SalaryController] Error fetching weekly salary: $e');
    } finally {
      isWeeklyLoading.value = false;
    }
  }

  Future<void> fetchMonthlySalary() async {
    try {
      isMonthlyLoading.value = true;
      final response = await ApiClient.instance.get('/customer/salary/monthly');
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          monthlySalary.value = SalaryModel.fromJson(Map<String, dynamic>.from(resMap['data'] as Map));
        }
      }
    } catch (e) {
      debugPrint('[SalaryController] Error fetching monthly salary: $e');
    } finally {
      isMonthlyLoading.value = false;
    }
  }

  Future<void> fetchAnnualSalary() async {
    try {
      isAnnualLoading.value = true;
      final response = await ApiClient.instance.get('/customer/salary/annual');
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          annualSalary.value = SalaryModel.fromJson(Map<String, dynamic>.from(resMap['data'] as Map));
        }
      }
    } catch (e) {
      debugPrint('[SalaryController] Error fetching annual salary: $e');
    } finally {
      isAnnualLoading.value = false;
    }
  }

  Future<void> claimSalary(String type) async {
    try {
      // POST /customer/salary/claim with { "type": "weekly" }
      final response = await ApiClient.instance.post(
        '/customer/salary/claim',
        data: {'type': type},
      );
      final resData = response.data;
      if (resData is Map && resData['success'] == true) {
        Get.snackbar(
          'Success',
          resData['message']?.toString() ?? 'Salary claimed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
        // Refresh
        if (type == 'weekly') fetchWeeklySalary();
        if (type == 'monthly') fetchMonthlySalary();
        if (type == 'annual') fetchAnnualSalary();
      } else {
        throw ApiException(message: resData['message']?.toString() ?? 'Failed to claim salary');
      }
    } on ApiException catch (e) {
      Get.snackbar('Notice', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Could not claim salary: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
