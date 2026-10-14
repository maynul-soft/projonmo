import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/vip_reward_model.dart';

class CheckInController extends GetxController {
  final isCheckedInToday = false.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
    });
  }

  final rewards = <VipRewardModel>[
    VipRewardModel(level: 1, title: 'VIP1', dailyReward: 2.0),
    VipRewardModel(level: 2, title: 'VIP2', dailyReward: 15.0),
    VipRewardModel(level: 3, title: 'VIP3', dailyReward: 70.0),
    VipRewardModel(level: 4, title: 'VIP4', dailyReward: 150.0),
    VipRewardModel(level: 5, title: 'VIP5', dailyReward: 330.0),
    VipRewardModel(level: 6, title: 'VIP6', dailyReward: 680.0),
    VipRewardModel(level: 7, title: 'VIP7', dailyReward: 1700.0),
    VipRewardModel(level: 8, title: 'VIP8', dailyReward: 7000.0),
  ].obs;

  /// Hook for API response
  void setVipRewards(List<VipRewardModel> list) {
    rewards.assignAll(list);
  }

  void claimReward() {
    if (isCheckedInToday.value) {
      Get.snackbar('Notice', AppStrings.alreadyCheckedIn, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final userVip = Get.find<AuthController>().currentUser.value?.vipLevel ?? 1;
    final rewardObj = rewards.firstWhere(
      (r) => r.level == userVip,
      orElse: () => rewards.first,
    );

    isCheckedInToday.value = true;
    Get.find<ProfileController>().addEarnings(rewardObj.dailyReward);

    Get.snackbar(
      AppStrings.success,
      '${AppStrings.checkInSuccess} (+৳${rewardObj.dailyReward})',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
