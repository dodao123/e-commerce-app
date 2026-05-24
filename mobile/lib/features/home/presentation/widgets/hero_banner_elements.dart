import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

/// Dynamic cosmic fluid aurora for products in dark mode.
class GlowingAura extends StatefulWidget {
  final bool isDark;
  const GlowingAura({super.key, required this.isDark});

  @override
  State<GlowingAura> createState() => _GlowingAuraState();
}

class _GlowingAuraState extends State<GlowingAura> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isDark) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.95 + 0.15 * math.sin(_controller.value * 2 * math.pi);
        return Transform.scale(
          scale: scale,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: RotationTransition(
              turns: _controller,
              child: Container(
                width: 105, height: 105,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF00E5FF),
                      Color(0xFFD500F9),
                      Color(0xFFFF3D00),
                      Color(0xFF00E5FF),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Builds the static "New Product" / "Sản Phẩm Mới" label.
Widget buildNewLabel(bool isDark, String lang) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      lang == 'vi' ? 'Sản Phẩm Mới' : 'New Product',
      style: TextStyle(
          color: isDark ? Colors.white70 : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11),
    ),
  );
}

/// Builds the static "Buy Now!" / "Mua Ngay!" button.
Widget buildBuyButton(
    String lang, ProductModel product, ValueChanged<ProductModel> onTap) {
  return GestureDetector(
    onTap: () => onTap(product),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lang == 'vi' ? 'Mua Ngay!' : 'Buy Now!',
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    ),
  );
}
