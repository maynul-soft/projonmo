class UserModel {
  final String id;
  final String phone;
  final String memberId;
  final int vipLevel;
  final String vipLevelText;
  final String? invitationCode;
  final String? referralCode;
  final String? invitationLink;
  final String? sponsorId;
  final double balance;
  final double totalBalance;
  final double balanceWallet;
  final double rechargeWallet;
  final double totalDeposit;
  final double totalWithdraw;
  final double totalWithdrawals;
  final double totalEarnings;
  final double teamIncome;
  final double todayIncome;
  final double yesterdayEarning;
  final double todaysLoss;
  final double totalLoss;
  final int points;
  final String? telegramChannelLink;
  final int directReferrals;
  final int teamCount;
  final String? registeredAt;
  final String status;
  final String? token;
  final String countryCode;

  UserModel({
    required this.id,
    required this.phone,
    required this.memberId,
    this.vipLevel = 0,
    this.vipLevelText = 'Level 0',
    this.invitationCode,
    this.referralCode,
    this.invitationLink,
    this.sponsorId,
    this.balance = 0.0,
    this.totalBalance = 0.0,
    this.balanceWallet = 0.0,
    this.rechargeWallet = 0.0,
    this.totalDeposit = 0.0,
    this.totalWithdraw = 0.0,
    this.totalWithdrawals = 0.0,
    this.totalEarnings = 0.0,
    this.teamIncome = 0.0,
    this.todayIncome = 0.0,
    this.yesterdayEarning = 0.0,
    this.todaysLoss = 0.0,
    this.totalLoss = 0.0,
    this.points = 0,
    this.telegramChannelLink,
    this.directReferrals = 0,
    this.teamCount = 0,
    this.registeredAt,
    this.status = 'Active',
    this.token,
    this.countryCode = '+880',
  });

  String get mobile => phone;
  double get total_deposit => totalDeposit;
  double get recharge_wallet => rechargeWallet;
  double get balance_wallet => balanceWallet;
  double get total_balance => totalBalance;
  double get total_withdraw => totalWithdraw;
  double get total_withdrawals => totalWithdrawals;
  double get total_earnings => totalEarnings;
  double get team_income => teamIncome;
  double get today_income => todayIncome;
  double get yesterday_earning => yesterdayEarning;
  int get points_balance => points;
  int get direct_referrals => directReferrals;
  int get team_count => teamCount;

  static int _parseVipLevel(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    final str = val.toString();
    final match = RegExp(r'\d+').firstMatch(str);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final refCode = json['referralCode']?.toString() ??
        json['referral_code']?.toString() ??
        json['invitationCode']?.toString() ??
        json['invitation_code']?.toString();

    final phoneStr = json['mobile']?.toString() ??
        json['phone']?.toString() ??
        json['mobileNumber']?.toString() ??
        json['mobile_number']?.toString() ??
        '';

    final memberIdStr = json['memberId']?.toString() ??
        json['member_id']?.toString() ??
        refCode ??
        '';

    final vipRaw = json['vipLevel'] ?? json['vip_level'];

    final balanceVal = _parseDouble(
      json['balance'] ??
          json['totalBalance'] ??
          json['total_balance'] ??
          json['balanceWallet'] ??
          json['balance_wallet'] ??
          json['availableEarnings'] ??
          json['available_earnings'],
    );

    final rechargeWalletVal = _parseDouble(
      json['rechargeWallet'] ??
          json['recharge_wallet'] ??
          json['totalDeposit'] ??
          json['total_deposit'],
    );

    final totalDepositVal = _parseDouble(
      json['totalDeposit'] ??
          json['total_deposit'] ??
          json['rechargeWallet'] ??
          json['recharge_wallet'],
    );

    final totalWithdrawVal = _parseDouble(
      json['totalWithdraw'] ??
          json['total_withdraw'] ??
          json['totalWithdrawals'] ??
          json['total_withdrawals'],
    );

    final totalEarningsVal = _parseDouble(
      json['totalEarnings'] ?? json['total_earnings'],
    );

    final teamIncomeVal = _parseDouble(
      json['teamIncome'] ?? json['team_income'],
    );

    final todayIncomeVal = _parseDouble(
      json['todayIncome'] ??
          json['today_income'] ??
          json['incomeToday'] ??
          json['income_today'],
    );

    final yesterdayEarningVal = _parseDouble(
      json['yesterdayEarning'] ??
          json['yesterday_earning'] ??
          json['yesterdaysEarnings'] ??
          json['yesterdays_earnings'] ??
          json['yesterdayIncome'] ??
          json['yesterday_income'],
    );

    final todaysLossVal = _parseDouble(
      json['todaysLoss'] ?? json['todays_loss'],
    );

    final totalLossVal = _parseDouble(
      json['totalLoss'] ?? json['total_loss'],
    );

    final pointsVal = _parseInt(
      json['points'] ?? json['pointsBalance'] ?? json['points_balance'],
    );

    final telegramLinkVal = json['telegramChannelLink']?.toString() ??
        json['telegram_channel_link']?.toString() ??
        json['telegramLink']?.toString() ??
        json['telegram_link']?.toString();

    final inviteLinkVal = json['invitationLink']?.toString() ??
        json['invitation_link']?.toString() ??
        json['referralLink']?.toString() ??
        json['referral_link']?.toString();

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      phone: phoneStr,
      memberId: memberIdStr,
      vipLevel: _parseVipLevel(vipRaw),
      vipLevelText: vipRaw?.toString() ?? 'Level 0',
      invitationCode: refCode,
      referralCode: refCode,
      invitationLink: inviteLinkVal,
      sponsorId: json['sponsorId']?.toString() ?? json['sponsor_id']?.toString(),
      balance: balanceVal,
      totalBalance: _parseDouble(json['totalBalance'] ?? json['total_balance'] ?? balanceVal),
      balanceWallet: _parseDouble(json['balanceWallet'] ?? json['balance_wallet'] ?? balanceVal),
      rechargeWallet: rechargeWalletVal,
      totalDeposit: totalDepositVal,
      totalWithdraw: totalWithdrawVal,
      totalWithdrawals: totalWithdrawVal,
      totalEarnings: totalEarningsVal,
      teamIncome: teamIncomeVal,
      todayIncome: todayIncomeVal,
      yesterdayEarning: yesterdayEarningVal,
      todaysLoss: todaysLossVal,
      totalLoss: totalLossVal,
      points: pointsVal,
      telegramChannelLink: telegramLinkVal,
      directReferrals: _parseInt(json['directReferrals'] ?? json['direct_referrals']),
      teamCount: _parseInt(json['teamCount'] ?? json['team_count']),
      registeredAt: json['registeredAt']?.toString() ?? json['registered_at']?.toString(),
      status: json['status']?.toString() ?? 'Active',
      token: json['token']?.toString(),
      countryCode: json['countryCode']?.toString() ?? json['country_code']?.toString() ?? '+880',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': phone,
      'phone': phone,
      'memberId': memberId,
      'member_id': memberId,
      'referralCode': referralCode ?? invitationCode,
      'invitationCode': invitationCode ?? referralCode,
      'invitationLink': invitationLink,
      'sponsorId': sponsorId,
      'vipLevel': vipLevelText,
      'balance': balance,
      'totalBalance': totalBalance,
      'total_balance': totalBalance,
      'balanceWallet': balanceWallet,
      'balance_wallet': balanceWallet,
      'rechargeWallet': rechargeWallet,
      'recharge_wallet': rechargeWallet,
      'totalDeposit': totalDeposit,
      'total_deposit': totalDeposit,
      'totalWithdraw': totalWithdraw,
      'total_withdraw': totalWithdraw,
      'totalWithdrawals': totalWithdrawals,
      'total_withdrawals': totalWithdrawals,
      'totalEarnings': totalEarnings,
      'total_earnings': totalEarnings,
      'teamIncome': teamIncome,
      'team_income': teamIncome,
      'todayIncome': todayIncome,
      'incomeToday': todayIncome,
      'yesterdayEarning': yesterdayEarning,
      'yesterdaysEarnings': yesterdayEarning,
      'todaysLoss': todaysLoss,
      'totalLoss': totalLoss,
      'points': points,
      'telegramChannelLink': telegramChannelLink,
      'directReferrals': directReferrals,
      'teamCount': teamCount,
      'registeredAt': registeredAt,
      'status': status,
      'token': token,
      'countryCode': countryCode,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? memberId,
    int? vipLevel,
    String? vipLevelText,
    String? invitationCode,
    String? referralCode,
    String? invitationLink,
    String? sponsorId,
    double? balance,
    double? totalBalance,
    double? balanceWallet,
    double? rechargeWallet,
    double? totalDeposit,
    double? totalWithdraw,
    double? totalWithdrawals,
    double? totalEarnings,
    double? teamIncome,
    double? todayIncome,
    double? yesterdayEarning,
    double? todaysLoss,
    double? totalLoss,
    int? points,
    String? telegramChannelLink,
    int? directReferrals,
    int? teamCount,
    String? registeredAt,
    String? status,
    String? token,
    String? countryCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      memberId: memberId ?? this.memberId,
      vipLevel: vipLevel ?? this.vipLevel,
      vipLevelText: vipLevelText ?? this.vipLevelText,
      invitationCode: invitationCode ?? this.invitationCode,
      referralCode: referralCode ?? this.referralCode,
      invitationLink: invitationLink ?? this.invitationLink,
      sponsorId: sponsorId ?? this.sponsorId,
      balance: balance ?? this.balance,
      totalBalance: totalBalance ?? this.totalBalance,
      balanceWallet: balanceWallet ?? this.balanceWallet,
      rechargeWallet: rechargeWallet ?? this.rechargeWallet,
      totalDeposit: totalDeposit ?? this.totalDeposit,
      totalWithdraw: totalWithdraw ?? this.totalWithdraw,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      teamIncome: teamIncome ?? this.teamIncome,
      todayIncome: todayIncome ?? this.todayIncome,
      yesterdayEarning: yesterdayEarning ?? this.yesterdayEarning,
      todaysLoss: todaysLoss ?? this.todaysLoss,
      totalLoss: totalLoss ?? this.totalLoss,
      points: points ?? this.points,
      telegramChannelLink: telegramChannelLink ?? this.telegramChannelLink,
      directReferrals: directReferrals ?? this.directReferrals,
      teamCount: teamCount ?? this.teamCount,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      token: token ?? this.token,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
