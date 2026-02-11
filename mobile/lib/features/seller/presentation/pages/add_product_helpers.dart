import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/product_category_picker.dart';

/// Helper methods for AddProductPage, extracted to
/// keep the main page file within 100 lines.

/// Builds the tip banner at the top of the form.
Widget buildProductTipBanner(bool isDark, bool isVi) {
  return Container(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    decoration: BoxDecoration(
      color: isDark ? DarkColors.surface : const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.shade200)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 20,
          color: Colors.orange.shade700),
        const SizedBox(width: 8),
        Expanded(child: Text(
          isVi
              ? 'Nhập đầy đủ thông tin sản phẩm để hỗ trợ '
                'người mua tìm kiếm dễ dàng hơn.'
              : 'Fill in product info completely to help '
                'buyers find your product easily.',
          style: TextStyle(fontSize: 12, height: 1.4,
            color: isDark
                ? DarkColors.textPrimary
                : Colors.brown.shade700))),
      ]));
}

/// Shows a dialog to enter a video URL.
Future<String?> showVideoUrlDialog(
    BuildContext context, bool isVi) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(isVi ? 'Thêm video URL' : 'Add Video URL'),
      content: TextField(
        controller: ctrl, autofocus: true,
        decoration: InputDecoration(
          hintText: 'https://...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8)))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(isVi ? 'Hủy' : 'Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: Text(isVi ? 'Thêm' : 'Add')),
      ]));
}

/// Builds the "Save" bottom button.
Widget buildSaveButton(bool isDark, bool isVi, VoidCallback? onSave) {
  return SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: SizedBox(height: 48, width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          elevation: 0),
        child: Text(isVi ? 'Lưu' : 'Save',
          style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w600))))));
}
