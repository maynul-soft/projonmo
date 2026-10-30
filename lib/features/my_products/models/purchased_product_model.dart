import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper to cache the initial countdown target time for newly purchased products
/// until the first income is claimed.
class FirstClaimCache {
  static const String _storageKey = 'product_first_claim_targets';
  static final Map<String, DateTime> _targets = {};
  static bool _isLoaded = false;

  static DateTime? getTarget(String productId) => _targets[productId];

  /// Load all cached target unlock times from SharedPreferences
  static Future<void> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        map.forEach((key, val) {
          final dt = DateTime.tryParse(val.toString());
          if (dt != null) {
            _targets[key] = dt.toLocal();
          }
        });
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('[FirstClaimCache] Error loading targets: $e');
    }
  }

  /// Resolve or create the target unlock time:
  /// - If target is ALREADY cached: return the cached target! (DO NOT recalculate from waitHours)
  /// - If target is NOT cached yet AND waitHours > 0: create target = now + waitHours, cache it and persist it!
  static DateTime? resolveTarget(String productId, int waitHours) {
    if (productId.isEmpty) return null;

    // 1. If target is already cached in memory, return it directly!
    if (_targets.containsKey(productId)) {
      return _targets[productId];
    }

    // 2. If waitHours > 0, calculate new target unlock time, cache in memory, and persist
    if (waitHours > 0) {
      final target = DateTime.now().add(Duration(hours: waitHours));
      _targets[productId] = target;
      _persist();
      return target;
    }

    return null;
  }

  /// Clear cache when product has been claimed (lastClaimedAt is no longer null)
  static void clear(String productId) {
    if (_targets.containsKey(productId)) {
      _targets.remove(productId);
      _persist();
    }
  }

  static void _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> map = {};
      _targets.forEach((key, val) {
        map[key] = val.toIso8601String();
      });
      await prefs.setString(_storageKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[FirstClaimCache] Error persisting targets: $e');
    }
  }
}

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
  final int waitHours;
  final DateTime? unlockAt;

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
    this.waitHours = 0,
    this.unlockAt,
  });

  bool get isExpired {
    final s = status.toUpperCase().trim();
    if (s == 'EXPIRED' || s == 'COMPLETED') return true;
    if (s == 'ACTIVE') return false;
    return validityDays > 0 && daysPassed >= validityDays;
  }

  /// Check if eligible to receive income
  bool get canReceive {
    if (isExpired) return false;

    // First-time purchase case (never claimed before)
    if (lastClaimedAt == null) {
      if (unlockAt != null) {
        return DateTime.now().isAfter(unlockAt!);
      }
      if (waitHours > 0) return false;
      return true;
    }

    // Traditional system (24h between claims)
    return remainingTime == Duration.zero;
  }

  /// Remaining duration until next claim
  Duration get remainingTime {
    if (isExpired) return Duration.zero;

    // First-time purchase countdown
    if (lastClaimedAt == null) {
      if (unlockAt != null) {
        final remaining = unlockAt!.difference(DateTime.now());
        return remaining.isNegative ? Duration.zero : remaining;
      }
      if (waitHours > 0) {
        return Duration(hours: waitHours);
      }
      return Duration.zero;
    }

    // Traditional system: 24h from last claim
    final lastClaimLocal = lastClaimedAt!.toLocal();
    final nextClaimTime = lastClaimLocal.add(const Duration(hours: 24));
    final remaining = nextClaimTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  factory PurchasedProductModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString() ?? 'ACTIVE';

    // Parse 'lastClaimDate' and 'lastClaimTime' or default to 'lastClaimedAt'
    DateTime? lastClaim;
    if (json['lastClaimDate'] != null && json['lastClaimTime'] != null) {
      final dateStr = json['lastClaimDate'].toString().split('T').first;
      final timeStr = json['lastClaimTime'].toString();
      lastClaim = DateTime.tryParse('${dateStr}T$timeStr');
    }

    if (lastClaim == null) {
      lastClaim = _parseDateTime(
        json['lastClaimedAt'] ??
            json['last_claimed_at'] ??
            json['lastClaimed'] ??
            json['last_claimed'] ??
            json['lastClaimAt'] ??
            json['last_claim_at'],
      );
    }

    final prodId = json['id']?.toString() ?? json['userProductId']?.toString() ?? '';
    final waitH = _parseInt(
      json['waitHours'] ??
          json['hoursRemainingUntilFirstIncome'] ??
          json['wait_hours'] ??
          json['hours_remaining_until_first_income'],
      0,
    );

    // If lastClaim is present, traditional system applies & clear any first-time cache.
    // If lastClaim is null, resolve unlock target from cache or waitHours.
    DateTime? firstUnlockAt;
    if (lastClaim != null) {
      if (prodId.isNotEmpty) {
        FirstClaimCache.clear(prodId);
      }
    } else {
      final canClaimNow = json['canClaimToday'] == true ||
          json['can_claim_today'] == true ||
          json['is24HoursPassed'] == true ||
          json['is_24_hours_passed'] == true;

      if (!canClaimNow && waitH > 0 && prodId.isNotEmpty) {
        firstUnlockAt = FirstClaimCache.resolveTarget(prodId, waitH);
      }
    }

    // Explicit flags from backend API
    bool claimed = json['isClaimedToday'] == true ||
        json['is_claimed_today'] == true ||
        json['claimedToday'] == true ||
        json['claimed_today'] == true ||
        json['canClaimToday'] == false ||
        json['can_claim_today'] == false ||
        json['isClaimed'] == true ||
        json['is_claimed'] == true ||
        json['isClaim'] == true ||
        json['claimed'] == true;

    // Use backend's `is24HoursPassed` flag directly if available, otherwise check difference
    bool is24HoursPassed = json['is24HoursPassed'] == true || json['is_24_hours_passed'] == true;

    if (json.containsKey('is24HoursPassed') || json.containsKey('is_24_hours_passed')) {
      claimed = !is24HoursPassed;
    } else if (!claimed && lastClaim != null) {
      final diff = DateTime.now().difference(lastClaim);
      if (diff.inHours < 24) {
        claimed = true;
      }
    }

    // If it's a first-time purchase with waitHours, it is waiting for first claim
    if (lastClaim == null && waitH > 0) {
      if (firstUnlockAt != null && !DateTime.now().isAfter(firstUnlockAt)) {
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

    final pDate = _parseDateTime(
          json['purchasedAt'] ?? json['purchase_date'] ?? json['purchased_at'] ?? json['purchaseDate'],
        ) ??
        DateTime.now();

    // API থেকে daysPassed না আসলে হিসাব করে বের করা হবে
    int calculatedDaysPassed = _parseInt(json['daysPassed'] ?? json['days_passed'], -1);
    if (calculatedDaysPassed == -1) {
      calculatedDaysPassed = DateTime.now().difference(pDate).inDays;
      // daysPassed যেন 0 এর নিচে না যায় এবং validityDays এর বেশি না হয়
      if (calculatedDaysPassed < 0) calculatedDaysPassed = 0;
      if (calculatedDaysPassed > vDays) calculatedDaysPassed = vDays;
    }

    return PurchasedProductModel(
      id: prodId,
      productCode: json['productCode']?.toString() ?? json['product_code']?.toString() ?? json['productId']?.toString() ?? 'A1',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      price: _parseDouble(json['pricePaid'] ?? json['price']),
      dailyIncome: dailyInc,
      validityDays: vDays,
      daysPassed: calculatedDaysPassed,
      totalEarnings: totalEarn,
      alreadyReceived: _parseDouble(json['alreadyReceived'] ?? json['already_received']),
      purchaseDate: pDate,
      lastClaimedAt: lastClaim,
      isClaimed: claimed,
      status: statusStr,
      waitHours: waitH,
      unlockAt: firstUnlockAt,
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
      'wait_hours': waitHours,
      'unlock_at': unlockAt?.toIso8601String(),
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
    int? waitHours,
    DateTime? unlockAt,
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
      waitHours: waitHours ?? this.waitHours,
      unlockAt: unlockAt ?? this.unlockAt,
    );
  }
}
