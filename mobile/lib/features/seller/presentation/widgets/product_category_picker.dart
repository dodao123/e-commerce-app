import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Category list and bottom sheet picker for product categories.
const List<Map<String, dynamic>> productCategories = [
  {'icon': Icons.phone_android, 'vi': 'Điện thoại', 'en': 'Phones'},
  {'icon': Icons.laptop_mac, 'vi': 'Máy tính & Laptop', 'en': 'Computers'},
  {'icon': Icons.electrical_services, 'vi': 'Điện tử', 'en': 'Electronics'},
  {'icon': Icons.checkroom, 'vi': 'Thời trang', 'en': 'Fashion'},
  {'icon': Icons.face_retouching_natural, 'vi': 'Làm đẹp', 'en': 'Beauty'},
  {'icon': Icons.kitchen, 'vi': 'Gia dụng', 'en': 'Home Appliances'},
  {'icon': Icons.sports_soccer, 'vi': 'Giày dép', 'en': 'Footwear'},
  {'icon': Icons.ac_unit, 'vi': 'Điện lạnh', 'en': 'Cooling'},
  {'icon': Icons.child_care, 'vi': 'Mẹ và bé', 'en': 'Mom & Baby'},
  {'icon': Icons.restaurant, 'vi': 'Thực phẩm', 'en': 'Food'},
  {'icon': Icons.sports_esports, 'vi': 'Gaming', 'en': 'Gaming'},
  {'icon': Icons.more_horiz, 'vi': 'Khác', 'en': 'Other'},
];

/// Shows a bottom sheet to pick a product category.
Future<String?> showCategoryPicker(
    BuildContext context, bool isVi, bool isDark) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: IndieFolkTheme.surface(isDark),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
    builder: (_) => _CategorySheet(isVi: isVi, isDark: isDark));
}

class _CategorySheet extends StatelessWidget {
  final bool isVi;
  final bool isDark;

  const _CategorySheet({required this.isVi, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
          decoration: BoxDecoration(color: IndieFolkTheme.secondary(isDark).withOpacity(0.3),
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(isVi ? 'Chọn ngành hàng' : 'Select Category',
          style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 12),
        ...productCategories.map((cat) => ListTile(
          leading: Icon(cat['icon'] as IconData,
            color: IndieFolkTheme.tertiary(isDark)),
          title: Text(isVi ? cat['vi'] : cat['en'], style: IndieFolkTheme.body(isDark)),
          onTap: () => Navigator.pop(context,
              isVi ? cat['vi'] : cat['en']),
        )),
      ])));
  }
}
