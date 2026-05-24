import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/datasources/product_home_datasource.dart';
import '../../data/models/product_model.dart';
import 'hero_banner_carousel_view.dart';

/// Animated banner carousel displaying electronic products with smooth cross-fade animation.
class HeroBannerCarousel extends StatefulWidget {
  /// Callback when a product is tapped.
  final ValueChanged<ProductModel> onProductTap;

  /// Creates a HeroBannerCarousel.
  const HeroBannerCarousel({super.key, required this.onProductTap});

  @override
  State<HeroBannerCarousel> createState() => _HeroBannerCarouselState();
}

class _HeroBannerCarouselState extends State<HeroBannerCarousel> {
  final _datasource = ProductHomeDatasource();
  List<ProductModel> _electronics = [];
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadElectronics();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadElectronics() async {
    try {
      final items = await _datasource.fetchProducts(
        limit: 100,
        category: 'electronics',
      );
      if (items.isNotEmpty && mounted) {
        items.shuffle();
        setState(() => _electronics = items);
        _timer = Timer.periodic(const Duration(seconds: 4), (t) {
          if (mounted) {
            setState(() => _currentIndex = (_currentIndex + 1) % _electronics.length);
          }
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_electronics.isEmpty) return const SizedBox.shrink();
    return HeroBannerCarouselView(
      product: _electronics[_currentIndex],
      onProductTap: widget.onProductTap,
    );
  }
}

