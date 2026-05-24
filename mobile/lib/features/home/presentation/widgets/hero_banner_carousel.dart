import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/datasources/product_home_datasource.dart';
import '../../data/models/product_model.dart';
import 'hero_banner_elements.dart';

/// Animated banner carousel displaying electronic products with smooth cross-fade animation.
class HeroBannerCarousel extends StatefulWidget {
  final ValueChanged<ProductModel> onProductTap;

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
          limit: 100, category: 'electronics');
      if (items.isNotEmpty && mounted) {
        items.shuffle();
        for (final item in items) {
          if (item.imageUrl.isNotEmpty && mounted) {
            final provider = item.isNetworkImage
                ? NetworkImage(item.imageUrl)
                : AssetImage(item.imageUrl) as ImageProvider;
            precacheImage(provider, context).catchError((_) {});
          }
        }
        setState(() => _electronics = items);
        _startTimer();
      }
    } catch (_) {}
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_electronics.isEmpty || !mounted) return;
      setState(() => _currentIndex = (_currentIndex + 1) % _electronics.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_electronics.isEmpty) return const SizedBox(height: 0);

    final product = _electronics[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 35),
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 185, right: 15),
            decoration: BoxDecoration(
              gradient: isDark
                  ? DarkColors.darkCardGradient
                  : AppColors.darkCardGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildNewLabel(isDark, lang),
                const SizedBox(height: 4),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      product.localizedName(lang),
                      key: ValueKey<String>(product.id),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                buildBuyButton(lang, product, widget.onProductTap),
              ],
            ),
          ),
          Positioned(
            left: -30, top: -45, bottom: 0, width: 220,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: SizedBox(
                key: ValueKey<String>(product.imageUrl),
                width: 220, height: 220,
                child: ProductImage(
                  product: product,
                  errorWidget: Icon(Icons.headphones,
                      size: 100,
                      color: isDark ? Colors.white54 : Colors.black54),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
