import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../controllers/post_controller.dart';
import '../models/post_model.dart';

class PostListView extends GetView<PostController> {
  const PostListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background image shines through
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.postsTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const PostShimmerView();
        }

        if (controller.posts.isEmpty) {
          return const Center(
            child: Text(
              AppStrings.noPostsAvailable,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: controller.posts.length,
          itemBuilder: (ctx, idx) => _buildPostCard(context, controller.posts[idx]),
        );
      }),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.postDetail, arguments: post),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author Header (Logo + Admin + Time ago + Official Post)
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Admin',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                          ],
                        ),
                        Text(
                          post.timeAgo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: const Text(
                      'Official Post',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),

              // Content snippet
              Text(
                post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Multiple Images Layout (1 Big image + up to 5 small thumbnails)
              if (post.images.isNotEmpty) _buildPostImagesCollage(context, post),
            ],
          ),
        ),
      ),
    );
  }

  /// Implements user requirement:
  /// "dhoro 6 ta image ashlo eta image boro kore ashbe and baki 5 ta side diye niche diye soto soto kore thakbe"
  Widget _buildPostImagesCollage(BuildContext context, PostModel post) {
    final images = post.images;
    final featuredImage = images.first;
    final smallImages = images.length > 1 ? images.sublist(1) : <String>[];

    return Column(
      children: [
        // 1. Featured Big Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              featuredImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.primaryLight,
                child: const Icon(Icons.image_outlined, size: 40, color: AppColors.primary),
              ),
            ),
          ),
        ),

        // 2. Remaining Small Images underneath (up to 5 thumbnails in a neat row)
        if (smallImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: Row(
              children: List.generate(
                smallImages.length > 5 ? 5 : smallImages.length,
                (idx) {
                  final isLast = idx == 4 && smallImages.length > 5;
                  final extraCount = smallImages.length - 4;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: idx < 4 ? 6 : 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              smallImages[idx],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: AppColors.surfaceMuted,
                                child: const Icon(Icons.image, size: 16, color: AppColors.textMuted),
                              ),
                            ),
                            // +N overlay if more than 5 remaining
                            if (isLast)
                              Container(
                                color: Colors.black.withValues(alpha: 0.6),
                                alignment: Alignment.center,
                                child: Text(
                                  '+$extraCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
