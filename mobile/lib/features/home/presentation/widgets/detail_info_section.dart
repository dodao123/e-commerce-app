import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/product_model.dart';

/// Info section displayed below the image on the product detail page.
class DetailInfoSection extends StatelessWidget {
  /// The product to display info for.
  final ProductModel product;

  /// Creates DetailInfoSection for the given product.
  const DetailInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppProvider>().locale.languageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.isNew)
            Text(lang == 'vi' ? 'Sản Phẩm Mới' : 'New Product',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 6),
          _buildNamePriceRow(lang),
          const SizedBox(height: 10),
          _buildRatingRow(),
          const SizedBox(height: 20),
          Text(lang == 'vi' ? 'Mô tả' : 'Descriptions',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildDescription(lang),
        ],
      ),
    );
  }

  Widget _buildNamePriceRow(String lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(product.localizedName(lang),
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Text(PriceFormatter.format(product.price),
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
          i < product.rating.floor() ? Icons.star : Icons.star_border,
          color: AppColors.starYellow, size: 18,
        )),
        const SizedBox(width: 6),
        Text('${product.rating}',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 4),
        Text('(${product.reviewCount} review)',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }

  Widget _buildDescription(String lang) {
    final desc = product.localizedDescription(lang);
    return Text(
      desc.isNotEmpty ? desc : 'No description available.',
      style: TextStyle(
          color: AppColors.textSecondary, fontSize: 14, height: 1.6),
    );
  }
}
