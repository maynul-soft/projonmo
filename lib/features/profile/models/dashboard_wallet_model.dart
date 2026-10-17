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
  });

  factory DashboardWalletModel.fromJson(Map<String, dynamic> json) {
    final depositRaw = json['totalDeposit'] ?? json['total_deposit'];
    final depositVal = depositRaw != null ? (depositRaw as num).toDouble() : null;
    final rechargeRaw = json['recharge_wallet'] ?? json['rechargeWallet'];
    final rechargeVal = rechargeRaw != null ? (rechargeRaw as num).toDouble() : 0.0;
    final effectiveRecharge = depositVal ?? rechargeVal;

    final availableEarningsRaw = json['availableEarnings'] ??
        json['available_earnings'] ??
        json['balanceWallet'] ??
        json['balance_wallet'] ??
        json['balance'];
    final availableEarningsVal = availableEarningsRaw != null
        ? (availableEarningsRaw as num).toDouble()
        : 0.0;

    final earningsRaw = json['totalEarnings'] ?? json['total_earnings'];
    final earningsVal = earningsRaw != null ? (earningsRaw as num).toDouble() : 0.0;

    return DashboardWalletModel(
      rechargeWallet: effectiveRecharge,
      totalDeposite: effectiveRecharge,
      balanceWallet: availableEarningsVal,
      availableEarnings: availableEarningsVal,
      totalEarnings: earningsVal,
      totalWithdrawals: ((json['total_withdraw'] ?? json['totalWithdraw'] ?? json['total_withdrawals'] ?? json['totalWithdrawals']) as num?)?.toDouble() ?? 0.0,
      teamIncome: ((json['team_income'] ?? json['teamIncome']) as num?)?.toDouble() ?? 0.0,
      incomeToday: ((json['today_income'] ?? json['todayIncome'] ?? json['income_today'] ?? json['incomeToday']) as num?)?.toDouble() ?? 0.0,
      todaysLoss: ((json['todays_loss'] ?? json['todaysLoss']) as num?)?.toDouble() ?? 0.0,
      totalLoss: ((json['total_loss'] ?? json['totalLoss']) as num?)?.toDouble() ?? 0.0,
      yesterdaysEarnings: ((json['yesterday_earning'] ?? json['yesterdayEarning'] ?? json['yesterdays_earnings'] ?? json['yesterdaysEarnings'] ?? json['yesterday_income'] ?? json['yesterdayIncome']) as num?)?.toDouble() ?? 0.0,
      points: ((json['points'] ?? json['pointsBalance'] ?? json['points_balance']) as num?)?.toInt() ?? 0,
      telegramChannelUrl: json['telegramLink']?.toString() ??
          json['telegram_link']?.toString() ??
          json['telegramChannelLink']?.toString() ??
          json['telegram_channel_link']?.toString() ??
          json['telegram_channel_url']?.toString() ??
          json['telegramChannelUrl']?.toString() ??
          'https://t.me/delmonte_official',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recharge_wallet': rechargeWallet,
      'balance_wallet': balanceWallet,
      'available_earnings': availableEarnings,
      'total_earnings': totalEarnings,
      'total_withdrawals': totalWithdrawals,
      'team_income': teamIncome,
      'income_today': incomeToday,
      'todays_loss': todaysLoss,
      'total_loss': totalLoss,
      'yesterdays_earnings': yesterdaysEarnings,
      'points': points,
      'telegram_channel_url': telegramChannelUrl,
    };
  }

  DashboardWalletModel copyWith({
    double? rechargeWallet,
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
  }) {
    return DashboardWalletModel(
      rechargeWallet: rechargeWallet ?? this.rechargeWallet,
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
    );
  }
}
