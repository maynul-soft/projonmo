class PaymentMethodModel {
  final String id;
  final String name; // e.g. 'bKash', 'Nagad', 'Rocket', 'Bank Transfer'
  final String icon; // Icon identifier or asset/logo
  final String number; // Admin wallet/account number or user account number
  final String? accountHolder;
  final String? instruction;
  final double minAmount;
  final double maxAmount;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.icon = 'wallet',
    required this.number,
    this.accountHolder,
    this.instruction,
    this.minAmount = 500.0,
    this.maxAmount = 50000.0,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'wallet',
      number: json['accountInfo']?.toString() ?? json['account_info']?.toString() ?? json['number']?.toString() ?? '',
      accountHolder: json['accountHolder']?.toString() ?? json['account_holder']?.toString(),
      instruction: json['instructions']?.toString() ?? json['instruction']?.toString(),
      minAmount: (json['minAmount'] ?? json['min_amount'] as num?)?.toDouble() ?? 500.0,
      maxAmount: (json['maxAmount'] ?? json['max_amount'] as num?)?.toDouble() ?? 50000.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'number': number,
      'account_holder': accountHolder,
      'instruction': instruction,
      'min_amount': minAmount,
      'max_amount': maxAmount,
    };
  }
}
