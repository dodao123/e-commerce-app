import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Dynamic cosmic fluid aurora for products in dark mode.
class GlowingAura extends StatefulWidget {
  /// Whether the dark theme is active.
  final bool isDark;

  /// Creates a GlowingAura.
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
                width: 140,
                height: 140,
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
