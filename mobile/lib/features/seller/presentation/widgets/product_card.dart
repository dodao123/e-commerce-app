import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Card widget displaying a single product in the list.
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final bool isVi;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;

  /// Creates the ProductCard widget.
  const ProductCard({super.key, required this.product,
    required this.isDark, required this.isVi, this.onTap, this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final images = product['images'] as List? ?? [];
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6)),
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
      color: IndieFolkTheme.neutral(isDark),
      borderRadius: BorderRadius.circular(6)),
    child: Icon(Icons.image_outlined, size: 28,
      color: IndieFolkTheme.secondary(isDark)));

  Widget _details() {
    final name = product['name'] ?? '';
    final price = product['price'] ?? 0;
    final stock = product['stock'] ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('₫${_fmtPrice(price)}', style: IndieFolkTheme.body(isDark).copyWith(
          color: IndieFolkTheme.tertiary(isDark), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text('${isVi ? 'Kho' : 'Stock'}: $stock',
          style: IndieFolkTheme.label(isDark).copyWith(color: IndieFolkTheme.secondary(isDark))),
      ]);
  }

  String _fmtPrice(dynamic p) {
    final d = (p is int) ? p.toDouble() : p as double;
    return d == d.truncateToDouble()
        ? d.toInt().toString() : d.toStringAsFixed(0);
  }

  Widget _badge(String status) {
    return PopupMenuButton<String>(
      onSelected: onStatusChanged,
      color: IndieFolkTheme.surface(isDark),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'active',
          child: Text(isVi ? 'Đang bán' : 'Active', style: IndieFolkTheme.body(isDark)),
        ),
        PopupMenuItem(
          value: 'inactive',
          child: Text(isVi ? 'Ngừng bán' : 'Inactive', style: IndieFolkTheme.body(isDark)),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: IndieFolkTheme.neutral(isDark),
          border: Border.all(color: IndieFolkTheme.secondary(isDark).withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status.toUpperCase(), style: IndieFolkTheme.label(isDark)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 14, color: IndieFolkTheme.primary(isDark)),
          ],
        )),
    );
  }
}
