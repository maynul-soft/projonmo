class UserModel {
  final String id;
  final String phone;
  final String memberId;
  final int vipLevel;
  final String vipLevelText;
  final String? invitationCode;
  final String? referralCode;
  final String? sponsorId;
  final double balance;
  final double totalDeposit;
  final double totalWithdraw;
  final double totalEarnings;
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
    this.sponsorId,
    this.balance = 0.0,
    this.totalDeposit = 0.0,
    this.totalWithdraw = 0.0,
    this.totalEarnings = 0.0,
    this.directReferrals = 0,
    this.teamCount = 0,
    this.registeredAt,
    this.status = 'Active',
    this.token,
    this.countryCode = '+880',
  });

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

    return UserModel(
      id: json['id']?.toString() ?? json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      phone: phoneStr,
      memberId: memberIdStr,
      vipLevel: _parseVipLevel(vipRaw),
      vipLevelText: vipRaw?.toString() ?? 'Level 0',
      invitationCode: refCode,
      referralCode: refCode,
      sponsorId: json['sponsorId']?.toString() ?? json['sponsor_id']?.toString(),
      balance: _parseDouble(json['availableEarnings'] ?? json['available_earnings'] ?? json['balance'] ?? json['balanceWallet'] ?? json['balance_wallet']),
      totalDeposit: _parseDouble(json['totalDeposit'] ?? json['total_deposit']),
      totalWithdraw: _parseDouble(json['totalWithdraw'] ?? json['total_withdraw'] ?? json['totalWithdrawals'] ?? json['total_withdrawals']),
      totalEarnings: _parseDouble(json['totalEarnings'] ?? json['total_earnings']),
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
      'sponsorId': sponsorId,
      'balance': balance,
      'totalDeposit': totalDeposit,
      'totalWithdraw': totalWithdraw,
      'totalEarnings': totalEarnings,
      'directReferrals': directReferrals,
      'teamCount': teamCount,
      'vipLevel': vipLevelText,
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
    String? sponsorId,
    double? balance,
    double? totalDeposit,
    double? totalWithdraw,
    double? totalEarnings,
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
      sponsorId: sponsorId ?? this.sponsorId,
      balance: balance ?? this.balance,
      totalDeposit: totalDeposit ?? this.totalDeposit,
      totalWithdraw: totalWithdraw ?? this.totalWithdraw,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      directReferrals: directReferrals ?? this.directReferrals,
      teamCount: teamCount ?? this.teamCount,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      token: token ?? this.token,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
