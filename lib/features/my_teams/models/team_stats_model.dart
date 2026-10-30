class TeamMemberModel {
  final String account;
  final String maxProduct;
  final String contact;
  final bool isValid;
  final String level; // 'A', 'B', 'C'

  TeamMemberModel({
    required this.account,
    required this.maxProduct,
    required this.contact,
    required this.isValid,
    required this.level,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json, {bool isValid = true, String level = 'A'}) {
    final stage = (json['stage']?.toString() ?? level).toUpperCase();
    return TeamMemberModel(
      account: json['mobile']?.toString() ?? json['userId']?.toString() ?? json['id']?.toString() ?? '',
      maxProduct: json['maxProductName']?.toString() ?? '—',
      contact: 'Telegram', // Placeholder since API does not provide it
      isValid: isValid,
      level: stage.isNotEmpty ? stage : 'A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'max_product': maxProduct,
      'contact': contact,
      'is_valid': isValid,
      'level': level,
    };
  }
}

class TeamStatsModel {
  final double totalTeamIncome;
  final int validMembersCount;
  final double teamCumulativeRecharge;
  final int countA;
  final int countB;
  final int countC;
  final int todayNewA;
  final int todayNewB;
  final int todayNewC;
  final int yesterdayNewA;
  final int yesterdayNewB;
  final int yesterdayNewC;
  final double todayTopUpAmount;
  final double yesterdayRechargeAmount;
  final double thisMonthRechargeAmount;
  final double lastMonthRechargeAmount;

  TeamStatsModel({
    this.totalTeamIncome = 0.0,
    this.validMembersCount = 0,
    this.teamCumulativeRecharge = 0.0,
    this.countA = 0,
    this.countB = 0,
    this.countC = 0,
    this.todayNewA = 0,
    this.todayNewB = 0,
    this.todayNewC = 0,
    this.yesterdayNewA = 0,
    this.yesterdayNewB = 0,
    this.yesterdayNewC = 0,
    this.todayTopUpAmount = 0.0,
    this.yesterdayRechargeAmount = 0.0,
    this.thisMonthRechargeAmount = 0.0,
    this.lastMonthRechargeAmount = 0.0,
  });

  factory TeamStatsModel.fromJson(Map<String, dynamic> json) {
    // Total members by stage
    final membersMap = json['totalMembersByStage'] as Map<String, dynamic>? ?? {};
    final aCount = (membersMap['A'] as num?)?.toInt() ?? 0;
    final bCount = (membersMap['B'] as num?)?.toInt() ?? 0;
    final cCount = (membersMap['C'] as num?)?.toInt() ?? 0;

    // Valid members count (sum of all valid arrays)
    final validMap = json['validMembers'] as Map<String, dynamic>? ?? {};
    final aValid = (validMap['A'] as List?)?.length ?? 0;
    final bValid = (validMap['B'] as List?)?.length ?? 0;
    final cValid = (validMap['C'] as List?)?.length ?? 0;
    final totalValid = aValid + bValid + cValid;

    // Today new members
    final todayMap = json['todayNewByStage'] as Map<String, dynamic>? ?? {};
    
    // Yesterday new members
    final yesterdayMap = json['yesterdayNewByStage'] as Map<String, dynamic>? ?? {};

    return TeamStatsModel(
      totalTeamIncome: (json['totalTeamIncome'] as num?)?.toDouble() ?? 0.0,
      validMembersCount: totalValid,
      teamCumulativeRecharge: (json['totalTeamRecharge'] as num?)?.toDouble() ?? 0.0,
      countA: aCount,
      countB: bCount,
      countC: cCount,
      todayNewA: (todayMap['A'] as num?)?.toInt() ?? 0,
      todayNewB: (todayMap['B'] as num?)?.toInt() ?? 0,
      todayNewC: (todayMap['C'] as num?)?.toInt() ?? 0,
      yesterdayNewA: (yesterdayMap['A'] as num?)?.toInt() ?? 0,
      yesterdayNewB: (yesterdayMap['B'] as num?)?.toInt() ?? 0,
      yesterdayNewC: (yesterdayMap['C'] as num?)?.toInt() ?? 0,
      todayTopUpAmount: 0.0, // Backend doesn't provide today top up, defaulting to 0
      yesterdayRechargeAmount: 0.0, // Backend doesn't provide yesterday recharge, defaulting to 0
      thisMonthRechargeAmount: (json['thisMonthRecharge'] as num?)?.toDouble() ?? 0.0,
      lastMonthRechargeAmount: (json['lastMonthRecharge'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTeamIncome': totalTeamIncome,
      'validMembersCount': validMembersCount,
      'teamCumulativeRecharge': teamCumulativeRecharge,
      'countA': countA,
      'countB': countB,
      'countC': countC,
      'todayNewA': todayNewA,
      'todayNewB': todayNewB,
      'todayNewC': todayNewC,
      'yesterdayNewA': yesterdayNewA,
      'yesterdayNewB': yesterdayNewB,
      'yesterdayNewC': yesterdayNewC,
      'todayTopUpAmount': todayTopUpAmount,
      'yesterdayRechargeAmount': yesterdayRechargeAmount,
      'thisMonthRechargeAmount': thisMonthRechargeAmount,
      'lastMonthRechargeAmount': lastMonthRechargeAmount,
    };
  }
}
