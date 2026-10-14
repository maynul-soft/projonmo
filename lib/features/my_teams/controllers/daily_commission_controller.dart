import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../models/daily_commission_model.dart';

class DailyCommissionController extends GetxController {
  final totalTeamIncome = 0.0.obs;
  final isLoading = true.obs;
  final commissions = <DailyCommissionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailyCommissions();
  }

  Future<void> fetchDailyCommissions() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.customerTeam);
      
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final data = Map<String, dynamic>.from(resMap['data'] as Map);
          
          totalTeamIncome.value = (data['totalTeamIncome'] as num?)?.toDouble() ?? 0.0;
          
          final listRaw = data['dailyIncomeLast20'];
          if (listRaw is List) {
            final fetched = listRaw.map((item) {
              if (item is Map) {
                return DailyCommissionModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            }).whereType<DailyCommissionModel>().toList();
            
            commissions.assignAll(fetched);
          }
        }
      }
    } catch (e) {
      debugPrint('[DailyCommissionController] Error fetching data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hook for API to inject dynamic daily commissions
  void setDailyCommissions({required double total, required List<DailyCommissionModel> list}) {
    totalTeamIncome.value = total;
    commissions.assignAll(list);
  }
}
