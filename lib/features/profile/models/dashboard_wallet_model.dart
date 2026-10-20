class DashboardWalletModel {
  final double rechargeWallet;
  final double totalDeposite;
  final double balanceWallet;
  final double availableEarnings;
  final double totalEarnings;
  final double totalWithdrawals;
  final double teamIncome;
  final double incomeToday;
  final double todaysLoss;
  final double totalLoss;
  final double yesterdaysEarnings;
  final int points;
  final String telegramChannelUrl;
  final String? invitationLink;
  final int directReferrals;
  final int teamCount;

  DashboardWalletModel({
    this.totalDeposite = 0.00,
    this.rechargeWallet = 0.0,
    this.balanceWallet = 0.0,
    this.availableEarnings = 0.0,
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.teamIncome = 0.0,
    this.incomeToday = 0.0,
    this.todaysLoss = 0.0,
    this.totalLoss = 0.0,
    this.yesterdaysEarnings = 0.0,
    this.points = 0,
    this.telegramChannelUrl = 'https://t.me/delmonte_official',
    this.invitationLink,
    this.directReferrals = 0,
    this.teamCount = 0,
  });

  double get totalDeposit => totalDeposite;
  double get total_deposit => totalDeposite;
  double get recharge_wallet => rechargeWallet;
  double get balance_wallet => balanceWallet;
  double get total_withdrawals => totalWithdrawals;
  double get total_withdraw => totalWithdrawals;
  double get total_earnings => totalEarnings;
  double get team_income => teamIncome;
  double get today_income => incomeToday;
  double get yesterday_earning => yesterdaysEarnings;
  int get points_balance => points;
  String get telegramChannelLink => telegramChannelUrl;

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  factory DashboardWalletModel.fromJson(Map<String, dynamic> json) {
    final depositVal = _parseDouble(json['totalDeposit'] ?? json['total_deposit']);
    final rechargeVal = _parseDouble(json['rechargeWallet'] ?? json['recharge_wallet']);
    final effectiveRecharge = (json.containsKey('rechargeWallet') || json.containsKey('recharge_wallet'))
        ? rechargeVal
        : depositVal;
    final effectiveDeposit = (json.containsKey('totalDeposit') || json.containsKey('total_deposit'))
        ? depositVal
        : effectiveRecharge;

    final balanceVal = _parseDouble(
      json['balanceWallet'] ??
          json['balance_wallet'] ??
          json['balance'] ??
          json['totalBalance'] ??
          json['total_balance'] ??
          json['availableEarnings'] ??
          json['available_earnings'],
    );

    return DashboardWalletModel(
      rechargeWallet: effectiveRecharge,
      totalDeposite: effectiveDeposit,
      balanceWallet: balanceVal,
      availableEarnings: balanceVal,
      totalEarnings: _parseDouble(json['totalEarnings'] ?? json['total_earnings']),
      totalWithdrawals: _parseDouble(
        json['totalWithdrawals'] ??
            json['total_withdrawals'] ??
            json['totalWithdraw'] ??
            json['total_withdraw'],
      ),
      teamIncome: _parseDouble(json['teamIncome'] ?? json['team_income']),
      incomeToday: _parseDouble(
        json['todayIncome'] ??
            json['today_income'] ??
            json['incomeToday'] ??
            json['income_today'],
      ),
      todaysLoss: _parseDouble(json['todaysLoss'] ?? json['todays_loss']),
      totalLoss: _parseDouble(json['totalLoss'] ?? json['total_loss']),
      yesterdaysEarnings: _parseDouble(
        json['yesterdayEarning'] ??
            json['yesterday_earning'] ??
            json['yesterdaysEarnings'] ??
            json['yesterdays_earnings'] ??
            json['yesterdayIncome'] ??
            json['yesterday_income'],
      ),
      points: _parseInt(json['points'] ?? json['pointsBalance'] ?? json['points_balance']),
      telegramChannelUrl: json['telegramChannelLink']?.toString() ??
          json['telegram_channel_link']?.toString() ??
          json['telegramLink']?.toString() ??
          json['telegram_link']?.toString() ??
          json['telegramChannelUrl']?.toString() ??
          json['telegram_channel_url']?.toString() ??
          'https://t.me/delmonte_official',
      invitationLink: json['invitationLink']?.toString() ??
          json['invitation_link']?.toString() ??
          json['referralLink']?.toString() ??
          json['referral_link']?.toString(),
      directReferrals: _parseInt(json['directReferrals'] ?? json['direct_referrals']),
      teamCount: _parseInt(json['teamCount'] ?? json['team_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rechargeWallet': rechargeWallet,
      'recharge_wallet': rechargeWallet,
      'totalDeposit': totalDeposite,
      'total_deposit': totalDeposite,
      'balanceWallet': balanceWallet,
      'balance_wallet': balanceWallet,
      'balance': balanceWallet,
      'availableEarnings': availableEarnings,
      'available_earnings': availableEarnings,
      'totalEarnings': totalEarnings,
      'total_earnings': totalEarnings,
      'totalWithdrawals': totalWithdrawals,
      'total_withdrawals': totalWithdrawals,
      'totalWithdraw': totalWithdrawals,
      'total_withdraw': totalWithdrawals,
      'teamIncome': teamIncome,
      'team_income': teamIncome,
      'todayIncome': incomeToday,
      'incomeToday': incomeToday,
      'income_today': incomeToday,
      'todaysLoss': todaysLoss,
      'todays_loss': todaysLoss,
      'totalLoss': totalLoss,
      'total_loss': totalLoss,
      'yesterdayEarning': yesterdaysEarnings,
      'yesterdaysEarnings': yesterdaysEarnings,
      'yesterdays_earnings': yesterdaysEarnings,
      'points': points,
      'telegramChannelLink': telegramChannelUrl,
      'telegram_channel_link': telegramChannelUrl,
      'telegram_channel_url': telegramChannelUrl,
      'invitationLink': invitationLink,
      'directReferrals': directReferrals,
      'teamCount': teamCount,
    };
  }

  DashboardWalletModel copyWith({
    double? rechargeWallet,
    double? totalDeposite,
    double? balanceWallet,
    double? availableEarnings,
    double? totalEarnings,
    double? totalWithdrawals,
    double? teamIncome,
    double? incomeToday,
    double? todaysLoss,
    double? totalLoss,
    double? yesterdaysEarnings,
    int? points,
    String? telegramChannelUrl,
    String? invitationLink,
    int? directReferrals,
    int? teamCount,
  }) {
    return DashboardWalletModel(
      rechargeWallet: rechargeWallet ?? this.rechargeWallet,
      totalDeposite: totalDeposite ?? this.totalDeposite,
      balanceWallet: balanceWallet ?? this.balanceWallet,
      availableEarnings: availableEarnings ?? this.availableEarnings,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      teamIncome: teamIncome ?? this.teamIncome,
      incomeToday: incomeToday ?? this.incomeToday,
      todaysLoss: todaysLoss ?? this.todaysLoss,
      totalLoss: totalLoss ?? this.totalLoss,
      yesterdaysEarnings: yesterdaysEarnings ?? this.yesterdaysEarnings,
      points: points ?? this.points,
      telegramChannelUrl: telegramChannelUrl ?? this.telegramChannelUrl,
      invitationLink: invitationLink ?? this.invitationLink,
      directReferrals: directReferrals ?? this.directReferrals,
      teamCount: teamCount ?? this.teamCount,
    );
  }
}
