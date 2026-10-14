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
    ]);
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
        
        // Deduct balance from profile locally for instant UI update
        profileController.deductFunds(product.price, fromRechargeWallet: selectedWallet.value == 'recharge');

        // Add the newly purchased product to the list
        myProductsController.addProduct(PurchasedProductModel.fromJson(data));

        Get.back(); // close bottomsheet
        Get.snackbar(
          AppStrings.success, 
          resData['message']?.toString() ?? AppStrings.purchaseSuccess, 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
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
