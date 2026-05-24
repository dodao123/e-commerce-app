import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/shop_card.dart';

/// Public Shop List Page loaded inside the main navigation shell displaying shops grid.
class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  bool _isLoading = true;
  List<dynamic> _shops = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/shops/public'),
      ).timeout(const Duration(seconds: ApiConstants.timeoutSeconds));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _shops = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load shops');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = Localizations.localeOf(context).languageCode == 'vi';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)));
    }
    if (_shops.isEmpty) {
      return Center(
        child: Text(
          isVi ? 'Không tìm thấy cửa hàng nào' : 'No shops found',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _shops.length,
      itemBuilder: (context, index) {
        return ShopCard(
          shop: _shops[index],
          isDark: isDark,
          isVi: isVi,
        );
      },
    );
  }
}
