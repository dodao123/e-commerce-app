import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../widgets/detail_image_carousel.dart';
import '../widgets/detail_info_section.dart';

/// Product detail page with image carousel and product info.
class ProductDetailPage extends StatefulWidget {
  /// The product to display details for.
  final ProductModel product;

  /// Creates ProductDetailPage for the given product.
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = context.watch<AppProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.background,
      body: Column(
        children: [
          _buildImageHeader(context, isDark),
          Expanded(child: DetailInfoSection(product: widget.product)),
        ],
      ),
      bottomNavigationBar: _buildAddToCartButton(lang),
    );
  }

  Widget _buildImageHeader(BuildContext context, bool isDark) {
    final images = widget.product.imageDetail.isNotEmpty
        ? widget.product.imageDetail
        : [widget.product.imageUrl];

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? DarkColors.darkCardGradient
            : AppColors.darkCardGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            _buildNavButton(Icons.arrow_back, Alignment.topLeft, isDark,
                () => Navigator.pop(context)),
            _buildNavButton(Icons.bookmark_border, Alignment.topRight,
                isDark, () {}),
            DetailImageCarousel(
              images: images,
              pageController: _pageController,
              currentPage: _currentPage,
              onPageChanged: (i) => setState(() => _currentPage = i),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      IconData icon, Alignment align, bool isDark, VoidCallback onTap) {
    final isLeft = align == Alignment.topLeft;
    return Positioned(
      top: 8, left: isLeft ? 16 : null, right: isLeft ? null : 16,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildAddToCartButton(String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 30),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(lang == 'vi' ? 'Thêm vào giỏ' : 'Add to cart',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
