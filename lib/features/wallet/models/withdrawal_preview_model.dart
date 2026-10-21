class WithdrawalPreviewModel {
  final double grossAmount;
  final double netAmount;
  final double totalFeeRate;
  final double totalFeeAmount;
  final WithdrawalPreviewLevel? levelA;
  final WithdrawalPreviewLevel? levelB;
  final WithdrawalPreviewLevel? levelC;

  WithdrawalPreviewModel({
    required this.grossAmount,
    required this.netAmount,
    required this.totalFeeRate,
    required this.totalFeeAmount,
    this.levelA,
    this.levelB,
    this.levelC,
  });

  factory WithdrawalPreviewModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalPreviewModel(
      grossAmount: (json['grossAmount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      totalFeeRate: (json['totalFeeRate'] as num?)?.toDouble() ?? 0.0,
      totalFeeAmount: (json['totalFeeAmount'] as num?)?.toDouble() ?? 0.0,
      levelA: json['levelA'] is Map ? WithdrawalPreviewLevel.fromJson(Map<String, dynamic>.from(json['levelA'] as Map)) : null,
      levelB: json['levelB'] is Map ? WithdrawalPreviewLevel.fromJson(Map<String, dynamic>.from(json['levelB'] as Map)) : null,
      levelC: json['levelC'] is Map ? WithdrawalPreviewLevel.fromJson(Map<String, dynamic>.from(json['levelC'] as Map)) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grossAmount': grossAmount,
      'netAmount': netAmount,
      'totalFeeRate': totalFeeRate,
      'totalFeeAmount': totalFeeAmount,
      'levelA': levelA?.toJson(),
      'levelB': levelB?.toJson(),
      'levelC': levelC?.toJson(),
    };
  }
}

class WithdrawalPreviewLevel {
  final bool exists;
  final bool isAdmin;
  final String userId;
  final String mobile;
  final double rate;
  final double fee;

  WithdrawalPreviewLevel({
    required this.exists,
    required this.isAdmin,
    required this.userId,
    required this.mobile,
    required this.rate,
    required this.fee,
  });

  factory WithdrawalPreviewLevel.fromJson(Map<String, dynamic> json) {
    return WithdrawalPreviewLevel(
      exists: json['exists'] == true,
      isAdmin: json['isAdmin'] == true,
      userId: json['userId']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'isAdmin': isAdmin,
      'userId': userId,
      'mobile': mobile,
      'rate': rate,
      'fee': fee,
    };
  }
}
