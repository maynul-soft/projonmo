import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/network/network.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';

class FaqItem {
  final String id;
  final String question;
  final String answer;

  const FaqItem({this.id = '', required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id']?.toString() ?? '').trim(),
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}

class FaqView extends StatefulWidget {
  const FaqView({super.key});

  @override
  State<FaqView> createState() => _FaqViewState();
}

class _FaqViewState extends State<FaqView> {
  final Set<int> _expandedIndices = {};
  bool _isLoading = true;
  List<FaqItem> _faqList = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFaqs();
    });
  }

  Future<void> _fetchFaqs() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.publicFaqs);
      if (response.data != null && response.data is Map) {
        final resMap = Map<String, dynamic>.from(response.data as Map);
        final list = resMap['data'];
        if (list is List && list.isNotEmpty) {
          final fetched = list.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return FaqItem.fromJson(map);
          }).where((f) => f.question.isNotEmpty).toList();

          if (fetched.isNotEmpty && mounted) {
            setState(() {
              _faqList = fetched;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('[FaqView] Error fetching FAQs: $e');
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
          'FAQ',
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
              itemCount: _faqList.length + 1,
              itemBuilder: (context, index) {
              if (index == _faqList.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text('No more', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                );
              }

              final item = _faqList[index];
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
                                item.question,
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
                          item.answer,
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
