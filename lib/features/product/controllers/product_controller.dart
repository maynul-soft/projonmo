import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/network/network.dart';
import '../../my_products/controllers/my_products_controller.dart';
import '../../my_products/models/purchased_product_model.dart';
import '../../profile/controllers/profile_controller.dart';
import '../models/product_model.dart';

class ProductController extends GetxController {
  final selectedCategory = 'all'.obs;
  final selectedWallet = 'recharge'.obs; // 'recharge' or 'balance'
  final selectedProduct = Rx<ProductModel?>(null);
  final isPurchasing = false.obs;
  final isLoading = true.obs;

  final categories = <CategoryModel>[
    CategoryModel(id: 'all', name: 'All'),
  ].obs;

  final products = <ProductModel>[].obs;

  // Dynamic commission rates (matching Calculator settings from /public/calculator-settings)
  final level1Rate = 7.0.obs;
  final level2Rate = 3.0.obs;
  final level3Rate = 1.0.obs;
  final isCommissionSettingsLoaded = false.obs;

  String formatRate(double rate) {
    if (rate == rate.toInt()) {
      return '${rate.toInt()}%';
    }
    return '${rate.toStringAsFixed(1)}%';
  }

  @override
  void onInit() {
    super.onInit();
    refreshProducts();
  }

  Future<void> refreshProducts() async {
    isLoading.value = true;
    await Future.wait([
      fetchCategories(),
      fetchProducts(),
      fetchCommissionSettings(),
    ]);
  }

  /// Fetch dynamic commission rates from API (GET /public/calculator-settings)
  Future<void> fetchCommissionSettings() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicCalculatorSettings);
      if (response.data != null && (response.data['success'] == true || response.data is Map)) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final data = resMap['data'] != null && resMap['data'] is Map
            ? Map<String, dynamic>.from(resMap['data'] as Map)
            : resMap;
        final stage1 = (data['level1'] ?? data['A'] ?? data['teamStages']?['A'] as num?)?.toDouble();
        final stage2 = (data['level2'] ?? data['B'] ?? data['teamStages']?['B'] as num?)?.toDouble();
        final stage3 = (data['level3'] ?? data['C'] ?? data['teamStages']?['C'] as num?)?.toDouble();
        if (stage1 != null) level1Rate.value = stage1;
        if (stage2 != null) level2Rate.value = stage2;
        if (stage3 != null) level3Rate.value = stage3;
        isCommissionSettingsLoaded.value = true;
      }
    } catch (e) {
      debugPrint('[ProductController] Error fetching commission settings: $e');
    }
  }

  /// Fetch public categories from API (GET /public/categories)
  Future<void> fetchCategories() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicCategories);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final fetched = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return CategoryModel.fromJson(map);
          }).where((c) => c.name.isNotEmpty).toList();

          if (fetched.isNotEmpty) {
            final List<CategoryModel> allCats = [
              CategoryModel(id: 'all', name: 'All'),
              ...fetched,
            ];
            categories.assignAll(allCats);
            selectedCategory.value = 'all';
          }
        }
      }
    } catch (e) {
      debugPrint('[ProductController] Error fetching categories: $e');
    }
  }

  /// Fetch public products from API (GET /public/products)
  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await ApiClient.instance.get(ApiEndpoints.publicProducts);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final fetched = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return ProductModel.fromJson(map);
          }).where((p) => p.name.isNotEmpty).toList();

          if (fetched.isNotEmpty) {
            products.assignAll(fetched);
            _syncCategoriesFromProducts(fetched);
          }
        }
      }
    } catch (e) {
      debugPrint('[ProductController] Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Dynamically extract categories if categories API didn't populate enough
  void _syncCategoriesFromProducts(List<ProductModel> list) {
    if (categories.length > 1) return; // Already populated from Categories API

    final Map<String, String> catMap = {};
    for (final p in list) {
      final idKey = p.categoryId.isNotEmpty ? p.categoryId : p.categoryName;
      final nameVal = p.categoryName.isNotEmpty ? p.categoryName : idKey;
      if (idKey.isNotEmpty) {
        catMap[idKey] = nameVal;
      }
    }

    if (catMap.isNotEmpty) {
      final List<CategoryModel> dynamicCats = [
        CategoryModel(id: 'all', name: 'All'),
      ];
      catMap.forEach((id, name) {
        dynamicCats.add(CategoryModel(id: id, name: name));
      });
      categories.assignAll(dynamicCats);
      selectedCategory.value = 'all';
    }
  }

  /// Fetch single product detail by ID (GET /public/products/:id)
  Future<ProductModel?> fetchProductDetailById(String id) async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicProductDetail(id));
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final data = resMap['data'];
        if (data is Map) {
          return ProductModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      debugPrint('[ProductController] Error fetching product detail for $id: $e');
    }
    return null;
  }

  List<ProductModel> get filteredProducts {
    final myProductsCtrl = Get.isRegistered<MyProductsController>()
        ? Get.find<MyProductsController>()
        : null;

    final purchasedCodes = myProductsCtrl?.purchasedProducts.map((p) => p.productCode.trim()).toSet() ?? {};

    final catId = selectedCategory.value.trim();
    if (catId.isEmpty || catId == 'all') {
      return products.where((p) => !purchasedCodes.contains(p.code.trim())).toList();
    }

    final selectedCat = categories.firstWhereOrNull((c) => c.id.trim() == catId || c.name.trim() == catId);
    final targetName = (selectedCat?.name ?? catId).toLowerCase().trim();
    final targetId = (selectedCat?.id ?? catId).toLowerCase().trim();

    return products.where((p) {
      if (purchasedCodes.contains(p.code.trim())) return false;

      final pCatId = p.categoryId.toLowerCase().trim();
      final pCatName = p.categoryName.toLowerCase().trim();

      if (pCatId.isEmpty && pCatName.isEmpty) return true;

      // 1. Direct Category ID match
      if (targetId.isNotEmpty && pCatId == targetId) return true;

      // 2. Direct Category Name match
      if (targetName.isNotEmpty && (pCatName == targetName || pCatId == targetName)) return true;

      // 3. Category Name vs Target ID
      if (pCatName == targetId) return true;

      // 4. Substring / fuzzy match
      if (targetName.isNotEmpty && pCatName.contains(targetName)) return true;
      if (targetName.isNotEmpty && targetName.contains(pCatName) && pCatName.isNotEmpty) return true;

      return false;
    }).toList();
  }

  void selectCategory(String categoryId) {
    if (selectedCategory.value == categoryId) return;
    selectedCategory.value = categoryId;
  }

  /// Hook for API to replace categories dynamically
  void setCategories(List<CategoryModel> list) {
    categories.assignAll(list);
  }

  /// Hook for API to replace products dynamically
  void setProducts(List<ProductModel> list) {
    products.assignAll(list);
  }

  Future<void> purchaseProduct(ProductModel product) async {
    final profileController = Get.find<ProfileController>();
    final myProductsController = Get.find<MyProductsController>();

    final balanceAvailable = selectedWallet.value == 'recharge'
        ? profileController.walletData.value.rechargeWallet
        : profileController.walletData.value.balanceWallet;

    if (balanceAvailable < product.price) {
      Get.snackbar(
        AppStrings.error,
        '${AppStrings.insufficientBalance} (Required: ৳${product.price})',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isPurchasing.value = true;

      // Call API: POST /api/v1/customer/products/:id/purchase
      final response = await ApiClient.instance.post(
        ApiEndpoints.customerPurchaseProductById(product.id),
      );

      final resData = response.data;
      if (resData is Map && resData['success'] == true && resData['data'] != null) {
        final data = Map<String, dynamic>.from(resData['data']);
        
        // Extract points from response
        final int pointsAwarded = (data['pointsAwarded'] as num?)?.toInt() ?? 0;
        final int pointsBalance = (data['pointsBalance'] as num?)?.toInt() ?? profileController.walletData.value.points + pointsAwarded;

        // Deduct balance from profile locally for instant UI update
        profileController.deductFunds(product.price, fromRechargeWallet: selectedWallet.value == 'recharge');
        
        // Update points in profile
        final curWallet = profileController.walletData.value;
        profileController.setWalletData(curWallet.copyWith(points: pointsBalance));

        // Add the newly purchased product to the list
        myProductsController.addProduct(PurchasedProductModel.fromJson(data));

        Get.back(); // close bottomsheet
        
        // Show Success Dialog
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 50),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Purchase Successful!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    resData['message']?.toString() ?? 'You have successfully purchased ${product.name}.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  if (pointsAwarded > 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            '+$pointsAwarded Points Earned!',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New Point Balance: $pointsBalance',
                      style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back(); // close dialog
                        // optionally redirect to My Products if wanted
                        // Get.toNamed(AppRoutes.myProducts); 
                      },
                      child: const Text('Great', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        throw ApiException(message: resData['message']?.toString() ?? 'Purchase failed');
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Purchase Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[ProductController] Error during purchase: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred during purchase.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isPurchasing.value = false;
    }
  }
}
