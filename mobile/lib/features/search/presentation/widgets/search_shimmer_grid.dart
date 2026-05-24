import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated pulsing block for skeleton loaders.
class ShimmerBlock extends StatefulWidget {
  /// Width of the pulsing block.
  final double width;

  /// Height of the pulsing block.
  final double height;

  /// Rounded corner radius of the block.
  final double borderRadius;

  /// Creates a ShimmerBlock.
  const ShimmerBlock({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value * 0.5 + 0.3,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}

/// Renders a skeleton grid layout mimicking the ProductCard list.
class SearchShimmerGrid extends StatelessWidget {
  /// Creates the SearchShimmerGrid.
  const SearchShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? DarkColors.surface.withValues(alpha: 0.5)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Center(child: ShimmerBlock(borderRadius: 12))),
              SizedBox(height: 12),
              ShimmerBlock(height: 12, width: 80),
              SizedBox(height: 6),
              ShimmerBlock(height: 14, width: 120),
              SizedBox(height: 6),
              ShimmerBlock(height: 16, width: 60),
            ],
          ),
        ),
      ),
    );
  }
}
