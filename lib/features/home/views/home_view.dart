import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_network_image/app_network_image.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/marquee_text.dart';
import '../../../core/widgets/video_player/app_video_player.dart';
import '../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBanners();
      controller.fetchLuckyGifts();
      controller.fetchVideos();
      controller.fetchAnnouncementPopup();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Obx(() => controller.isLoading.value
                ? _buildBannerShimmer()
                : _buildBannerCarousel(context)),
            const SizedBox(height: 12),
            Obx(() => controller.isLoading.value
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: ShimmerColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: const AppShimmer(
                        child: Row(
                          children: [
                            ShimmerCircle(size: 18),
                            SizedBox(width: 8),
                            Expanded(child: ShimmerLine(height: 14)),
                          ],
                        ),
                      ),
                    ),
                  )
                : _buildMarqueeAnnouncement(context)),
            const SizedBox(height: 16),
            // Static Quick Action Grid (Weekly Salary, Monthly Salary, etc.) - Direct load without shimmer
            _buildQuickActionGrid(context),
            const SizedBox(height: 16),
            Obx(() => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ShimmerCard(
                      margin: EdgeInsets.zero,
                      child: Row(
                        children: [
                          ShimmerBox(width: 48, height: 48, borderRadius: 12),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLine(width: 140, height: 16),
                                SizedBox(height: 8),
                                ShimmerLine(width: 90, height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _buildLuckyGiftCard(context)),
            const SizedBox(height: 16),
            Obx(() => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ShimmerCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(height: 160, borderRadius: 12),
                          SizedBox(height: 12),
                          ShimmerLine(width: 160, height: 16),
                          SizedBox(height: 6),
                          ShimmerLine(width: 220, height: 12),
                        ],
                      ),
                    ),
                  )
                : _buildVideoPromoCard(context)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: AppGlass.flexibleSpace,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              AppAssets.appLogo,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Grab your device',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text(
                'English',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Get.toNamed(AppRoutes.notifications),
          icon: const Badge(
            smallSize: 8,
            child: Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBannerShimmer() {
    return Column(
      children: [
        Container(
          height: 170,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ShimmerColors.card, // Light grey shape (#DFDFDF)
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Inside the banner towards the bottom, grey title shape where title is
              Positioned(
                left: 16,
                bottom: 16,
                child: AppShimmer(
                  child: ShimmerLine(
                    width: 220,
                    height: 20,
                    borderRadius: 100,
                    color: ShimmerColors.element, // Medium grey (#BFBFBF)
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppShimmer(
              child: ShimmerBox(width: 20, height: 6, borderRadius: 3, color: ShimmerColors.element),
            ),
            const SizedBox(width: 6),
            AppShimmer(
              child: ShimmerBox(width: 6, height: 6, borderRadius: 3, color: ShimmerColors.element),
            ),
            const SizedBox(width: 6),
            AppShimmer(
              child: ShimmerBox(width: 6, height: 6, borderRadius: 3, color: ShimmerColors.element),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCarousel(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Obx(() {
            final bannerCount = controller.banners.length;
            if (bannerCount == 0) return const SizedBox.shrink();

            return PageView.builder(
              controller: controller.bannerPageController,
              onPageChanged: (idx) => controller.currentBannerIndex.value = idx % bannerCount,
              itemBuilder: (ctx, idx) {
                final banner = controller.banners[idx % bannerCount];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                            child: const Center(
                              child: Icon(Icons.shopping_bag_rounded, size: 48, color: Colors.white54),
                            ),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(gradient: AppColors.bannerOverlay),
                        ),
                        if (banner.title != null || banner.subtitle != null)
                          Positioned(
                            left: 16,
                            bottom: 14,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (banner.title != null && banner.title!.isNotEmpty)
                                  Text(
                                    banner.title!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                    ),
                                  ),
                                if (banner.subtitle != null && banner.subtitle!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    banner.subtitle!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.88),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        Obx(() => Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                controller.banners.length,
                (idx) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: controller.currentBannerIndex.value == idx ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: controller.currentBannerIndex.value == idx
                        ? AppColors.primary
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildMarqueeAnnouncement(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final popup = controller.announcementPopup.value;
        if (popup != null) {
          controller.showImageAnnouncementDialog(
            imageUrl: popup.imageUrl,
            title: popup.title,
            description: popup.description,
          );
        } else {
          controller.showImageAnnouncementDialog(
            imageUrl: '',
            title: 'Announcement',
            description: controller.marqueeNotice.value,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() => MarqueeText(
                text: controller.marqueeNotice.value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
                velocity: 38.0,
                blankSpace: 40.0,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    final actions = [
      {'id': 'weekly', 'title': AppStrings.weeklySalary, 'icon': Icons.calendar_today_rounded, 'color': const Color(0xFF10B981)},
      {'id': 'monthly', 'title': AppStrings.monthlySalary, 'icon': Icons.date_range_rounded, 'color': const Color(0xFF059669)},
      {'id': 'annual', 'title': AppStrings.annualSalary, 'icon': Icons.savings_rounded, 'color': const Color(0xFF0D9488)},
      {'id': 'online', 'title': AppStrings.onlineService, 'icon': Icons.support_agent_rounded, 'color': const Color(0xFF2563EB)},
      {'id': 'faq', 'title': AppStrings.faq, 'icon': Icons.help_outline_rounded, 'color': const Color(0xFF7C3AED)},
      {'id': 'rule', 'title': AppStrings.rule, 'icon': Icons.menu_book_rounded, 'color': const Color(0xFFD97706)},
      {'id': 'download', 'title': AppStrings.downloadApp, 'icon': Icons.download_rounded, 'color': const Color(0xFF0284C7)},
      {'id': 'invitation', 'title': AppStrings.invitation, 'icon': Icons.person_add_alt_1_rounded, 'color': const Color(0xFFE11D48)},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.9, // Adjust ratio for better fitting
        ),
        itemCount: actions.length,
        itemBuilder: (ctx, idx) {
          final item = actions[idx];
          final color = item['color'] as Color;
          return InkWell(
            onTap: () => controller.onQuickActionTap(item['id'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center align vertically
              children: [
                Container(
                  padding: const EdgeInsets.all(14), // Bigger background
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16), // Softer corners
                  ),
                  child: Icon(item['icon'] as IconData, size: 26, color: color), // Bigger icon
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] as String,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2, // Tighter line height
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLuckyGiftCard(BuildContext context) {
    return Obx(() {
      final gift = controller.luckyGift.value;
      final bannerUrl = gift?.bannerUrl ?? '';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB45309).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image or Fallback Gradient
              Positioned.fill(
                child: bannerUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: bannerUrl,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF854D0E), Color(0xFFB45309), Color(0xFFD97706)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF854D0E), Color(0xFFB45309), Color(0xFFD97706)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
              ),

              // Soft dark overlay to guarantee text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        const Color(0xFF854D0E).withValues(alpha: 0.78),
                        const Color(0xFFB45309).withValues(alpha: 0.65),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
          Obx(() {
            final gift = controller.luckyGift.value;
            final name = gift?.name.isNotEmpty == true ? gift!.name : AppStrings.crazyMondayTitle;
            final details = gift?.details.isNotEmpty == true
                ? gift!.details
                : '${AppStrings.luckyGiftTitle} • Win up to ৳100,000';

            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 26),
                ),
              ],
            );
          }),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isVeryNarrow = constraints.maxWidth < 290;
              final timerRow = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TIME REMAINING: ',
                    style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Obx(() => _buildTimerBlock(controller.hoursRemaining.value.toString().padLeft(2, '0'))),
                  const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  Obx(() => _buildTimerBlock(controller.minutesRemaining.value.toString().padLeft(2, '0'))),
                  const Text(' : ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  Obx(() => _buildTimerBlock(controller.secondsRemaining.value.toString().padLeft(2, '0'))),
                ],
              );

              final participateBtn = ElevatedButton(
                onPressed: controller.showLuckyGiftModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFB45309),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  AppStrings.participateNow,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              );

              if (isVeryNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: timerRow,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: participateBtn,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: timerRow,
                    ),
                  ),
                  const SizedBox(width: 8),
                  participateBtn,
                ],
              );
            },
          ),
        ],
      ),
    ),
  ],
),
),
);
});
}

  Widget _buildTimerBlock(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildVideoPromoCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final isPlaying = controller.isVideoPlaying.value;
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: isPlaying
                    ? Stack(
                        children: [
                          PlatformVideoPlayer(
                            videoUrl: controller.promotionalVideoUrl.value,
                            autoPlay: true,
                            showControls: true,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => controller.setVideoPlaying(false),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.65),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF065F46), Color(0xFF047857)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: AppNetworkImage(
                              imageUrl: controller.promotionalVideo.value?.thumbnailUrl.isNotEmpty == true
                                  ? controller.promotionalVideo.value!.thumbnailUrl
                                  : 'https://elements-resized.envatousercontent.com/elements-cover-images/3636fe3b-f647-44d7-a5bf-e1f7c73c5d57?w=433&cf_fit=scale-down&q=85&format=auto&s=46417af98699675c7088cef0dd693b0d1a5d66aa5ab8f497fa120271c233a6a6',
                              fit: BoxFit.cover,
                              errorWidget: const Center(
                                child: Icon(Icons.nature_people_rounded, size: 60, color: Colors.white30),
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.setVideoPlaying(true);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              child: const Text(
                                'Tap to Play',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    final vid = controller.promotionalVideo.value;
                    final title = vid?.title.isNotEmpty == true ? vid!.title : AppStrings.promotionalVideo;
                    final desc = vid?.description?.isNotEmpty == true ? vid!.description! : 'Visit and learn more about us';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          desc,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }),
                ),
                IconButton(
                  tooltip: 'Fullscreen Video',
                  onPressed: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.black,
                        insetPadding: const EdgeInsets.all(16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 460),
                          child: Stack(
                            children: [
                              PlatformVideoPlayer(
                                videoUrl: controller.promotionalVideoUrl.value,
                                autoPlay: true,
                                showControls: true,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                                  onPressed: () => Get.back(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
