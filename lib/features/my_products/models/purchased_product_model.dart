class PurchasedProductModel {
  final String id;
  final String productCode;
  final String name;
  final String imageUrl;
  final double price;
  final double dailyIncome;
  final int validityDays;
  final int daysPassed;
  final double totalEarnings;
  final double alreadyReceived;
  final DateTime purchaseDate;
  final DateTime? lastClaimedAt;
  final bool isClaimed;
  final String status;

  PurchasedProductModel({
    required this.id,
    required this.productCode,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.dailyIncome,
    required this.validityDays,
    required this.daysPassed,
    required this.totalEarnings,
    required this.alreadyReceived,
    required this.purchaseDate,
    this.lastClaimedAt,
    this.isClaimed = false,
    this.status = 'ACTIVE',
  });

  bool get isExpired {
    final s = status.toUpperCase().trim();
    if (s == 'EXPIRED' || s == 'COMPLETED') return true;
    if (s == 'ACTIVE') return false;
    return validityDays > 0 && daysPassed >= validityDays;
  }

  /// Check if 24 hours have passed since last claim and not currently claimed
  bool get canReceive {
    if (isExpired) return false;
    if (isClaimed) return false;
    if (lastClaimedAt == null) return true;
    return remainingTime == Duration.zero;
  }

  /// Remaining duration until next claim
  Duration get remainingTime {
    if (lastClaimedAt == null) return Duration.zero;
    final lastClaimLocal = lastClaimedAt!.toLocal();
    final nextClaimTime = lastClaimLocal.add(const Duration(hours: 24));
    final remaining = nextClaimTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory PurchasedProductModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString() ?? 'ACTIVE';

    final lastClaim = _parseDateTime(
      json['lastClaimedAt'] ??
          json['last_claimed_at'] ??
          json['lastClaimed'] ??
          json['last_claimed'] ??
          json['lastClaimAt'] ??
          json['last_claim_at'],
    );

    // Explicit flags from backend API (supports isClaimedToday, canClaimToday, claimedToday, etc.)
    bool claimed = json['isClaimedToday'] == true ||
        json['is_claimed_today'] == true ||
        json['claimedToday'] == true ||
        json['claimed_today'] == true ||
        json['canClaimToday'] == false ||
        json['can_claim_today'] == false ||
        json['isClaimed'] == true ||
        json['is_claimed'] == true ||
        json['claimed'] == true;

    if (!claimed && lastClaim != null) {
      final diff = DateTime.now().difference(lastClaim);
      if (diff.inHours < 24) {
        claimed = true;
      }
    }

    final dailyInc = _parseDouble(json['dailyIncome'] ?? json['daily_income']);
    final vDays = _parseInt(json['contractDays'] ?? json['validity_days'] ?? json['validityDays'], 30);
    double totalEarn = _parseDouble(json['totalReturn'] ?? json['total_earnings'] ?? json['totalEarnings']);
    
    // Auto-compute total return if not explicitly returned by API
    if (totalEarn == 0.0 && dailyInc > 0 && vDays > 0) {
      totalEarn = dailyInc * vDays;
    }

    return PurchasedProductModel(
      id: json['id']?.toString() ?? json['userProductId']?.toString() ?? '',
      productCode: json['productCode']?.toString() ?? json['product_code']?.toString() ?? json['productId']?.toString() ?? 'A1',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      price: _parseDouble(json['pricePaid'] ?? json['price']),
      dailyIncome: dailyInc,
      validityDays: vDays,
      daysPassed: _parseInt(json['daysPassed'] ?? json['days_passed'], 0),
      totalEarnings: totalEarn,
      alreadyReceived: _parseDouble(json['alreadyReceived'] ?? json['already_received']),
      purchaseDate: _parseDateTime(
            json['purchasedAt'] ?? json['purchase_date'] ?? json['purchased_at'] ?? json['purchaseDate'],
          ) ??
          DateTime.now(),
      lastClaimedAt: lastClaim,
      isClaimed: claimed,
      status: statusStr,
    );
  }

  static double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? defaultVal;
    }
    return defaultVal;
  }

  static int _parseInt(dynamic val, [int defaultVal = 0]) {
    if (val == null) return defaultVal;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? defaultVal;
    }
    return defaultVal;
  }

  static DateTime? _parseDateTime(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val.toLocal();
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    final dt = DateTime.tryParse(str);
    return dt?.toLocal();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_code': productCode,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'daily_income': dailyIncome,
      'validity_days': validityDays,
      'days_passed': daysPassed,
      'total_earnings': totalEarnings,
      'already_received': alreadyReceived,
      'purchase_date': purchaseDate.toIso8601String(),
      'last_claimed_at': lastClaimedAt?.toIso8601String(),
      'is_claimed': isClaimed,
      'status': status,
    };
  }

  PurchasedProductModel copyWith({
    String? id,
    String? productCode,
    String? name,
    String? imageUrl,
    double? price,
    double? dailyIncome,
    int? validityDays,
    int? daysPassed,
    double? totalEarnings,
    double? alreadyReceived,
    DateTime? purchaseDate,
    DateTime? lastClaimedAt,
    bool? isClaimed,
    String? status,
  }) {
    return PurchasedProductModel(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      dailyIncome: dailyIncome ?? this.dailyIncome,
      validityDays: validityDays ?? this.validityDays,
      daysPassed: daysPassed ?? this.daysPassed,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      alreadyReceived: alreadyReceived ?? this.alreadyReceived,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      lastClaimedAt: lastClaimedAt ?? this.lastClaimedAt,
      isClaimed: isClaimed ?? this.isClaimed,
      status: status ?? this.status,
    );
  }
}
