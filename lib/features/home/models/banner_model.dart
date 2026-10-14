class BannerModel {
  final String id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? targetUrl;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.targetUrl,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: (json['id']?.toString() ?? json['_id']?.toString() ?? '').trim(),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString() ?? json['image']?.toString() ?? json['bannerUrl']?.toString() ?? json['banner_url']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString(),
      subtitle: json['subtitle']?.toString() ?? json['description']?.toString() ?? json['details']?.toString(),
      targetUrl: json['link']?.toString() ?? json['target_url']?.toString() ?? json['targetUrl']?.toString() ?? json['url']?.toString() ?? json['redirect_url']?.toString() ?? json['redirectUrl']?.toString() ?? json['path']?.toString() ?? json['route']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'target_url': targetUrl,
    };
  }
}

class QuickActionItem {
  final String id;
  final String title;
  final String icon;
  final String? route;

  QuickActionItem({
    required this.id,
    required this.title,
    required this.icon,
    this.route,
  });

  factory QuickActionItem.fromJson(Map<String, dynamic> json) {
    return QuickActionItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      route: json['route']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'route': route,
    };
  }
}
