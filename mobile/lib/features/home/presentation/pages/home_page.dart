import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/product_home_datasource.dart';
import '../../data/models/product_model.dart';
import 'home_page_content.dart';
import 'product_detail_page.dart';

/// Home page with infinite scroll product feed.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _datasource = ProductHomeDatasource();
  final _scrollCtrl = ScrollController();
  final List<ProductModel> _products = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() { _scrollCtrl.dispose(); super.dispose(); }

  void _onScroll() {
    if (_loadingMore || !_hasMore) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    if (_scrollCtrl.offset >= max - 300) _loadMore();
  }

  Future<void> _loadProducts() async {
    try {
      final items = await _datasource.fetchProducts(
          limit: _pageSize, offset: 0);
      if (!mounted) return;
      setState(() {
        _products..clear()..addAll(items);
        _hasMore = items.length >= _pageSize;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Home load error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final items = await _datasource.fetchProducts(
          limit: _pageSize, offset: _products.length);
      if (!mounted) return;
      setState(() {
        _products.addAll(items);
        _hasMore = items.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _openDetail(ProductModel p) {
    Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: p)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
          color: AppColors.primary));
    }
    if (_products.isEmpty) return _emptyState();
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: buildHomeContent(
        context: context, scrollCtrl: _scrollCtrl,
        products: _products, hasMore: _hasMore,
        loadingMore: _loadingMore,
        onProductTap: _openDetail));
  }

  Widget _emptyState() => Center(child: Column(
    mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
      const SizedBox(height: 12), const Text('No products found'),
      const SizedBox(height: 8), TextButton(onPressed: () {
        setState(() => _loading = true); _loadProducts();
      }, child: const Text('Retry'))]));
}
