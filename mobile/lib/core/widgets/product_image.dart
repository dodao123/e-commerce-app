import 'package:flutter/material.dart';
import '../../features/home/data/models/product_model.dart';

/// Displays a product image from either asset or network source.
/// Automatically detects the source type via [product.isNetworkImage].
class ProductImage extends StatelessWidget {
  /// The product whose image to display.
  final ProductModel product;

  /// How to fit the image in the box.
  final BoxFit fit;

  /// Fallback widget shown on error or empty URL.
  final Widget? errorWidget;

  /// Creates a ProductImage widget.
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.contain,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = errorWidget ??
        const Icon(Icons.image_not_supported, size: 50);

    if (product.imageUrl.isEmpty) return fallback;

    if (product.isNetworkImage) {
      return Image.network(
        product.imageUrl,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
      );
    }

    return Image.asset(
      product.imageUrl,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}
