import 'package:flutter/material.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_remote_datasource.dart';
import 'product_card.dart';

/// Content for each product status tab.
/// Fetches products from API filtered by status.
class ProductTabContent extends StatefulWidget {
  /// Whether to show Vietnamese text.
  final bool isVi;

  /// Whether the theme is dark.
  final bool isDark;

  /// Status filter for this tab (e.g., 'active', 'pending').
  /// Pass empty string for "all" / "in stock".
  final String status;

  /// Creates the ProductTabContent widget.
  const ProductTabContent({
    super.key,
    required this.isVi,
    required this.isDark,
    required this.status,
  });

  @override
  State<ProductTabContent> createState() =>
      _ProductTabContentState();
}

class _ProductTabContentState extends State<ProductTabContent> {
  List<dynamic> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  /// Loads products from the backend API.
  Future<void> _fetchProducts() async {
    try {
      final token = await TokenManager().getToken();
      if (token == null) return;
      final result = await ProductRemoteDatasource()
          .listProducts(
              token: token, status: widget.status);
      if (mounted) {
        setState(() {
          _products = result;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_products.isEmpty) return _emptyState();

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _products.length,
        itemBuilder: (_, index) => ProductCard(
          product: _products[index] as Map<String, dynamic>,
          isDark: widget.isDark,
          isVi: widget.isVi)));
  }

  Widget _emptyState() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _emptyIllustration(),
          const SizedBox(height: 20),
          Text(widget.isVi
              ? 'Không tìm thấy sản phẩm nào'
              : 'No products found',
            style: TextStyle(fontSize: 14,
              color: widget.isDark
                  ? DarkColors.textSecondary
                  : Colors.grey.shade500)),
        ])));
  }

  Widget _emptyIllustration() {
    return Container(
      width: 120, height: 120,
      decoration: BoxDecoration(
        color: widget.isDark
            ? DarkColors.surface
            : Colors.grey.shade100,
        shape: BoxShape.circle),
      child: Icon(Icons.shopping_bag_outlined, size: 50,
        color: widget.isDark
            ? DarkColors.textSecondary.withOpacity(0.4)
            : Colors.grey.shade300));
  }
}
