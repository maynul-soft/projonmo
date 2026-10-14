
class UserBankCardModel {
  final String id;
  final String methodId; // e.g., 'bkash', 'nagad', 'bank'
  final String methodName; // 'bKash', 'Nagad'
  final String accountNumber; // phone number or bank account number
  final String accountHolderName;
  final String? bankName;
  final String? branchName;
  final bool isDefault;

  UserBankCardModel({
    required this.id,
    required this.methodId,
    required this.methodName,
    required this.accountNumber,
    required this.accountHolderName,
    this.bankName,
    this.branchName,
    this.isDefault = false,
  });

  factory UserBankCardModel.fromJson(Map<String, dynamic> json) {
    return UserBankCardModel(
      id: json['id']?.toString() ?? '',
      methodId: json['method_id']?.toString() ?? json['methodId']?.toString() ?? '',
      methodName: json['method_name']?.toString() ?? json['methodName']?.toString() ?? json['method']?.toString() ?? json['name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? json['accountNo']?.toString() ?? json['accountInfo']?.toString() ?? '',
      accountHolderName: json['account_holder_name']?.toString() ?? json['accountHolderName']?.toString() ?? json['accountName']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString(),
      branchName: json['branch_name']?.toString() ?? json['branchName']?.toString(),
      isDefault: json['is_default'] == true || json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method_id': methodId,
      'method_name': methodName,
      'account_number': accountNumber,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'branch_name': branchName,
      'is_default': isDefault,
    };
  }

  UserBankCardModel copyWith({
    String? id,
    String? methodId,
    String? methodName,
    String? accountNumber,
    String? accountHolderName,
    String? bankName,
    String? branchName,
    bool? isDefault,
  }) {
    return UserBankCardModel(
      id: id ?? this.id,
      methodId: methodId ?? this.methodId,
      methodName: methodName ?? this.methodName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
