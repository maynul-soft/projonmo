class ProductModel {
  final String id;
  final String code;
  final String name;
  final String imageUrl;
  final String vipLevel;
  final double price;
  final int points;
  final int validityDays;
  final double dailyIncome;
  final double totalEarnings;
  final bool isUpgradeDay;
  final double invitationBonus;
  final double upgradeBonus;
  final String description;
  final String categoryId;
  final String categoryName;
  final double teamCommission;
  final int minPurchase;
  final int maxPurchase;
  final bool allowRepurchase;
  final String availableFrom;
  final String availableTo;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.imageUrl,
    required this.vipLevel,
    required this.price,
    required this.points,
    required this.validityDays,
    required this.dailyIncome,
    required this.totalEarnings,
    this.isUpgradeDay = true,
    this.invitationBonus = 0.0,
    this.upgradeBonus = 0.0,
    this.description = '',
    this.categoryId = 'all',
    this.categoryName = '',
    this.teamCommission = 0.0,
    this.minPurchase = 1,
    this.maxPurchase = 1,
    this.allowRepurchase = true,
    this.availableFrom = '',
    this.availableTo = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name']?.toString() ?? 'Investment Package';
    final rawCode = json['code']?.toString() ?? rawName;
    final rawVip = json['minVip']?.toString() ?? json['min_vip']?.toString() ?? json['vipLevel']?.toString() ?? json['vip_level']?.toString() ?? '1';

    String formattedVip = rawVip;
    if (rawVip.isNotEmpty && !rawVip.toLowerCase().contains('vip') && !rawVip.toLowerCase().contains('level')) {
      formattedVip = 'VIP $rawVip and above';
    }

    final rawPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final rawDaily = (json['dailyIncome'] ?? json['daily_income'] as num?)?.toDouble() ?? 0.0;
    final rawDays = (json['contractDays'] ?? json['contract_days'] ?? json['validityDays'] ?? json['validity_days'] as num?)?.toInt() ?? 30;
    final rawTotal = (json['totalReturn'] ?? json['total_return'] ?? json['totalEarnings'] ?? json['total_earnings'] as num?)?.toDouble() ?? (rawDaily * rawDays);

    String catId = '';
    String catName = '';

    if (json['category'] is Map) {
      final catMap = Map<String, dynamic>.from(json['category'] as Map);
      catId = catMap['id']?.toString() ?? catMap['_id']?.toString() ?? '';
      catName = catMap['name']?.toString() ?? catMap['title']?.toString() ?? '';
    } else if (json['category'] is String) {
      catName = json['category'].toString();
    }

    if (catId.isEmpty) {
      catId = json['categoryId']?.toString() ?? json['category_id']?.toString() ?? '';
    }

    if (catName.isEmpty) {
      catName = json['categoryName']?.toString() ?? json['category_name']?.toString() ?? catId;
    }

    return ProductModel(
      id: (json['id']?.toString() ?? '').trim(),
      code: rawCode,
      name: rawName,
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? json['image']?.toString() ?? '',
      vipLevel: formattedVip,
      price: rawPrice,
      points: (json['points'] as num?)?.toInt() ?? 0,
      validityDays: rawDays,
      dailyIncome: rawDaily,
      totalEarnings: rawTotal,
      isUpgradeDay: json['isUpgradeDay'] ?? json['is_upgrade_day'] ?? true,
      invitationBonus: (json['invitationBonus'] ?? json['invitation_bonus'] as num?)?.toDouble() ?? (rawPrice * 0.1),
      upgradeBonus: (json['upgradeBonus'] ?? json['upgrade_bonus'] as num?)?.toDouble() ?? (rawPrice * 0.05),
      description: json['description']?.toString() ?? '',
      categoryId: catId.trim(),
      categoryName: catName.isNotEmpty ? catName : catId,
      teamCommission: (json['teamCommission'] ?? json['team_commission'] as num?)?.toDouble() ?? 0.0,
      minPurchase: (json['minPurchase'] ?? json['min_purchase'] as num?)?.toInt() ?? 1,
      maxPurchase: (json['maxPurchase'] ?? json['max_purchase'] as num?)?.toInt() ?? 1,
      allowRepurchase: json['allowRepurchase'] ?? json['allow_repurchase'] ?? true,
      availableFrom: json['availableFrom']?.toString() ?? json['available_from']?.toString() ?? '',
      availableTo: json['availableTo']?.toString() ?? json['available_to']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'imageUrl': imageUrl,
      'vipLevel': vipLevel,
      'price': price,
      'points': points,
      'contractDays': validityDays,
      'dailyIncome': dailyIncome,
      'totalReturn': totalEarnings,
      'isUpgradeDay': isUpgradeDay,
      'invitationBonus': invitationBonus,
      'upgradeBonus': upgradeBonus,
      'description': description,
      'categoryId': categoryId,
      'category': categoryName,
      'teamCommission': teamCommission,
      'minPurchase': minPurchase,
      'maxPurchase': maxPurchase,
      'allowRepurchase': allowRepurchase,
      'availableFrom': availableFrom,
      'availableTo': availableTo,
    };
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int displayOrder;
  final int productCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.displayOrder = 0,
    this.productCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final idStr = (json['id']?.toString() ?? '').trim();
    final nameStr = json['name']?.toString() ?? json['title']?.toString() ?? '';

    return CategoryModel(
      id: idStr.isNotEmpty ? idStr : nameStr,
      name: nameStr.isNotEmpty ? nameStr : idStr,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? '',
      displayOrder: (json['displayOrder'] ?? json['display_order'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] ?? json['product_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'productCount': productCount,
    };
  }
}
