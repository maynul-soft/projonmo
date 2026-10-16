import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../models/team_stats_model.dart';

class TeamController extends GetxController {
  final teamStats = Rx<TeamStatsModel>(TeamStatsModel());
  final selectedLevelTab = 'A'.obs; // 'A', 'B', 'C'
  final selectedMemberType = 'valid'.obs; // 'valid', 'invalid'
  final isLoading = true.obs;

  final teamMembers = <TeamMemberModel>[].obs;

  // Dynamic commission rates for Stage A, B, C
  final rateA = 10.0.obs;
  final rateB = 5.0.obs;
  final rateC = 2.0.obs;

  String formatRate(double rate) {
    if (rate == rate.toInt()) {
      return '${rate.toInt()}%';
    }
    return '${rate.toStringAsFixed(1)}%';
  }

  @override
  void onInit() {
    super.onInit();
    fetchCommissionSettings();
    fetchTeamSummary();
  }

  Future<void> fetchCommissionSettings() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicCalculatorSettings);
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'] ?? {};
        final stageA = (data['A'] ?? data['teamStages']?['A'] ?? data['level1'] as num?)?.toDouble();
        final stageB = (data['B'] ?? data['teamStages']?['B'] ?? data['level2'] as num?)?.toDouble();
        final stageC = (data['C'] ?? data['teamStages']?['C'] ?? data['level3'] as num?)?.toDouble();
        if (stageA != null) rateA.value = stageA;
        if (stageB != null) rateB.value = stageB;
        if (stageC != null) rateC.value = stageC;
      }
    } catch (e) {
      debugPrint('[TeamController] Error fetching commission settings: $e');
    }
  }

  Future<void> fetchTeamSummary() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.customerTeam);
      
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final data = Map<String, dynamic>.from(resMap['data'] as Map);
          
          // Parse overall stats
          teamStats.value = TeamStatsModel.fromJson(data);

          // Parse dynamic commission rates from commissionPerStage if available
          final cps = data['commissionPerStage'];
          if (cps is List) {
            for (final item in cps) {
              if (item is Map) {
                final stage = item['stage']?.toString();
                final rate = (item['ratePercent'] as num?)?.toDouble();
                if (rate != null) {
                  if (stage == 'A') rateA.value = rate;
                  if (stage == 'B') rateB.value = rate;
                  if (stage == 'C') rateC.value = rate;
                }
              }
            }
          }
          
          // Parse members
          final List<TeamMemberModel> allMembers = [];
          
          final validMap = data['validMembers'] as Map<String, dynamic>? ?? {};
          final invalidMap = data['invalidMembers'] as Map<String, dynamic>? ?? {};

          void parseLevel(String levelKey, Map<String, dynamic> source, bool isValid) {
            final list = source[levelKey];
            if (list is List) {
              for (final item in list) {
                if (item is Map) {
                  allMembers.add(TeamMemberModel.fromJson(
                    Map<String, dynamic>.from(item), 
                    isValid: isValid, 
                    level: levelKey
                  ));
                }
              }
            }
          }

          final levels = ['A', 'B', 'C'];
          for (final level in levels) {
            parseLevel(level, validMap, true);
            parseLevel(level, invalidMap, false);
          }

          teamMembers.assignAll(allMembers);
        } else if (resMap['success'] == true && resMap['data'] == null) {
          teamMembers.clear();
        }
      }
    } catch (e) {
      debugPrint('[TeamController] Error fetching team summary: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TeamMemberModel> get filteredMembers {
    return teamMembers.where((m) {
      final matchesLevel = m.level == selectedLevelTab.value;
      final matchesValidity = selectedMemberType.value == 'valid' ? m.isValid : !m.isValid;
      return matchesLevel && matchesValidity;
    }).toList();
  }

  /// Hook for API response to set team statistics
  void setTeamStats(TeamStatsModel stats) {
    teamStats.value = stats;
  }

  /// Hook for API response to set team members
  void setTeamMembers(List<TeamMemberModel> members) {
    teamMembers.assignAll(members);
  }
}
