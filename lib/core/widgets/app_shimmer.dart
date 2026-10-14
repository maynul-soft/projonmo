import 'package:flutter/material.dart';

/// Exact Shimmer Palette matching user reference image
class ShimmerColors {
  /// Light Grey for outer container cards (#DFDFDF)
  static const Color card = Color(0xFFDFDFDF);

  /// Medium Grey for inner pill lines, dots, and boxes (#BFBFBF)
  static const Color element = Color(0xFFBFBFBF);

  /// Shimmer wave highlight sweep (#EBEBEB)
  static const Color highlight = Color(0xFFEBEBEB);
}

/// Professional Animated Shimmer Engine
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = ShimmerColors.element, // #BFBFBF
    this.highlightColor = ShimmerColors.highlight, // #EBEBEB
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              stops: const [0.1, 0.5, 0.9],
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2 - 1), 0.0, 0.0);
  }
}

/// Shimmer container card matching the reference image (light grey rounded container: #DFDFDF)
class ShimmerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  const ShimmerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ShimmerColors.card,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: AppShimmer(
        baseColor: ShimmerColors.element,
        highlightColor: ShimmerColors.highlight,
        child: child,
      ),
    );
  }
}

/// Shimmer rounded box / pill
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 100, // Pill shaped by default as in reference image
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? ShimmerColors.element,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer line simulating text line with pill-shaped ends
class ShimmerLine extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color? color;

  const ShimmerLine({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 100, // Pill shape with rounded ends
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
      color: color ?? ShimmerColors.element,
    );
  }
}

/// Shimmer circle for avatars and dots
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const ShimmerCircle({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? ShimmerColors.element,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Shimmer row representing label & value pair
class ShimmerRow extends StatelessWidget {
  final double leftWidth;
  final double rightWidth;

  const ShimmerRow({
    super.key,
    this.leftWidth = 65,
    this.rightWidth = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerLine(width: leftWidth, height: 10),
          ShimmerLine(width: rightWidth, height: 11),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Screen-Specific Shimmer Skeletons
// ---------------------------------------------------------

/// Home Screen Skeleton
class HomeShimmerView extends StatelessWidget {
  const HomeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Skeleton: Light grey container (#DFDFDF) with title pill at bottom (#BFBFBF)
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: ShimmerColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Stack(
                children: [
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: ShimmerLine(
                      width: 220,
                      height: 18,
                      borderRadius: 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Carousel Dots Skeleton
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 20, height: 6, borderRadius: 3),
                SizedBox(width: 6),
                ShimmerBox(width: 6, height: 6, borderRadius: 3),
                SizedBox(width: 6),
                ShimmerBox(width: 6, height: 6, borderRadius: 3),
              ],
            ),
            const SizedBox(height: 12),

            // Marquee Bar Skeleton
            const ShimmerBox(height: 42, borderRadius: 12),
            const SizedBox(height: 14),

            // Quick Actions 8 Grid Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: 8,
                itemBuilder: (_, _) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerBox(height: 44, width: 44, borderRadius: 12),
                    SizedBox(height: 8),
                    ShimmerLine(width: 48, height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Lucky Gift Box Skeleton
            const ShimmerBox(height: 96, borderRadius: 16),
            const SizedBox(height: 14),

            // Video Promo Card Skeleton
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 180, borderRadius: 16),
                  Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 160, height: 16),
                        SizedBox(height: 6),
                        ShimmerLine(width: 220, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product Screen Skeleton - Matches exact horizontal product card layout
class ProductShimmerView extends StatelessWidget {
  const ProductShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, _) => ShimmerCard(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: 64x64 thumbnail + Code + VIP + Price + Points
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 64, height: 64, borderRadius: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            ShimmerLine(width: 90, height: 16),
                            SizedBox(width: 8),
                            ShimmerBox(width: 60, height: 18, borderRadius: 100),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            ShimmerLine(width: 36, height: 12),
                            SizedBox(width: 6),
                            ShimmerLine(width: 65, height: 15),
                            Spacer(),
                            ShimmerBox(width: 52, height: 18, borderRadius: 100),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: ShimmerColors.element.withValues(alpha: 0.6)),
              const SizedBox(height: 12),

              // Bottom Stats Row & Join Button
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 50, height: 10),
                        SizedBox(height: 4),
                        ShimmerLine(width: 40, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 50, height: 10),
                        SizedBox(height: 4),
                        ShimmerLine(width: 45, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 50, height: 10),
                        SizedBox(height: 4),
                        ShimmerLine(width: 45, height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const ShimmerBox(width: 72, height: 30, borderRadius: 100),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Product Detail Skeleton - Light grey cards (#DFDFDF) with grey pills (#BFBFBF)
class ProductDetailShimmerView extends StatelessWidget {
  const ProductDetailShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image Banner Skeleton (#DFDFDF card)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: ShimmerColors.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: AppShimmer(
                child: ShimmerCircle(size: 48),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description Card Skeleton (#DFDFDF card with #BFBFBF pills)
          ShimmerCard(
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 110, height: 16),
                SizedBox(height: 12),
                ShimmerLine(width: double.infinity, height: 14),
                SizedBox(height: 8),
                ShimmerLine(width: 240, height: 14),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Product Details Table Card Skeleton
          ShimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLine(width: 130, height: 16),
                const SizedBox(height: 14),
                ...List.generate(
                  6,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerLine(width: 90, height: 13),
                        ShimmerLine(width: 80, height: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Team Commission Calculation Card Skeleton
          ShimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLine(width: 160, height: 16),
                const SizedBox(height: 12),
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        ShimmerBox(width: 50, height: 14, borderRadius: 100),
                        SizedBox(width: 8),
                        Expanded(child: ShimmerLine(height: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Post Community Screen Skeleton - Exactly mirrors _buildPostCard
class PostShimmerView extends StatelessWidget {
  const PostShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (_, _) => ShimmerCard(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Header: 36x36 rounded square logo + Admin text & time + Official Post badge
            Row(
              children: [
                const ShimmerBox(width: 36, height: 36, borderRadius: 10),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerLine(width: 55, height: 14),
                          SizedBox(width: 6),
                          ShimmerCircle(size: 14),
                        ],
                      ),
                      SizedBox(height: 6),
                      ShimmerLine(width: 80, height: 11),
                    ],
                  ),
                ),
                const ShimmerBox(width: 82, height: 22, borderRadius: 100),
              ],
            ),
            const SizedBox(height: 14),

            // Post Title Line (Bold pill)
            const ShimmerLine(width: 220, height: 16),
            const SizedBox(height: 8),

            // Post Snippet Lines
            const ShimmerLine(width: double.infinity, height: 13),
            const SizedBox(height: 6),
            const ShimmerLine(width: 180, height: 13),
            const SizedBox(height: 14),

            // 1. Featured Big Image (aspect ratio 16:9, borderRadius: 12)
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: ShimmerBox(
                height: double.infinity,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 8),

            // 2. Row of 5 small thumbnails underneath (height: 52, borderRadius: 8)
            Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                    child: const ShimmerBox(height: 52, borderRadius: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile Screen Skeleton
class ProfileShimmerView extends StatelessWidget {
  const ProfileShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header Card Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShimmerColors.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  ShimmerCircle(size: 54),
                  SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 120, height: 16),
                      SizedBox(height: 6),
                      ShimmerLine(width: 80, height: 12),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Top Buttons Skeleton
            const Row(
              children: [
                Expanded(child: ShimmerBox(height: 46, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(height: 46, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 14),

            // Stats Cards Skeleton
            Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(child: ShimmerBox(height: 68, borderRadius: 14, color: ShimmerColors.card)),
                      SizedBox(width: 10),
                      Expanded(child: ShimmerBox(height: 68, borderRadius: 14, color: ShimmerColors.card)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Services Grid Skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShimmerColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.8,
                ),
                itemCount: 8,
                itemBuilder: (_, _) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerCircle(size: 38),
                    SizedBox(height: 6),
                    ShimmerLine(width: 44, height: 9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Team Screen Skeleton
class TeamsShimmerView extends StatelessWidget {
  const TeamsShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            const ShimmerBox(height: 140, borderRadius: 16),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: ShimmerBox(height: 80, borderRadius: 14)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(height: 80, borderRadius: 14)),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(
                3,
                (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: ShimmerBox(height: 90, borderRadius: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wallet / Funding Details Skeleton
class FundingShimmerView extends StatelessWidget {
  const FundingShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ShimmerBox(width: 72, height: 34, borderRadius: 10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, _) => Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    ShimmerCircle(size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLine(width: 130, height: 14),
                          SizedBox(height: 6),
                          ShimmerLine(width: 90, height: 11),
                        ],
                      ),
                    ),
                    ShimmerLine(width: 60, height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Withdraw Screen Skeleton
class WithdrawShimmerView extends StatelessWidget {
  const WithdrawShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card Skeleton
            const ShimmerBox(height: 140, borderRadius: 20),
            const SizedBox(height: 18),
            // Receiving Accounts Header Skeleton
            const ShimmerLine(width: 180, height: 16),
            const SizedBox(height: 10),
            // Bank/Wallet Cards Horizontal List
            Row(
              children: [
                Expanded(child: const ShimmerBox(height: 110, borderRadius: 16)),
                const SizedBox(width: 12),
                Expanded(child: const ShimmerBox(height: 110, borderRadius: 16)),
              ],
            ),
            const SizedBox(height: 18),
            // Input Amount Card Skeleton
            const ShimmerBox(height: 130, borderRadius: 18),
            const SizedBox(height: 18),
            // Rules/Summary Card Skeleton
            const ShimmerBox(height: 100, borderRadius: 16),
            const SizedBox(height: 20),
            // Submit Button Skeleton
            const ShimmerBox(height: 52, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}

/// Recharge / Deposit Screen Skeleton
class RechargeShimmerView extends StatelessWidget {
  const RechargeShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet Card Skeleton
            const ShimmerBox(height: 120, borderRadius: 18),
            const SizedBox(height: 16),
            const ShimmerLine(width: 200, height: 15),
            const SizedBox(height: 10),
            // Payment Methods Grid Skeleton
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemCount: 4,
              itemBuilder: (_, _) => const ShimmerBox(height: 56, borderRadius: 12),
            ),
            const SizedBox(height: 16),
            // Method Details Card Skeleton
            const ShimmerBox(height: 130, borderRadius: 16),
            const SizedBox(height: 16),
            // Amount Input Card Skeleton
            const ShimmerBox(height: 150, borderRadius: 16),
            const SizedBox(height: 20),
            // Confirm Button Skeleton
            const ShimmerBox(height: 52, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}

/// Bank / Receiving Account List Skeleton
class BankAccountShimmerView extends StatelessWidget {
  const BankAccountShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerBox(height: 60, borderRadius: 16),
            const SizedBox(height: 16),
            const ShimmerBox(height: 120, borderRadius: 16),
            const SizedBox(height: 14),
            const ShimmerBox(height: 120, borderRadius: 16),
            const SizedBox(height: 14),
            const ShimmerBox(height: 120, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// My Purchased Products Skeleton - Matches exact purchased product card layout
class MyProductsShimmerView extends StatelessWidget {
  const MyProductsShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          // Top Summary Banner Skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: const [
                        ShimmerLine(width: 80, height: 12),
                        SizedBox(height: 8),
                        ShimmerLine(width: 60, height: 18),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: ShimmerColors.element),
                  Expanded(
                    child: Column(
                      children: const [
                        ShimmerLine(width: 80, height: 12),
                        SizedBox(height: 8),
                        ShimmerLine(width: 60, height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tab Toggle Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerBox(height: 40, borderRadius: 12),
          ),
          const SizedBox(height: 14),
          // Product Cards List Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, _) => ShimmerCard(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerBox(width: 80, height: 80, borderRadius: 12),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              ShimmerRow(),
                              const SizedBox(height: 6),
                              ShimmerRow(),
                              const SizedBox(height: 6),
                              ShimmerRow(),
                              const SizedBox(height: 6),
                              ShimmerRow(),
                              const SizedBox(height: 6),
                              ShimmerRow(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: ShimmerColors.element.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const ShimmerBox(height: 44, borderRadius: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily Commission / Income Skeleton
class CommissionShimmerView extends StatelessWidget {
  const CommissionShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          children: [
            const ShimmerBox(height: 120, borderRadius: 16),
            const SizedBox(height: 14),
            ...List.generate(
              5,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerBox(height: 80, borderRadius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic List/Card Screen Skeleton (for Salary, Rules, FAQ, etc.)
class GenericListShimmerView extends StatelessWidget {
  const GenericListShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerBox(height: 90, borderRadius: 16),
            const SizedBox(height: 14),
            ...List.generate(
              6,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerBox(height: 72, borderRadius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calculator Screen Skeleton
class CalculatorShimmerView extends StatelessWidget {
  const CalculatorShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ShimmerBox(height: 190, borderRadius: 16),
            const SizedBox(height: 16),
            const ShimmerBox(height: 120, borderRadius: 16),
            const SizedBox(height: 16),
            const ShimmerBox(height: 160, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

/// Check-in Screen Skeleton
class CheckInShimmerView extends StatelessWidget {
  const CheckInShimmerView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ShimmerBox(height: 100, borderRadius: 16),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: 6,
              itemBuilder: (_, _) => const ShimmerBox(height: 90, borderRadius: 14),
            ),
          ],
        ),
      ),
    );
  }
}

