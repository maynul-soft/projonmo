import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/network.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';

class RuleItem {
  final String id;
  final String title;
  final String content;

  const RuleItem({
    this.id = '',
    required this.title,
    required this.content,
  });

  factory RuleItem.fromJson(Map<String, dynamic> json) {
    return RuleItem(
      id: (json['id']?.toString() ?? '').trim(),
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}

class RuleView extends StatefulWidget {
  const RuleView({super.key});

  @override
  State<RuleView> createState() => _RuleViewState();
}

class _RuleViewState extends State<RuleView> {
  final Set<int> _expandedIndices = {};
  bool _isLoading = true;

  List<RuleItem> _rules = const [
    RuleItem(
      id: '1',
      title: '📅 Our Weekly Schedule',
      content:
          '• Monday & Tuesday: Upgrade Days — Claim double point rewards upon upgrading your VIP membership tier.\n\n'
          '• Wednesday: General Agricultural Inspection & Farm Harvest Reporting Day.\n\n'
          '• Thursday & Friday: Team Invitation Days — Extra referral commission and team leader bonuses.\n\n'
          '• Saturday: Weekly Financial Settlement & Audit.\n\n'
          '• Sunday: Weekly Salary Distribution — Claimable from 10:00 AM to 10:00 PM.',
    ),
    RuleItem(
      id: '2',
      title: '📅 Thursday and Friday: Invitation Days',
      content:
          'On Thursdays and Fridays, members who invite active team members receive double points and special team bonus matching! Make sure to invite friends during these 48 hours for maximum return.',
    ),
    RuleItem(
      id: '3',
      title: '📅 Monday & Tuesday: Upgrade Day',
      content:
          'On Mondays and Tuesdays, you can earn points in addition to upgrade rewards! ⭐\n\n'
          'Any member upgrading their contract level receives instant bonus cashback credited to their balance wallet.',
    ),
    RuleItem(
      id: '4',
      title: '🔥 Product Details',
      content:
          '• Contract Period: Every product contract runs for a designated term (e.g. 44 to 60 days).\n\n'
          '• Daily Returns: Earnings are calculated and added to your balance wallet every 24 hours.\n\n'
          '• Re-investment: Upon maturity, principal and total earnings are fully settled.',
    ),
    RuleItem(
      id: '5',
      title: 'ℹ️ About team commissions',
      content:
          'Team commissions are distributed across 3 direct relationship stages:\n\n'
          '• Stage B (Direct Invitees): 10% daily commission on every product return.\n'
          '• Stage C (Second-tier Invitees): 5% daily commission.\n'
          '• Stage D (Third-tier Invitees): 2% daily commission.\n\n'
          'Commissions are disbursed automatically without any deduction or delays.',
    ),
    RuleItem(
      id: '6',
      title: '⚠️ Account VIP Level Rules',
      content:
          '• VIP 1: Activated with basic contract package.\n'
          '• VIP 2 - VIP 4: Requires specific team size and cumulative contract holdings.\n'
          '• VIP 5 - VIP 8: Unlocks exclusive weekly and monthly salaries up to ৳2,800,000.\n\n'
          'Levels are upgraded automatically once the qualifying turnover is reached.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRules();
    });
  }

  Future<void> _fetchRules() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicRules);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final fetched = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return RuleItem.fromJson(map);
          }).where((r) => r.title.isNotEmpty || r.content.isNotEmpty).toList();

          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _rules = fetched;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[RuleView] Error fetching rules: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
        title: const Text(
          'Rule',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Image.asset(
            AppAssets.scaffoldBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => Container(color: const Color(0xFFF0FDF4)),
          ),
          Container(color: Colors.black.withValues(alpha: 0.04)),
          if (_isLoading)
            const GenericListShimmerView()
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _rules.length + 1,
              itemBuilder: (context, index) {
                if (index == _rules.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No more', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ),
                  );
                }

                final item = _rules[index];
                final isExpanded = _expandedIndices.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIndices.remove(index);
                            } else {
                              _expandedIndices.add(index);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                color: AppColors.primaryDark.withValues(alpha: 0.2),
                                width: 1.2,
                              ),
                            ),
                          ),
                          child: Text(
                            item.content,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
