class LuckyGiftModel {
  final String id;
  final String name;
  final String details;
  final String bannerUrl;
  final String? endAt;
  final String? productId;
  final String status;

  LuckyGiftModel({
    required this.id,
    required this.name,
    required this.details,
    required this.bannerUrl,
    this.endAt,
    this.productId,
    this.status = 'Active',
  });

  factory LuckyGiftModel.fromJson(Map<String, dynamic> json) {
    return LuckyGiftModel(
      id: (json['id']?.toString() ?? '').trim(),
      name: json['name']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      bannerUrl: json['bannerUrl']?.toString() ?? json['banner_url']?.toString() ?? '',
      endAt: json['endAt']?.toString() ?? json['end_at']?.toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      status: json['status']?.toString() ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'bannerUrl': bannerUrl,
      'endAt': endAt,
      'productId': productId,
      'status': status,
    };
  }
}
