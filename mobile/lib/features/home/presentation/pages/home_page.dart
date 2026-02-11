import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/product_home_datasource.dart';
import '../../data/models/product_model.dart';
import '../widgets/hero_banner.dart';
import '../widgets/product_filter_tabs.dart';
import '../widgets/product_card.dart';
import '../widgets/special_section.dart';
import 'product_detail_page.dart';

/// Home page displaying real products from API.
class HomePage extends StatefulWidget {
  /// Creates the HomePage widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _datasource = ProductHomeDatasource();
  List<ProductModel> _products = [];
  bool _loading = true;
  final _tabs = ['All Product', 'Recommended', 'New Product', 'Popular'];
  final _tabsVi = ['Tất Cả', 'Đề Xuất', 'Sản Phẩm Mới', 'Phổ Biến'];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _datasource.fetchProducts();
      debugPrint('🏠 Home loaded ${products.length} products');
      if (!mounted) return;
      setState(() { _products = products; _loading = false; });
    } catch (e) {
      debugPrint('🏠 Home load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ProductModel> get _filteredProducts {
    if (_selectedTab == 0) return _products;
    final isNewTab = _selectedTab == 2;
    if (isNewTab) return _products.where((p) => p.isNew).toList();
    return _products;
  }

  void _navigateToDetail(ProductModel product) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_products.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48,
              color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No products found'),
          const SizedBox(height: 8),
          TextButton(onPressed: () {
            setState(() => _loading = true);
            _loadProducts();
          }, child: const Text('Retry')),
        ]));
    }
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
            products: _products.length > 4
                ? _products.sublist(4) : _products,
            onProductTap: _navigateToDetail,
          ),
          const SizedBox(height: 24),
        ],
      ),
    ));
  }

  Widget _buildSectionHeader() {
    return _SectionHeader(isVi:
        context.watch<AppProvider>().locale.languageCode == 'vi');
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

/// Section header with filter icon.
class _SectionHeader extends StatelessWidget {
  final bool isVi;
  const _SectionHeader({required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isVi ? 'Sản Phẩm' : 'Our Products',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
                Icons.tune, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
