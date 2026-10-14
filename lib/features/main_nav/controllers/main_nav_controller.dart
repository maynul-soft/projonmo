import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../post/controllers/post_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainNavController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      _triggerTabShimmer(index);
    }
  }

  void _triggerTabShimmer(int index) {
    if (index == 0 && Get.isRegistered<HomeController>()) {
      final c = Get.find<HomeController>();
      c.isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () => c.isLoading.value = false);
    } else if (index == 1 && Get.isRegistered<ProductController>()) {
      final c = Get.find<ProductController>();
      c.isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () => c.isLoading.value = false);
    } else if (index == 2 && Get.isRegistered<PostController>()) {
      final c = Get.find<PostController>();
      c.isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () => c.isLoading.value = false);
    } else if (index == 3 && Get.isRegistered<ProfileController>()) {
      final c = Get.find<ProfileController>();
      c.isLoading.value = true;
      Future.delayed(const Duration(seconds: 2), () => c.isLoading.value = false);
    }
  }
}

