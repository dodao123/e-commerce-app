import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

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
