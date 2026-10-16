import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/image_utils.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../routes/app_routes.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import '../widgets/purchase_bottom_sheet.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  bool _isLoading = true;
  ProductModel? _product;

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  Future<void> _loadProductDetail() async {
    final controller = Get.find<ProductController>();
    final args = Get.arguments;

    String? id;
    ProductModel? initialProduct;

    if (args is ProductModel) {
      initialProduct = args;
      id = args.id;
    } else if (args is Map) {
      id = args['id']?.toString();
    } else if (args is String) {
      id = args;
    }

    if (initialProduct != null) {
      if (mounted) {
        setState(() {
          _product = initialProduct;
          _isLoading = false;
        });
      }
    }

    if (id != null && id.isNotEmpty) {
      final fetched = await controller.fetchProductDetailById(id);
      if (fetched != null && mounted) {
        setState(() {
          _product = fetched;
          _isLoading = false;
        });
        return;
      }
    }

    if (_product == null && mounted) {
      setState(() {
        _product = controller.selectedProduct.value ?? (controller.products.isNotEmpty ? controller.products.first : null);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: AppGlass.flexibleSpace,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
          title: const Text('Loading...', style: TextStyle(color: AppColors.textPrimary)),
          centerTitle: true,
        ),
        body: const ProductDetailShimmerView(),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: AppGlass.flexibleSpace,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            onPressed: () => Get.back(),
          ),
          title: const Text('Product Detail', style: TextStyle(color: AppColors.textPrimary)),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Product not found.', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    // Calculate commissions for display
    final commB = product.dailyIncome * 0.1 * product.validityDays;
    final commC = product.dailyIncome * 0.05 * product.validityDays;
    final commD = product.dailyIncome * 0.02 * product.validityDays;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
              SizedBox(width: 2),
              Text(
                'Back',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              Get.offAllNamed(AppRoutes.main);
            }
          },
        ),
        leadingWidth: 80,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          product.name.isNotEmpty ? product.name : product.code,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              product.vipLevel,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fruit Image Banner
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Image.network(
                    getWebSafeImageUrl(product.imageUrl),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 200,
                      color: AppColors.primaryLight,
                      child: const Center(
                        child: Icon(Icons.eco_rounded, size: 60, color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (product.isUpgradeDay)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Text(
                          AppStrings.upgradeDayBadge,
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            if (product.description.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '[ Description ]',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Product Details Table Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '[ Product Details ]',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Product name:', product.name),
                  _buildDetailRow('Product price:', CurrencyFormatter.format(product.price)),
                  _buildDetailRow('Daily income:', CurrencyFormatter.format(product.dailyIncome)),
                  _buildDetailRow('Contract days:', '${product.validityDays} ${AppStrings.daysSuffix}'),
                  _buildDetailRow('Total revenue:', CurrencyFormatter.format(product.totalEarnings), isHighlight: true),
                  _buildDetailRow('Points reward:', '${product.points} Pts'),
                  _buildDetailRow('Max purchase:', '${product.maxPurchase} time(s)'),
                  _buildDetailRow('Repurchase:', product.allowRepurchase ? 'Allowed' : 'Not allowed'),
                  if (product.availableFrom.isNotEmpty && product.availableTo.isNotEmpty)
                    _buildDetailRow('Available period:', '${product.availableFrom} ~ ${product.availableTo}'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Team Commission Calculation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '[ Team Commission ]',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _buildCommissionFormula('B-10%:', '${product.dailyIncome} * 0.1 * ${product.validityDays} = ${CurrencyFormatter.format(commB)}'),
                  _buildCommissionFormula('C-5%:', '${product.dailyIncome} * 0.05 * ${product.validityDays} = ${CurrencyFormatter.format(commC)}'),
                  _buildCommissionFormula('D-2%:', '${product.dailyIncome} * 0.02 * ${product.validityDays} = ${CurrencyFormatter.format(commD)}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.8))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => PurchaseBottomSheet.show(context, product),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${AppStrings.joinNow} • ${CurrencyFormatter.format(product.price)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isHighlight ? 15 : 13,
                  color: isHighlight ? AppColors.primaryDark : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionFormula(String level, String formula) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formula,
              style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}
