import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/product_image_picker.dart';
import '../widgets/product_condition_picker.dart';
import 'add_product_form_fields.dart';
import 'add_product_helpers.dart';

/// Builds the scrollable form body for EditProductPage.
Widget buildEditBody({
  required BuildContext context,
  required bool isDark,
  required bool isVi,
  required List<String> allImages,
  required String videoUrl,
  required VoidCallback onAddImage,
  required VoidCallback onAddVideo,
  required ValueChanged<int> onRemoveImage,
  required VoidCallback onRemoveVideo,
  required TextEditingController nameCtrl,
  required TextEditingController descCtrl,
  required TextEditingController priceCtrl,
  required TextEditingController stockCtrl,
  required TextEditingController shippingCtrl,
  required String category,
  required VoidCallback onPickCategory,
  required bool isNew,
  required ValueChanged<bool> onConditionChanged,
  required TextEditingController conditionNoteCtrl,
}) {
  return SingleChildScrollView(child: Column(children: [
    buildProductTipBanner(isDark, isVi),
    const SizedBox(height: 8),
    ProductImagePicker(
      imagePaths: allImages, videoUrl: videoUrl,
      onAddImage: onAddImage, onAddVideo: onAddVideo,
      onRemoveImage: onRemoveImage,
      onRemoveVideo: onRemoveVideo,
      isDark: isDark, isVi: isVi),
    const SizedBox(height: 8),
    AddProductFormFields(
      nameCtrl: nameCtrl, descCtrl: descCtrl,
      priceCtrl: priceCtrl, stockCtrl: stockCtrl,
      shippingCtrl: shippingCtrl, category: category,
      onPickCategory: onPickCategory,
      isDark: isDark, isVi: isVi),
    const SizedBox(height: 8),
    ProductConditionPicker(
      isNew: isNew,
      onChanged: onConditionChanged,
      noteController: conditionNoteCtrl,
      isDark: isDark, isVi: isVi),
    const SizedBox(height: 24),
  ]));
}

/// Builds the bottom bar with Save and Delete buttons.
Widget buildEditBottomBar({
  required bool isDark,
  required bool isVi,
  required bool saving,
  required VoidCallback? onSave,
  required VoidCallback? onDelete,
}) {
  return SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
    child: Row(children: [
      Expanded(child: SizedBox(height: 48,
        child: OutlinedButton(
          onPressed: saving ? null : onDelete,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
          child: Text(isVi ? 'Xóa' : 'Delete',
            style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600))))),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: SizedBox(height: 48,
        child: ElevatedButton(
          onPressed: saving ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0),
          child: Text(isVi ? 'Cập nhật' : 'Update',
            style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w600))))),
    ])));
}
