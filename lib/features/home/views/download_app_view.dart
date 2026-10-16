import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../controllers/home_controller.dart';

class DownloadAppView extends StatefulWidget {
  const DownloadAppView({super.key});

  @override
  State<DownloadAppView> createState() => _DownloadAppViewState();
}

class _DownloadAppViewState extends State<DownloadAppView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18),
              SizedBox(width: 2),
              Text('Back', style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          onPressed: () => Get.back(),
        ),
        leadingWidth: 80,
      ),
      body: _isLoading
          ? const GenericListShimmerView()
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Header Card (Frame 48)
                  Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Green Rounded App Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
                          ),
                          child: const Text(
                            'Projonmo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Quality',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Projonmo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('1+', style: TextStyle(fontSize: 10, color: Colors.black54)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '1st place',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => Get.find<HomeController>().launchAppDownload(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7), // Blue installation button matching Frame 48
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            elevation: 0,
                          ),
                          child: const Text('Free installation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 36, thickness: 0.6),

            // Rating and comments Section (Frame 48)
            const Text(
              'Rating and comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '4.9',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1F2937), height: 1.1),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Full score of 5 points',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRatingBar(5, 0.95),
                    _buildRatingBar(4, 0.08),
                    _buildRatingBar(3, 0.03),
                    _buildRatingBar(2, 0.01),
                    _buildRatingBar(1, 0.02),
                    const SizedBox(height: 4),
                    const Text('19k ratings', style: TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
            const Divider(height: 36, thickness: 0.6),

            // new function Section (Frame 48)
            const Text(
              'new function',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              '1.03',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              '• Enhanced video playback performance\n'
              '• Instant withdrawal settlement notification integration\n'
              '• Regional payment gateways optimized for Bangladesh',
              style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.5),
            ),
            const Divider(height: 36, thickness: 0.6),

            // Information Section
            const Text(
              'information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Developer', 'Projonmo Enterprise Ltd.'),
            _buildInfoRow('Size', '24.5 MB'),
            _buildInfoRow('Category', 'Finance & Agriculture Alliance'),
            _buildInfoRow('Compatibility', 'Android 6.0 and higher / Web PWA'),
            _buildInfoRow('Languages', 'English, Bengali'),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4B5563),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}
