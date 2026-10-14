import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../models/funding_transaction_model.dart';

class FundingDetailsController extends GetxController {
  final activeTab = 'all'.obs; // 'all', 'recharge', 'withdraw', 'income'
  final isLoading = true.obs;

  final transactions = <FundingTransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      isLoading.value = true;
      
      // Fetch both transactions (withdraws/deposits) and income history concurrently
      final responses = await Future.wait([
        ApiClient.instance.get(ApiEndpoints.customerTransactions),
        ApiClient.instance.get(ApiEndpoints.customerIncome),
      ]);

      final allTrans = <FundingTransactionModel>[];

      // Parse Deposits & Withdrawals
      final transRes = responses[0];
      if (transRes.data != null && transRes.data is Map) {
        final resMap = Map<String, dynamic>.from(transRes.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final listRaw = resMap['data'];
          if (listRaw is List) {
            for (final item in listRaw) {
              if (item is Map) {
                final map = Map<String, dynamic>.from(item);
                // Adjust type for local filtering logic
                if (map['type'].toString().toLowerCase() == 'deposit') {
                  map['type'] = 'recharge';
                  map['is_credit'] = true;
                } else if (map['type'].toString().toLowerCase() == 'withdrawal') {
                  map['type'] = 'withdraw';
                  map['is_credit'] = false;
                }
                allTrans.add(FundingTransactionModel.fromJson(map));
              }
            }
          }
        }
      }

      // Parse Income
      final incomeRes = responses[1];
      if (incomeRes.data != null && incomeRes.data is Map) {
        final resMap = Map<String, dynamic>.from(incomeRes.data as Map);
        if (resMap['success'] == true && resMap['data'] != null) {
          final listRaw = resMap['data'];
          if (listRaw is List) {
            for (final item in listRaw) {
              if (item is Map) {
                final map = Map<String, dynamic>.from(item);
                map['type'] = 'product_income';
                map['is_credit'] = true;
                allTrans.add(FundingTransactionModel.fromJson(map));
              }
            }
          }
        }
      }

      // Sort by date descending
      allTrans.sort((a, b) => b.date.compareTo(a.date));
      transactions.assignAll(allTrans);

    } catch (e) {
      debugPrint('[FundingDetailsController] Error fetching records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<FundingTransactionModel> get filteredTransactions {
    final tab = activeTab.value;
    if (tab == 'all') return transactions;
    if (tab == 'recharge') return transactions.where((t) => t.type == 'recharge').toList();
    if (tab == 'withdraw') return transactions.where((t) => t.type == 'withdraw').toList();
    if (tab == 'income') {
      return transactions.where((t) => t.type == 'product_income' || t.type == 'commission' || t.type == 'check_in').toList();
    }
    return transactions;
  }
}

class FundingDetailsView extends StatelessWidget {
  const FundingDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FundingDetailsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          'Funding Details',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const FundingShimmerView();
        }

        return Column(
          children: [
            const SizedBox(height: 10),
            // Tab filters: All, Recharge, Withdraw, Income
            _buildFilterTabs(controller),
            const SizedBox(height: 10),

            // Transaction list
            Expanded(
              child: Obx(() {
                final list = controller.filteredTransactions;
                if (list.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text('No transaction records found', style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (ctx, idx) => _buildTransactionCard(list[idx]),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterTabs(FundingDetailsController controller) {
    final tabs = [
      {'label': 'All', 'id': 'all'},
      {'label': 'Recharge', 'id': 'recharge'},
      {'label': 'Withdraws', 'id': 'withdraw'},
      {'label': 'Income', 'id': 'income'},
    ];

    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.map((t) {
          final isSelected = controller.activeTab.value == t['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.activeTab.value = t['id']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  t['label']!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  Widget _buildTransactionCard(FundingTransactionModel tx) {
    final isCredit = tx.isCredit;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForType(tx.type),
              color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.accountOrTrx ?? tx.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.date,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ৳${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tx.status,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'recharge':
        return Icons.add_circle_outline_rounded;
      case 'withdraw':
        return Icons.remove_circle_outline_rounded;
      case 'product_income':
        return Icons.inventory_2_outlined;
      case 'commission':
        return Icons.group_outlined;
      case 'check_in':
        return Icons.event_available_outlined;
      default:
        return Icons.payment_rounded;
    }
  }
}
