class VipLevelModel {
  final String id;
  final String name;
  final int requiredTeam;
  final String imageUrl;
  final double teamBonusPercent;
  final double weeklySalary;
  final double monthlySalary;
  final double annualSalary;
  final bool isCurrent;
  final bool isUnlocked;
  final int currentTeamCount;
  final int targetTeamCount;
  final int remainingToUnlock;

  VipLevelModel({
    required this.id,
    required this.name,
    required this.requiredTeam,
    required this.imageUrl,
    required this.teamBonusPercent,
    required this.weeklySalary,
    required this.monthlySalary,
    required this.annualSalary,
    required this.isCurrent,
    required this.isUnlocked,
    required this.currentTeamCount,
    required this.targetTeamCount,
    required this.remainingToUnlock,
  });

  factory VipLevelModel.fromJson(Map<String, dynamic> json) {
    return VipLevelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      requiredTeam: (json['requiredTeam'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      teamBonusPercent: (json['teamBonusPercent'] as num?)?.toDouble() ?? 0.0,
      weeklySalary: (json['weeklySalary'] as num?)?.toDouble() ?? 0.0,
      monthlySalary: (json['monthlySalary'] as num?)?.toDouble() ?? 0.0,
      annualSalary: (json['annualSalary'] as num?)?.toDouble() ?? 0.0,
      isCurrent: json['isCurrent'] == true,
      isUnlocked: json['isUnlocked'] == true,
      currentTeamCount: (json['currentTeamCount'] as num?)?.toInt() ?? 0,
      targetTeamCount: (json['targetTeamCount'] as num?)?.toInt() ?? 0,
      remainingToUnlock: (json['remainingToUnlock'] as num?)?.toInt() ?? 0,
    );
  }
}
