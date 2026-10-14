import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  final isLoading = true.obs;
  final posts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  /// Fetch public posts from API (GET /public/posts)
  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.publicPosts);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final fetched = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return PostModel.fromJson(map);
          }).where((p) => p.title.isNotEmpty || p.content.isNotEmpty || p.images.isNotEmpty).toList();

          if (fetched.isNotEmpty) {
            posts.assignAll(fetched);
          }
        }
      }
    } catch (e) {
      debugPrint('[PostController] Error fetching posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Hook for API integration to set posts dynamically
  void setPosts(List<PostModel> list) {
    posts.assignAll(list);
  }

  void toggleLike(String postId) {
    final idx = posts.indexWhere((p) => p.id == postId);
    if (idx != -1) {
      final p = posts[idx];
      final isLiked = !p.isLiked;
      final likesCount = isLiked ? p.likesCount + 1 : p.likesCount - 1;
      posts[idx] = p.copyWith(isLiked: isLiked, likesCount: likesCount);
    }
  }
}
