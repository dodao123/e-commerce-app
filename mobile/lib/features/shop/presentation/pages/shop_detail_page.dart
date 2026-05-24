import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/product_model.dart';
import '../widgets/shop_detail_scaffold.dart';

/// Main public Shop Detail page for buyers with collapsible header.
class ShopDetailPage extends StatefulWidget {
  final String shopId;
  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _shop;
  List<ProductModel> _products = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final shopUrl = '${ApiConstants.baseUrl}/api/v1/shops/${widget.shopId}/public';
      final prodUrl = '${ApiConstants.baseUrl}/api/v1/shops/${widget.shopId}/products?limit=100';
      final shopRes = await http.get(Uri.parse(shopUrl));
      final prodRes = await http.get(Uri.parse(prodUrl));

      if (shopRes.statusCode == 200 && prodRes.statusCode == 200) {
        if (mounted) {
          setState(() {
            _shop = jsonDecode(shopRes.body);
            _products = (jsonDecode(prodRes.body) as List).map((j) => ProductModel.fromApiJson(j)).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeBg = isDark ? DarkColors.background : AppColors.background;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: themeBg,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    if (_error.isNotEmpty || _shop == null) {
      return Scaffold(body: Center(child: Text(_error)));
    }

    return ShopDetailScaffold(
      shop: _shop!,
      products: _products,
      isDark: isDark,
    );
  }
}
