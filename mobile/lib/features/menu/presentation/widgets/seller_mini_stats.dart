import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Small row showing stats for products, followers, and ratings of a seller shop.
class SellerMiniStats extends StatelessWidget {
  final bool isVi;

  const SellerMiniStats({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _stat('128', isVi ? 'Sản phẩm' : 'Products'),
        _divider(),
        _stat('1.2K', isVi ? 'Người theo dõi' : 'Followers'),
        _divider(),
        _stat('4.8', isVi ? '⭐ Đánh giá' : '⭐ Rating'),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: IndieFolkTheme.h1(true).copyWith(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: IndieFolkTheme.body(true).copyWith(fontSize: 10, color: Colors.white.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.15),
    );
  }
}
