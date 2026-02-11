import 'dart:math';
import 'package:flutter/material.dart';

/// Widget that shows fly-to-cart animation overlay.
/// Place this at the top of the widget tree (inside MaterialApp).
class FlyToCartOverlay extends StatefulWidget {
  /// Child widget tree.
  final Widget child;

  /// Creates the FlyToCartOverlay.
  const FlyToCartOverlay({super.key, required this.child});

  /// Triggers the fly animation from anywhere in the tree.
  static void fly(BuildContext context, {
    required Offset start,
    required Offset end,
    required String imageAsset,
    bool isNetwork = false,
  }) {
    context.findAncestorStateOfType<FlyToCartOverlayState>()
        ?._startAnimation(start, end, imageAsset, isNetwork);
  }

  @override
  State<FlyToCartOverlay> createState() => FlyToCartOverlayState();
}

/// State managing the fly-to-cart animation with Bezier curve.
class FlyToCartOverlayState extends State<FlyToCartOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  bool _isAnimating = false;
  Offset _start = Offset.zero;
  Offset _end = Offset.zero;
  Offset _control = Offset.zero;
  String _imageAsset = '';
  bool _isNetwork = false;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _isAnimating = false);
        _controller.reset();
      }
    });
  }

  void _startAnimation(
      Offset start, Offset end, String asset, bool isNet) {
    _start = start;
    _end = end;
    _imageAsset = asset;
    _isNetwork = isNet;
    _control = _randomControlPoint(start, end);
    setState(() => _isAnimating = true);
    _controller.forward(from: 0);
  }

  /// Generates a random Bezier control point for curved path.
  Offset _randomControlPoint(Offset p0, Offset p1) {
    final midX = (p0.dx + p1.dx) / 2;
    final midY = (p0.dy + p1.dy) / 2;
    // Random horizontal offset: -120 to +120
    final offsetX = (_random.nextDouble() - 0.5) * 240;
    // Vertical offset: always arc upward by 80~200px
    final offsetY = -80.0 - _random.nextDouble() * 120;
    return Offset(midX + offsetX, midY + offsetY);
  }

  /// Quadratic Bezier: B(t) = (1-t)²·P0 + 2(1-t)t·C + t²·P1
  Offset _bezier(double t) {
    final u = 1 - t;
    return Offset(
      u * u * _start.dx + 2 * u * t * _control.dx + t * t * _end.dx,
      u * u * _start.dy + 2 * u * t * _control.dy + t * t * _end.dy,
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      if (_isAnimating) AnimatedBuilder(
        animation: _curve,
        builder: (_, __) => _buildFlyingItem()),
    ]);
  }

  Widget _buildFlyingItem() {
    final t = _curve.value;
    final pos = _bezier(t);
    final size = Tween(begin: 50.0, end: 25.0).transform(t);
    final opacity = Tween(begin: 1.0, end: 0.6).transform(t);

    return Positioned(left: pos.dx, top: pos.dy,
      child: Opacity(opacity: opacity,
        child: SizedBox(width: size, height: size,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _isNetwork
                ? Image.network(_imageAsset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_cart, size: 14,
                        color: Colors.orange))
                : Image.asset(_imageAsset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.shopping_cart, size: 14,
                        color: Colors.orange))))));
  }
}
