class DailyCommissionModel {
  final String date; 
  final String dateLabel;
  final double amountA;
  final double amountB;
  final double amountC;

  DailyCommissionModel({
    required this.date,
    this.dateLabel = '',
    this.amountA = 0.0,
    this.amountB = 0.0,
    this.amountC = 0.0,
  });

  factory DailyCommissionModel.fromJson(Map<String, dynamic> json) {
    return DailyCommissionModel(
      date: json['date']?.toString() ?? '',
      dateLabel: json['dateLabel']?.toString() ?? '',
      amountA: (json['amountA'] ?? json['A'] as num?)?.toDouble() ?? 0.0,
      amountB: (json['amountB'] ?? json['B'] as num?)?.toDouble() ?? 0.0,
      amountC: (json['amountC'] ?? json['C'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dateLabel': dateLabel,
      'A': amountA,
      'B': amountB,
      'C': amountC,
    };
  }
}
