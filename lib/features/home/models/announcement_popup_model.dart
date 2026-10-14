class AnnouncementPopupModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String link;

  AnnouncementPopupModel({
    required this.id,
    required this.title,
    this.description = '',
    this.imageUrl = '',
    this.link = '',
  });

  factory AnnouncementPopupModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementPopupModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? json['details']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          json['image']?.toString() ??
          json['bannerUrl']?.toString() ??
          json['banner_url']?.toString() ??
          '',
      link: json['link']?.toString() ?? json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'link': link,
    };
  }
}
