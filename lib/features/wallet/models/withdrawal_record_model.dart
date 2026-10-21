class WithdrawalRecordModel {
  final String id;
  final double amount;
  final double netAmount;
  final double feeAmount;
  final double feeRate;
  final String method;
  final String accountNo;
  final String status;
  final String requestedAt;

  WithdrawalRecordModel({
    required this.id,
    required this.amount,
    required this.netAmount,
    required this.feeAmount,
    required this.feeRate,
    required this.method,
    required this.accountNo,
    required this.status,
    required this.requestedAt,
  });

  factory WithdrawalRecordModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalRecordModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0,
      feeAmount: (json['feeAmount'] as num?)?.toDouble() ?? 0.0,
      feeRate: (json['feeRate'] as num?)?.toDouble() ?? 0.0,
      method: json['method']?.toString() ?? 'Withdrawal',
      accountNo: json['accountNo']?.toString() ?? json['account_no']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      requestedAt: json['requestedAt']?.toString() ?? json['requested_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'netAmount': netAmount,
      'feeAmount': feeAmount,
      'feeRate': feeRate,
      'method': method,
      'accountNo': accountNo,
      'status': status,
      'requestedAt': requestedAt,
    };
  }
}
