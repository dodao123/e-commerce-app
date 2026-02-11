import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Card widget displaying a single product in the list.
class ProductCard extends StatelessWidget {
  /// Product data from API response.
  final Map<String, dynamic> product;

  /// Whether to use dark theme.
  final bool isDark;

  /// Whether to show Vietnamese text.
  final bool isVi;

  /// Creates the ProductCard widget.
  const ProductCard({
    super.key,
    required this.product,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? '';
    final price = product['price'] ?? 0;
    final stock = product['stock'] ?? 0;
    final status = product['status'] ?? 'active';
    final images = product['images'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4, offset: const Offset(0, 1))]),
      child: Row(children: [
        _thumbnail(images),
        const SizedBox(width: 10),
        Expanded(child: _details(name, price, stock)),
        _statusBadge(status),
      ]));
  }

  Widget _thumbnail(List images) {
    if (images.isNotEmpty) {
      final path = images.first.toString();
      // Server-relative path (e.g. uploads/shops/...)
      if (path.startsWith('uploads/')) {
        final url = '${ApiConstants.baseUrl}/$path';
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(url,
            width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _placeholderIcon()));
      }
      // Local file path
      if (path.startsWith('/') || path.startsWith('C:')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(File(path),
            width: 60, height: 60, fit: BoxFit.cover));
      }
    }
    return _placeholderIcon();
  }

  Widget _placeholderIcon() {
    return Container(width: 60, height: 60,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6)),
      child: Icon(Icons.image_outlined, size: 28,
        color: Colors.grey.shade400));
  }

  Widget _details(String name, dynamic price, int stock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87)),
        const SizedBox(height: 4),
        Text('₫${_formatPrice(price)}',
          style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary)),
        const SizedBox(height: 2),
        Text('${isVi ? 'Kho' : 'Stock'}: $stock',
          style: TextStyle(fontSize: 11,
            color: isDark ? DarkColors.textSecondary
                : Colors.grey.shade600)),
      ]);
  }

  String _formatPrice(dynamic price) {
    final p = (price is int) ? price.toDouble() : price as double;
    if (p == p.truncateToDouble()) return p.toInt().toString();
    return p.toStringAsFixed(0);
  }

  Widget _statusBadge(String status) {
    final colors = {
      'active': Colors.green, 'pending': Colors.orange,
      'inactive': Colors.grey, 'violated': Colors.red,
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600,
        color: color)));
  }
}
