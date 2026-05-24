import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/models/product_model.dart';

/// Header section showing product image, price, and stock.
class OptionSheetHeader extends StatelessWidget {
  /// The product being displayed.
  final ProductModel product;

  /// Whether dark mode is active.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the header widget.
  const OptionSheetHeader({
    super.key,
    required this.product,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        _productImage(),
        const SizedBox(width: 12),
        Expanded(child: _productInfo()),
        _closeButton(context),
      ]),
    );
  }

  Widget _productImage() => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 80, height: 80,
          child: product.isNetworkImage
              ? Image.network(product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
      );

  Widget _placeholder() => Container(
        color: IndieFolkTheme.secondary(isDark).withOpacity(0.2),
        child: Icon(Icons.image,
            color: IndieFolkTheme.secondary(isDark)),
      );

  Widget _productInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_formatPrice(product.price)}đ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: IndieFolkTheme.tertiary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${isVi ? "Kho" : "Stock"}: ${product.stock}',
            style: TextStyle(
              fontSize: 13,
              color: IndieFolkTheme.secondary(isDark),
            ),
          ),
        ],
      );

  Widget _closeButton(BuildContext ctx) => GestureDetector(
        onTap: () => Navigator.pop(ctx),
        child: Icon(Icons.close,
            size: 22,
            color: IndieFolkTheme.secondary(isDark)),
      );

  String _formatPrice(double price) {
    final parts = price.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && (parts.length - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }
}
