import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/shop_products_datasource.dart';
import '../../data/models/product_model.dart';
import '../widgets/detail_info_section.dart';
import '../widgets/detail_shop_banner.dart';
import '../widgets/detail_shop_products.dart';
import 'product_detail_helpers.dart';

/// Product detail page with shop info and related products.
class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _pageCtrl = PageController();
  final _shopDs = ShopProductsDatasource();
  int _currentPage = 0;
  List<ProductModel> _shopProducts = [];

  @override
  void initState() {
    super.initState();
    _loadShopProducts();
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  Future<void> _loadShopProducts() async {
    if (widget.product.shopId.isEmpty) return;
    final items = await _shopDs.fetchShopProducts(
        shopId: widget.product.shopId,
        excludeId: widget.product.id, limit: 10);
    if (mounted) setState(() => _shopProducts = items);
  }

  void _openProduct(ProductModel p) {
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: p)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : AppColors.background,
      body: Column(children: [
        buildDetailImageHeader(
          context: context, product: widget.product,
          pageCtrl: _pageCtrl, currentPage: _currentPage,
          onPageChanged: (i) => setState(() => _currentPage = i),
          isDark: isDark),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailShopBanner(product: widget.product),
              DetailInfoSection(product: widget.product),
              const SizedBox(height: 20),
              DetailShopProducts(products: _shopProducts,
                  onProductTap: _openProduct),
              const SizedBox(height: 24),
            ]))),
      ]),
      bottomNavigationBar: buildDetailCartButton(
          context, lang, widget.product));
  }
}
