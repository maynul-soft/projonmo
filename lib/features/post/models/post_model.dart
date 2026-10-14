class PostModel {
  final String id;
  final String title;
  final String content;
  final String author;
  final String authorAvatar;
  final String timeAgo;
  final List<String> images;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String? tag;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.authorAvatar,
    required this.timeAgo,
    required this.images,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.tag,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imageUrls'] ?? json['image_urls'] ?? json['images'];
    List<String> parsedImages = [];
    if (rawImages is List) {
      parsedImages = rawImages.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
    }

    final rawTime = json['publishedAt']?.toString() ?? json['published_at']?.toString() ?? json['timeAgo']?.toString() ?? json['time_ago']?.toString() ?? '';

    return PostModel(
      id: (json['id']?.toString() ?? '').trim(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Projonmo Official',
      authorAvatar: json['authorAvatar']?.toString() ?? json['author_avatar']?.toString() ?? '',
      timeAgo: rawTime.isNotEmpty ? rawTime : 'Recent',
      images: parsedImages,
      likesCount: (json['likesCount'] ?? json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] ?? json['comments_count'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      tag: json['tag']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'authorAvatar': authorAvatar,
      'timeAgo': timeAgo,
      'imageUrls': images,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'tag': tag,
    };
  }

  PostModel copyWith({
    String? id,
    String? title,
    String? content,
    String? author,
    String? authorAvatar,
    String? timeAgo,
    List<String>? images,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    String? tag,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timeAgo: timeAgo ?? this.timeAgo,
      images: images ?? this.images,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      tag: tag ?? this.tag,
    );
  }
}
