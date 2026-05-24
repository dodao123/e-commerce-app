import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../data/product_edit_datasource.dart';
import '../../data/product_remote_datasource.dart';
import '../widgets/image_processing_overlay.dart';
import 'edit_product_page.dart';

/// Submits the edited product data to the API.
/// Handles: field updates, image deletion, new image upload.
Future<void> submitEditProduct(
    BuildContext ctx, EditProductPageState state) async {
  final isVi = ctx.read<AppProvider>().locale.languageCode == 'vi';
  if (state.nameCtrl.text.isEmpty || state.priceCtrl.text.isEmpty) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(isVi
          ? 'Vui lòng nhập tên và giá'
          : 'Please enter name and price')));
    return;
  }

  state.setState(() => state.saving = true);
  try {
    final token = await TokenManager().getToken();
    if (token == null) throw Exception('No token');

    final productId = state.widget.product['id'] as String;
    final datasource = ProductEditDatasource();

    // Step 1: Delete removed images from server
    if (state.imagesToDelete.isNotEmpty) {
      await datasource.deleteImages(
        token: token,
        productId: productId,
        imagePaths: state.imagesToDelete);
    }

    // Step 2: Upload new local images
    if (state.newImages.isNotEmpty && state.mounted) {
      ImageProcessingOverlay.show(ctx,
        isVi: isVi,
        message: isVi
            ? 'Đang xử lý ảnh mới...'
            : 'Processing new images...');
      try {
        await ProductRemoteDatasource().uploadImages(
          token: token,
          productId: productId,
          localPaths: state.newImages);
      } finally {
        if (state.mounted) ImageProcessingOverlay.hide(ctx);
      }
    }

    // Step 3: Update product fields
    await datasource.updateProduct(
      token: token,
      productId: productId,
      updateData: _buildUpdatePayload(state));

    if (!state.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(isVi
          ? 'Cập nhật thành công!'
          : 'Product updated successfully!'),
      backgroundColor: Colors.green));
    Navigator.pop(ctx, true);
  } catch (error) {
    debugPrint('❌ Update error: $error');
    if (!state.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('Error: $error'),
      backgroundColor: Colors.red));
  } finally {
    if (state.mounted) {
      state.setState(() => state.saving = false);
    }
  }
}

/// Builds the JSON update payload from form state.
Map<String, dynamic> _buildUpdatePayload(
    EditProductPageState state) {
  return {
    'name': state.nameCtrl.text,
    'description': state.descCtrl.text.isNotEmpty
        ? state.descCtrl.text : 'No description',
    'category': state.category.isNotEmpty
        ? state.category : 'other',
    'price': double.tryParse(state.priceCtrl.text) ?? 0,
    'stock': int.tryParse(state.stockCtrl.text) ?? 0,
    'base_shipping_fee':
        double.tryParse(state.shippingCtrl.text) ?? 0,
    'condition': state.isNew ? 'new' : 'used',
    'condition_note': state.conditionNoteCtrl.text,
    'options': state.options
        .where((o) => o.name.isNotEmpty && o.values.isNotEmpty)
        .map((o) => o.toJson())
        .toList(),
    'video_url': state.videoUrl,
  };
}
