import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/models/product_model.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_filter_tabs.dart';
import '../widgets/product_card.dart';
import '../widgets/special_section.dart';
import 'product_detail_page.dart';

/// Home page displaying featured products, grid, and special section.
class HomePage extends StatefulWidget {
  /// Creates the HomePage widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _products = ProductLocalDatasource.getMockProducts();
  final _tabs = ['All Product', 'Recommended', 'New Product', 'Popular'];
  final _tabsVi = ['Tất Cả', 'Đề Xuất', 'Sản Phẩm Mới', 'Phổ Biến'];
  int _selectedTab = 0;

  List<ProductModel> get _filteredProducts {
    if (_selectedTab == 0) return _products;
    final category = _tabs[_selectedTab];
    return _products.where((p) => p.category == category).toList();
  }

  void _navigateToDetail(ProductModel product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          HeroBanner(
            product: _products.first,
            onBuyNow: () => _navigateToDetail(_products.first),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(),
          const SizedBox(height: 14),
          ProductFilterTabs(
            tabs: context.watch<AppProvider>().locale.languageCode == 'vi'
                ? _tabsVi : _tabs,
            selectedIndex: _selectedTab,
            onTabSelected: (i) => setState(() => _selectedTab = i),
          ),
          const SizedBox(height: 16),
          _buildProductGrid(),
          const SizedBox(height: 24),
          SpecialSection(
            products: _products.where((p) => p.price <= 300).toList(),
            onProductTap: _navigateToDetail,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              context.watch<AppProvider>().locale.languageCode == 'vi'
                  ? 'Sản Phẩm' : 'Our Products',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final items = _filteredProducts.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.82,
        crossAxisSpacing: 14, mainAxisSpacing: 14,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => ProductCard(
        product: items[i],
        onTap: () => _navigateToDetail(items[i]),
      ),
    );
  }
}
