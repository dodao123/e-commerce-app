import 'package:flutter/material.dart';

/// Renders the textual detail block of a ShopCard (name, category, rating, address).
class ShopCardDetails extends StatelessWidget {
  final Map<String, dynamic> shop;
  final double rating;
  final bool isDark;

  const ShopCardDetails({
    super.key,
    required this.shop,
    required this.rating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop['shop_name'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${shop['category'] ?? ''} • ${shop['province'] ?? ''}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${shop['detail_address'] ?? ''}, ${shop['ward'] ?? ''}, ${shop['district'] ?? ''}',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.grey[500],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
