import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/presentation/pages/product_detail_page.dart';
import '../../../home/presentation/widgets/product_card.dart';

/// Tab content displaying a local search bar and a grid of products belonging to the shop.
class ShopDetailProducts extends StatefulWidget {
  final List<ProductModel> products;
  final bool isDark;
  final bool isVi;

  const ShopDetailProducts({
    super.key,
    required this.products,
    required this.isDark,
    required this.isVi,
  });

  @override
  State<ShopDetailProducts> createState() => _ShopDetailProductsState();
}

class _ShopDetailProductsState extends State<ShopDetailProducts> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final filtered = widget.products.where((p) {
      final name = p.localizedName(lang).toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (val) => setState(() => _query = val),
            style: TextStyle(color: widget.isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: widget.isVi ? 'Tìm kiếm trong cửa hàng này...' : 'Search in this shop...',
              hintStyle: TextStyle(color: widget.isDark ? Colors.white54 : Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: widget.isDark ? Colors.white60 : Colors.grey[600]),
              filled: true,
              fillColor: widget.isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    widget.isVi ? 'Không tìm thấy sản phẩm nào' : 'No products found',
                    style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.all(2), // 2px separation as requested
                      child: ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
