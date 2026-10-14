class VideoModel {
  final String id;
  final String title;
  final String url;
  final String thumbnailUrl;
  final String? description;
  final int order;

  VideoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
    this.description,
    this.order = 0,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: (json['id']?.toString() ?? '').trim(),
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['thumbnail_url']?.toString() ?? '',
      description: json['description']?.toString(),
      order: int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'order': order,
    };
  }
}
