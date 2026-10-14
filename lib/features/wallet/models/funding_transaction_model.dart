class FundingTransactionModel {
  final String id;
  final String type; // 'recharge', 'withdraw', 'product_income', 'commission', 'check_in'
  final String title;
  final double amount;
  final bool isCredit; // true = +, false = -
  final String date;
  final String status; // 'Success', 'Pending', 'Processing'
  final String? accountOrTrx;

  FundingTransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.status,
    this.accountOrTrx,
  });

  factory FundingTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase() ?? 'recharge';
    final isCreditStr = json['source']?.toString().toLowerCase() ?? '';
    final isDeposit = typeStr == 'deposit' || isCreditStr.contains('income') || isCreditStr.contains('commission');
    
    // Some API sends isCredit explicitly, others we derive from type
    final creditValue = json['is_credit'] ?? json['isCredit'] ?? isDeposit;

    return FundingTransactionModel(
      id: json['id']?.toString() ?? '',
      type: typeStr,
      title: json['title']?.toString() ?? json['description']?.toString() ?? typeStr.toUpperCase(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isCredit: creditValue == true || creditValue == 'true',
      date: json['date']?.toString() ?? json['submittedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Success',
      accountOrTrx: json['account_or_trx']?.toString() ?? json['accountOrTrx']?.toString() ?? json['txnId']?.toString(),
    );
  }
}
