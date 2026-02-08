import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Image carousel for the product detail page header.
class DetailImageCarousel extends StatelessWidget {
  /// List of image URLs to display.
  final List<String> images;

  /// Page controller for synchronization.
  final PageController pageController;

  /// Current page index.
  final int currentPage;

  /// Callback when page changes.
  final ValueChanged<int> onPageChanged;

  /// Whether dark mode is active.
  final bool isDark;

  /// Creates a DetailImageCarousel.
  const DetailImageCarousel({
    super.key,
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60, bottom: 40),
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Image.network(images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.headphones,
                        size: 150,
                        color: isDark ? Colors.white54 : Colors.black54)),
              );
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10, left: 0, right: 0,
            child: _buildIndicators(),
          ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
