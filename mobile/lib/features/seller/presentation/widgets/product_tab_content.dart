import 'package:flutter/material.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_remote_datasource.dart';
import '../pages/edit_product_page.dart';
import 'product_card.dart';

/// Content for each product status tab.
class ProductTabContent extends StatefulWidget {
  final bool isVi;
  final bool isDark;
  final String status;
  final VoidCallback? onProductChanged;

  /// Creates the ProductTabContent widget.
  const ProductTabContent({super.key, required this.isVi,
    required this.isDark, required this.status,
    this.onProductChanged});

  @override
  State<ProductTabContent> createState() => _State();
}

class _State extends State<ProductTabContent> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) return;
      final r = await ProductRemoteDatasource()
          .listProducts(token: token, status: widget.status);
      if (mounted) setState(() { _products = r; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEdit(Map<String, dynamic> product) async {
    final ok = await Navigator.push<bool>(context,
      MaterialPageRoute(
          builder: (_) => EditProductPage(product: product)));
    if (ok == true && mounted) {
      _fetch();
      widget.onProductChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_products.isEmpty) return _empty();
    return RefreshIndicator(onRefresh: _fetch,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _products.length,
        itemBuilder: (_, i) {
          final p = _products[i] as Map<String, dynamic>;
          return ProductCard(product: p, isDark: widget.isDark,
            isVi: widget.isVi, onTap: () => _openEdit(p));
        }));
  }

  Widget _empty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 120, height: 120,
        decoration: BoxDecoration(
          color: widget.isDark
              ? DarkColors.surface : Colors.grey.shade100,
          shape: BoxShape.circle),
        child: Icon(Icons.shopping_bag_outlined, size: 50,
          color: widget.isDark
              ? DarkColors.textSecondary.withOpacity(0.4)
              : Colors.grey.shade300)),
      const SizedBox(height: 20),
      Text(widget.isVi ? 'Không tìm thấy sản phẩm nào'
          : 'No products found',
        style: TextStyle(fontSize: 14, color: widget.isDark
            ? DarkColors.textSecondary : Colors.grey.shade500)),
    ])));
}
