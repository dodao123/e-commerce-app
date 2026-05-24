import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/role_guard.dart';
import '../../data/datasources/product_home_datasource.dart';
import '../../data/models/product_model.dart';
import '../widgets/home_empty_state.dart';
import 'home_page_content.dart';
import 'product_detail_page.dart';

/// Home page with infinite scroll product feed and category filtering.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _datasource = ProductHomeDatasource();
  final _scrollCtrl = ScrollController();
  final List<ProductModel> _products = [];
  bool _loading = true, _loadingMore = false, _hasMore = true;
  String _selectedCategory = '';
  static const _pageSize = 8;

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
    if (_scrollCtrl.offset >= _scrollCtrl.position.maxScrollExtent - 300) _loadMore();
  }

  Future<void> _loadProducts() async {
    try {
      final items = await _datasource.fetchProducts(limit: _pageSize, offset: 0, category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _products..clear()..addAll(items);
        _products.shuffle();
        _hasMore = items.length >= _pageSize;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final items = await _datasource.fetchProducts(limit: _pageSize, offset: _products.length, category: _selectedCategory);
      if (!mounted) return;
      setState(() {
        _products.addAll(items);
        _products.shuffle();
        _hasMore = items.length >= _pageSize;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _loading = true;
      _products.clear();
      _hasMore = true;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_products.isEmpty) return HomeEmptyState(onRetry: () => _changeCategory(''));

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: buildHomeContent(
        context: context,
        scrollCtrl: _scrollCtrl,
        products: _products,
        hasMore: _hasMore,
        loadingMore: _loadingMore,
        selectedCategory: _selectedCategory,
        onCategorySelected: _changeCategory,
        onProductTap: (p) {
          if (RoleGuard.checkBuyerRole(context)) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)));
          }
        },
      ),
    );
  }
}
