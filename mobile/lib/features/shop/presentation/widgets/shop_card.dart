import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/shop_detail_page.dart';

/// Card widget to display key shop profile details in a grid.
class ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final bool isDark, isVi;

  const ShopCard({super.key, required this.shop, required this.isDark, required this.isVi});

  int _getBgIndex(String uuid) {
    if (uuid.isEmpty) return 1;
    int sum = 0;
    for (int i = 0; i < uuid.length; i++) {
      sum += uuid.codeUnitAt(i);
    }
    return (sum % 21) + 1;
  }

  double _getRating(String uuid) {
    if (uuid.isEmpty) return 4.5;
    int sum = 0;
    for (int i = 0; i < uuid.length; i++) {
      sum += uuid.codeUnitAt(i);
    }
    return 3.8 + (sum % 13) * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ApiConstants.resolveImageUrl(shop['shop_avatar'] ?? '');
    final borderCol = isDark ? DarkColors.surface : Colors.white;
    final bgIndex = _getBgIndex(shop['id'] ?? '');
    final rating = _getRating(shop['id'] ?? '');

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ShopDetailPage(shopId: shop['id']),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 70,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
                      child: Image.network(
                        '${ApiConstants.baseUrl}/uploads/backgrounds/bg_$bgIndex.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: isDark
                                ? [Colors.blueGrey.shade800, Colors.grey.shade900]
                                : [Colors.blueGrey.shade100, Colors.blueGrey.shade50]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: borderCol, width: 2.5),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty ? const Icon(Icons.store, size: 18, color: AppColors.primary) : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['shop_name'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${shop['category'] ?? ''} • ${shop['province'] ?? ''}',
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${shop['detail_address'] ?? ''}, ${shop['ward'] ?? ''}, ${shop['district'] ?? ''}',
                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
