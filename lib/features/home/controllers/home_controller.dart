import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/network.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_network_image/app_network_image.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../models/announcement_popup_model.dart';
import '../models/banner_model.dart';
import '../models/lucky_gift_model.dart';
import '../models/video_model.dart';
import '../widgets/announcement_image_dialog.dart';

class HomeController extends GetxController {
  final currentBannerIndex = 0.obs;
  final marqueeNotice = AppStrings.defaultMarquee.obs;
  final isLoading = true.obs;

  // Lucky gift reactive model from API
  final luckyGift = Rx<LuckyGiftModel?>(null);

  // Video reactive model from API
  final promotionalVideo = Rx<VideoModel?>(null);

  // Announcement popup reactive model from API
  final announcementPopup = Rx<AnnouncementPopupModel?>(null);
  bool _hasShownPopupThisSession = false;

  // Countdown timers for Crazy Monday event
  final hoursRemaining = 1.obs;
  final minutesRemaining = 22.obs;
  final secondsRemaining = 35.obs;
  Timer? _countdownTimer;

  // Promotional video player
  final promotionalVideoUrl = 'https://www.youtube.com/watch?v=dVuF9oFxQvI'.obs;
  final isVideoPlaying = false.obs;

  void toggleVideoPlay() {
    isVideoPlaying.value = !isVideoPlaying.value;
  }

  void setVideoPlaying(bool value) {
    isVideoPlaying.value = value;
  }

  void setPromotionalVideoUrl(String url) {
    promotionalVideoUrl.value = url;
  }

  // Reactive banners list from API
  final banners = <BannerModel>[].obs;

  static const int infiniteMultiplier = 10000;
  late final PageController bannerPageController;
  Timer? _bannerTimer;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController(initialPage: 0);
    _startCountdown();
    fetchBanners();
    fetchMarqueeText();
    fetchLuckyGifts();
    fetchVideos();
    fetchAnnouncementPopup();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    if (banners.isEmpty) return;

    final initialPage = (infiniteMultiplier ~/ 2) * banners.length;
    if (bannerPageController.hasClients) {
      bannerPageController.jumpToPage(initialPage);
    }

    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (banners.length > 1 && bannerPageController.hasClients) {
        final currentVisualPage = bannerPageController.page?.round() ?? initialPage;
        bannerPageController.animateToPage(
          currentVisualPage + 1,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  /// Fetch public banners from API (GET /public/banners)
  Future<void> fetchBanners() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicBanners);
      dynamic listRaw;
      if (response.data != null) {
        if (response.data is List) {
          listRaw = response.data;
        } else if (response.data is Map) {
          final resMap = Map<String, dynamic>.from(response.data as Map);
          if (resMap['data'] is List) {
            listRaw = resMap['data'];
          } else if (resMap['banners'] is List) {
            listRaw = resMap['banners'];
          }
        }
      }

      if (listRaw is List) {
        final List<BannerModel> fetched = [];
        for (final item in listRaw) {
          if (item is Map) {
            try {
              final model = BannerModel.fromJson(Map<String, dynamic>.from(item));
              if (model.imageUrl.isNotEmpty) {
                fetched.add(model);
              }
            } catch (e) {
              debugPrint('[HomeController] Error parsing banner: $e');
            }
          }
        }

        if (fetched.isNotEmpty) {
          banners.assignAll(fetched);
          _startBannerAutoSlide();
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching banners: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch public lucky gifts from API (GET /public/lucky-gifts)
  Future<void> fetchLuckyGifts() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicLuckyGifts);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final item = list.first;
          if (item is Map) {
            final gift = LuckyGiftModel.fromJson(Map<String, dynamic>.from(item));
            luckyGift.value = gift;
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching lucky gifts: $e');
    }
  }

  /// Fetch public videos from API (GET /public/videos)
  Future<void> fetchVideos() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicVideos);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final item = list.first;
          if (item is Map) {
            final vid = VideoModel.fromJson(Map<String, dynamic>.from(item));
            promotionalVideo.value = vid;
            if (vid.url.isNotEmpty) {
              promotionalVideoUrl.value = vid.url;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching videos: $e');
    }
  }

  /// Fetch public announcement popup from API (GET /public/announcement-popup)
  Future<void> fetchAnnouncementPopup() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicAnnouncementPopup);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null && resMap['data'] is Map) {
          final dataMap = Map<String, dynamic>.from(resMap['data'] as Map);
          final popup = AnnouncementPopupModel.fromJson(dataMap);

          if (popup.title.isNotEmpty || popup.imageUrl.isNotEmpty || popup.description.isNotEmpty) {
            announcementPopup.value = popup;
            if (!_hasShownPopupThisSession) {
              _hasShownPopupThisSession = true;
              _showAnnouncementDialog(popup);
            }
          }
        } else {
          announcementPopup.value = null;
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching announcement popup: $e');
    }
  }

  void _showAnnouncementDialog(AnnouncementPopupModel popup) {
    showImageAnnouncementDialog(
      imageUrl: popup.imageUrl,
      title: popup.title,
      description: popup.description,
    );
  }

  void showImageAnnouncementDialog({
    required String imageUrl,
    String title = '',
    String description = '',
  }) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      AnnouncementImageDialog(
        imageUrl: imageUrl,
        title: title,
        description: description,
      ),
      barrierDismissible: true,
    );
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else if (minutesRemaining.value > 0) {
        minutesRemaining.value--;
        secondsRemaining.value = 59;
      } else if (hoursRemaining.value > 0) {
        hoursRemaining.value--;
        minutesRemaining.value = 59;
        secondsRemaining.value = 59;
      }
    });
  }

  Future<void> fetchMarqueeText() async {
    try {
      final response = await ApiClient.instance.get('/public/marquee');
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final dataMap = Map<String, dynamic>.from(resMap['data'] as Map);
          if (dataMap['enabled'] == true) {
            marqueeNotice.value = dataMap['text']?.toString() ??
                dataMap['marquee']?.toString() ??
                dataMap['announcement']?.toString() ??
                "";
          } else {
            marqueeNotice.value = ''; // hide or default if disabled
          }
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching marquee: $e');
    }
  }

  /// Hook for API integration to set banners
  void setBanners(List<BannerModel> list) {
    banners.assignAll(list);
  }

  /// Hook for API integration to update notice text
  void setNotice(String notice) {
    marqueeNotice.value = notice;
  }

  void onQuickActionTap(String id) {
    switch (id) {
      case 'weekly':
        Get.toNamed(AppRoutes.weeklySalary);
        break;
      case 'monthly':
        Get.toNamed(AppRoutes.monthlySalary);
        break;
      case 'annual':
        Get.toNamed(AppRoutes.annualSalary);
        break;
      case 'online':
        showOnlineModal();
        break;
      case 'faq':
        Get.toNamed(AppRoutes.faq);
        break;
      case 'rule':
        Get.toNamed(AppRoutes.rule);
        break;
      case 'download':
        launchAppDownload();
        break;
      case 'invitation':
        Get.toNamed(AppRoutes.invitation);
        break;
      default:
        break;
    }
  }

  void launchAppDownload() async {
    bool isCancelled = false;

    // Show Loading Dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Preparing Download...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please wait while we fetch the latest app version.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    isCancelled = true;
                    Get.back(); // Close loading dialog
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    AppStrings.cancel,
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      // Get the download URL from the API
      final response = await ApiClient.instance.get('/public/app-download/file');

      // Close loading dialog if it's still open
      if (Get.isDialogOpen == true && !isCancelled) {
        Get.back();
      }

      if (isCancelled) return;

      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);

        if (resMap['success'] == true && resMap['data'] != null) {
          final dataMap = Map<String, dynamic>.from(resMap['data'] as Map);
          final downloadUrl = dataMap['url']?.toString() ?? '';

          if (downloadUrl.isNotEmpty) {
            final Uri url = Uri.parse(downloadUrl);
            
            Get.snackbar(
              'Download Started',
              'Downloading Projonmo APK...',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF0284C7),
              colorText: Colors.white,
            );

            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              _showDownloadErrorDialog('Could not launch the download link in your browser.');
            }
          } else {
             _showDownloadErrorDialog('Download link is empty or currently unavailable.');
          }
        } else {
          // Backend returned success: false
          final msg = resMap['message']?.toString() ?? 'The download is currently unavailable. Please try again later.';
          _showDownloadErrorDialog(msg);
        }
      } else {
        _showDownloadErrorDialog('Failed to connect to the download server.');
      }
    } catch (e) {
      if (Get.isDialogOpen == true && !isCancelled) {
        Get.back();
      }
      if (isCancelled) return;

      debugPrint('[HomeController] Error launching app download: $e');
      String errorMsg = 'An unexpected error occurred while preparing the download.';
      if (e is ApiException) {
        errorMsg = e.message;
      }
      _showDownloadErrorDialog(errorMsg);
    }
  }

  void _showDownloadErrorDialog(String message) {
    if (Get.isDialogOpen == true) Get.back();
    Get.defaultDialog(
      title: 'Download Failed',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.accentRed),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      radius: 16,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.accentRed, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        onPressed: () => Get.back(),
        child: const Text(AppStrings.close, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void showOnlineModal() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF4D7C0F), // Frame 8 green
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Online',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF65A30D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showInvitationModal() {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    final user = authController.currentUser.value;
    final refCode = user?.referralCode ?? user?.invitationCode ?? user?.memberId ?? '702426';
    final referralUrl = (user?.invitationLink != null && user!.invitationLink!.isNotEmpty)
        ? user.invitationLink!
        : 'https://projonmo.tech/register/$refCode';

    Get.defaultDialog(
      title: AppStrings.invitation,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      contentPadding: const EdgeInsets.all(20),
      radius: 16,
      content: Column(
        children: [
          const Text(
            'Share your referral link to earn Level B (10%), Level C (5%), and Level D (2%) daily commission!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(text: referralUrl));
              Get.snackbar('Copied', 'Referral link copied: $referralUrl', snackPosition: SnackPosition.BOTTOM);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Code: $refCode',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF1B8754)),
                ],
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B8754)),
        onPressed: () {
          Clipboard.setData(ClipboardData(text: referralUrl));
          Get.back();
          Get.snackbar('Copied', 'Referral link copied: $referralUrl', snackPosition: SnackPosition.BOTTOM);
        },
        child: const Text('Copy Referral Link', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void showLuckyGiftModal() {
    final gift = luckyGift.value;
    final title = gift?.name.isNotEmpty == true ? gift!.name : AppStrings.luckyGiftPopupTitle;
    final desc = gift?.details.isNotEmpty == true ? gift!.details : AppStrings.luckyGiftPopupDesc;
    final eventDate = gift?.endAt != null && gift!.endAt!.isNotEmpty
        ? 'Event End Date: ${gift.endAt}'
        : 'Event Date: September 29th ⏰';

    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B8754)),
      contentPadding: const EdgeInsets.all(20),
      radius: 16,
      content: Column(
        children: [
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Text(
            eventDate,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEA580C)),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B8754)),
        onPressed: () => Get.back(),
        child: const Text(AppStrings.close, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }
}
