import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../widgets/detail_image_carousel.dart';

/// Builds the image header for the product detail page.
Widget buildDetailImageHeader({
  required BuildContext context,
  required ProductModel product,
  required PageController pageCtrl,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
  required bool isDark,
}) {
  final images = product.imageDetail.isNotEmpty
      ? product.imageDetail : [product.imageUrl];
  return Container(
    height: MediaQuery.of(context).size.height * 0.4,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: isDark
          ? DarkColors.darkCardGradient
          : AppColors.darkCardGradient,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30))),
    child: SafeArea(child: Stack(children: [
      _navButton(Icons.arrow_back, Alignment.topLeft, isDark,
          () => Navigator.pop(context)),
      _navButton(Icons.bookmark_border, Alignment.topRight,
          isDark, () {}),
      DetailImageCarousel(
        images: images, pageController: pageCtrl,
        currentPage: currentPage,
        onPageChanged: onPageChanged, isDark: isDark),
    ])));
}

Widget _navButton(
    IconData icon, Alignment align, bool isDark, VoidCallback onTap) {
  final isLeft = align == Alignment.topLeft;
  return Positioned(
    top: 8, left: isLeft ? 16 : null, right: isLeft ? null : 16,
    child: IconButton(
      onPressed: onTap,
      icon: Icon(icon,
          color: isDark ? Colors.white : Colors.black87)));
}

/// Builds the "Add to cart" bottom button.
Widget buildDetailCartButton(String lang) {
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
        elevation: 0),
      child: Text(lang == 'vi' ? 'Thêm vào giỏ' : 'Add to cart',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600))));
}
