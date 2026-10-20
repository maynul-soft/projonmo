import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/widgets/app_network_image/app_network_image.dart';

class AnnouncementImageDialog extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String description;

  const AnnouncementImageDialog({
    super.key,
    required this.imageUrl,
    this.title = '',
    this.description = '',
  });

  @override
  State<AnnouncementImageDialog> createState() => _AnnouncementImageDialogState();
}

class _AnnouncementImageDialogState extends State<AnnouncementImageDialog> {
  bool _isExpanded = false;

  String get _fullText {
    final t = widget.title.trim();
    final d = widget.description.trim();
    if (t.isNotEmpty && d.isNotEmpty && t != d) {
      return '$t\n\n$d';
    }
    return t.isNotEmpty ? t : d;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Portrait mode taking 2/3 of the screen height
    final dialogHeight = (screenSize.height * (2.0 / 3.0)).clamp(380.0, 640.0);
    // Portrait width maintaining a proportional card width
    final dialogWidth = min(screenSize.width * 0.88, dialogHeight * (10.0 / 16.0)).clamp(280.0, 400.0);

    final fullText = _fullText;
    final words = fullText
        .replaceAll('\n', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    final hasWords = words.isNotEmpty;
    final canExpand = words.length > 5 || fullText.contains('\n');
    final collapsedWords = words.length > 5 ? words.take(5).join(' ') : fullText;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 0,
      child: Center(
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full Image Cover
                if (widget.imageUrl.trim().isNotEmpty)
                  AppNetworkImage(
                    imageUrl: widget.imageUrl.trim(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.campaign_rounded,
                        size: 56,
                        color: Colors.white38,
                      ),
                    ),
                  ),

                // 2. Bottom Title Section (Single line collapsed vs Scrollable expanded)
                if (hasWords)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: Alignment.bottomCenter,
                      child: _isExpanded
                          ? _buildExpandedContent(dialogHeight, fullText)
                          : _buildCollapsedContent(collapsedWords, canExpand),
                    ),
                  ),

                // 3. Top-Right Close Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedContent(String collapsedWords, bool canExpand) {
    return GestureDetector(
      onTap: canExpand ? () => setState(() => _isExpanded = true) : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
              Colors.black.withValues(alpha: 0.95),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: canExpand ? '$collapsedWords... ' : collapsedWords,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
                      ),
                    ),
                    if (canExpand)
                      const TextSpan(
                        text: 'see more',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(double dialogHeight, String fullText) {
    return Container(
      constraints: BoxConstraints(maxHeight: dialogHeight * 0.75),
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.88),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    fullText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _isExpanded = false),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'see less',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF38BDF8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
