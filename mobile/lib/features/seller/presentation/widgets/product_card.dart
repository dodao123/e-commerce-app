import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Card widget displaying a single product in the list.
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final bool isVi;
  final VoidCallback? onTap;

  /// Creates the ProductCard widget.
  const ProductCard({super.key, required this.product,
    required this.isDark, required this.isVi, this.onTap});

  @override
  Widget build(BuildContext context) {
    final images = product['images'] as List? ?? [];
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 4, offset: const Offset(0, 1))]),
      child: Row(children: [
        _thumb(images), const SizedBox(width: 10),
        Expanded(child: _details()),
        _badge(product['status'] ?? 'active'),
      ])));
  }

  Widget _thumb(List images) {
    if (images.isNotEmpty) {
      final p = images.first.toString();
      if (p.startsWith('uploads/')) {
        return ClipRRect(borderRadius: BorderRadius.circular(6),
          child: Image.network('${ApiConstants.baseUrl}/$p',
            width: 60, height: 60, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _phIcon()));
      }
      if (p.startsWith('/') || p.startsWith('C:')) {
        return ClipRRect(borderRadius: BorderRadius.circular(6),
          child: Image.file(File(p),
            width: 60, height: 60, fit: BoxFit.cover));
      }
    }
    return _phIcon();
  }

  Widget _phIcon() => Container(width: 60, height: 60,
    decoration: BoxDecoration(
      color: isDark ? DarkColors.background : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(6)),
    child: Icon(Icons.image_outlined, size: 28,
      color: Colors.grey.shade400));

  Widget _details() {
    final name = product['name'] ?? '';
    final price = product['price'] ?? 0;
    final stock = product['stock'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary : Colors.black87)),
        const SizedBox(height: 4),
        Text('₫${_fmtPrice(price)}', style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text('${isVi ? 'Kho' : 'Stock'}: $stock',
          style: TextStyle(fontSize: 11, color: isDark
              ? DarkColors.textSecondary : Colors.grey.shade600)),
      ]);
  }

  String _fmtPrice(dynamic p) {
    final d = (p is int) ? p.toDouble() : p as double;
    return d == d.truncateToDouble()
        ? d.toInt().toString() : d.toStringAsFixed(0);
  }

  Widget _badge(String status) {
    final c = {'active': Colors.green, 'pending': Colors.orange,
      'inactive': Colors.grey, 'violated': Colors.red,
    }[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(fontSize: 10,
        fontWeight: FontWeight.w600, color: c)));
  }
}
