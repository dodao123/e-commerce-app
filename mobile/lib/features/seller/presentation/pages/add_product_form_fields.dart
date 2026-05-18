import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Text input fields for the add product form.
/// Includes: product name, description, category, price,
/// stock, and shipping fee.
class AddProductFormFields extends StatelessWidget {
  /// Controllers for all text fields.
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController shippingCtrl;

  /// Currently selected category name.
  final String category;

  /// Called when user taps category to pick.
  final VoidCallback onPickCategory;

  /// Whether the theme is dark.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the AddProductFormFields widget.
  const AddProductFormFields({
    super.key, required this.nameCtrl, required this.descCtrl,
    required this.priceCtrl, required this.stockCtrl,
    required this.shippingCtrl, required this.category,
    required this.onPickCategory,
    required this.isDark, required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _field(isVi ? 'Tên sản phẩm' : 'Product name', nameCtrl,
        hint: isVi ? 'Nhập tên sản phẩm' : 'Enter product name',
        maxLen: 120, required: true),
      const SizedBox(height: 8),
      _field(isVi ? 'Mô tả sản phẩm' : 'Description', descCtrl,
        hint: isVi ? 'Nhập mô tả sản phẩm' : 'Enter description',
        maxLen: 3000, maxLines: 4, required: true),
      const SizedBox(height: 8),
      _categoryRow(),
      const SizedBox(height: 8),
      _numberRow(Icons.sell_outlined,
          isVi ? 'Giá' : 'Price', priceCtrl,
          suffix: isVi ? 'Đặt' : 'Set', required: true),
      const SizedBox(height: 8),
      _numberRow(Icons.inventory_outlined,
          isVi ? 'Tồn kho' : 'Stock', stockCtrl,
          required: true),
      const SizedBox(height: 8),
      _numberRow(Icons.local_shipping_outlined,
          isVi ? 'Phí vận chuyển' : 'Shipping fee', shippingCtrl,
          suffix: isVi ? 'Tùy chỉnh' : 'Custom'),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl,
      {String? hint, int? maxLen, int maxLines = 1,
      bool required = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: IndieFolkTheme.surface(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
            if (required) const Text(' *',
                style: TextStyle(color: Colors.red)),
            const Spacer(),
            if (maxLen != null)
              Text('${ctrl.text.length}/$maxLen',
                style: IndieFolkTheme.label(isDark).copyWith(color: IndieFolkTheme.secondary(isDark))),
          ]),
          const SizedBox(height: 8),
          TextField(controller: ctrl, maxLines: maxLines,
            maxLength: maxLen,
            style: IndieFolkTheme.body(isDark),
            decoration: InputDecoration(hintText: hint,
              counterText: '', border: InputBorder.none,
              hintStyle: IndieFolkTheme.body(isDark).copyWith(color: IndieFolkTheme.secondary(isDark).withOpacity(0.5)))),
        ]));
  }

  Widget _categoryRow() {
    return GestureDetector(
      onTap: onPickCategory,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: IndieFolkTheme.surface(isDark),
        child: Row(children: [
          Text(isVi ? 'Ngành hàng' : 'Category',
            style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
          const Text(' *', style: TextStyle(color: Colors.red)),
          const Spacer(),
          Text(category.isEmpty
              ? (isVi ? 'Chọn' : 'Select') : category,
            style: IndieFolkTheme.body(isDark).copyWith(
              color: category.isEmpty ? IndieFolkTheme.secondary(isDark) : IndieFolkTheme.primary(isDark))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 20,
            color: IndieFolkTheme.secondary(isDark)),
        ])));
  }

  Widget _numberRow(IconData icon, String label,
      TextEditingController ctrl,
      {String? suffix, bool required = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: IndieFolkTheme.surface(isDark),
      child: Row(children: [
        Icon(icon, size: 20, color: IndieFolkTheme.secondary(isDark)),
        const SizedBox(width: 10),
        Text(label, style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
        if (required)
          const Text(' *', style: TextStyle(color: Colors.red)),
        const Spacer(),
        SizedBox(width: 80,
          child: TextField(controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            style: IndieFolkTheme.body(isDark),
            decoration: InputDecoration(
              hintText: suffix ?? '0',
              border: InputBorder.none,
              hintStyle: IndieFolkTheme.body(isDark).copyWith(
                color: IndieFolkTheme.secondary(isDark).withOpacity(0.5)))),
        ),
      ]));
  }
}
