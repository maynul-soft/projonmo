class SalaryModel {
  final String type;
  final String title;
  final bool enabled;
  final double amount;
  final int minTeam;
  final int currentTeam;
  final String vipLevel;
  final bool isEligible;
  final int remainingTeam;
  final double progressPercent;
  final String formula;
  final String cycle;
  final String nextDistributionDate;

  SalaryModel({
    required this.type,
    required this.title,
    required this.enabled,
    required this.amount,
    required this.minTeam,
    required this.currentTeam,
    required this.vipLevel,
    required this.isEligible,
    required this.remainingTeam,
    required this.progressPercent,
    required this.formula,
    required this.cycle,
    required this.nextDistributionDate,
  });

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      enabled: json['enabled'] == true,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      minTeam: (json['minTeam'] as num?)?.toInt() ?? 0,
      currentTeam: (json['currentTeam'] ?? json['userTeamCount'] as num?)?.toInt() ?? 0,
      vipLevel: json['vipLevel']?.toString() ?? '',
      isEligible: json['isEligible'] == true || json['eligible'] == true,
      remainingTeam: (json['remainingTeam'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      formula: json['formula']?.toString() ?? json['multiplierHint']?.toString() ?? '',
      cycle: json['cycle']?.toString() ?? '',
      nextDistributionDate: json['nextDistributionDate']?.toString() ?? '',
    );
  }
}
