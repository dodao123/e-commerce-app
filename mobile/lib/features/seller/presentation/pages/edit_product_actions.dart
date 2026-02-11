import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/product_edit_datasource.dart';
import 'add_product_helpers.dart';
import 'edit_product_page.dart';

PreferredSizeWidget buildEditAppBar(
    BuildContext ctx, bool isDark, bool isVi) {
  return AppBar(
    backgroundColor: isDark ? DarkColors.surface : Colors.white,
    elevation: 0.5,
    leading: IconButton(
      onPressed: () => Navigator.pop(ctx),
      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20)),
    title: Text(isVi ? 'Chỉnh sửa sản phẩm' : 'Edit Product',
      style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.w600)));
}

Future<void> pickEditImages(EditProductPageState state) async {
  final total = state.existingImages.length + state.newImages.length;
  if (total >= 10) return;
  final picked = await ImagePicker().pickMultiImage(
    imageQuality: 80, limit: 10 - total);
  if (picked.isNotEmpty && state.mounted) {
    state.setState(() {
      for (final f in picked) {
        if (state.existingImages.length +
            state.newImages.length < 10) {
          state.newImages.add(f.path);
        }
      }
    });
  }
}

Future<void> addEditVideoUrl(
    BuildContext ctx, EditProductPageState state) async {
  final isVi = ctx.read<AppProvider>().locale.languageCode == 'vi';
  final url = await showVideoUrlDialog(ctx, isVi);
  if (url != null && url.isNotEmpty && state.mounted) {
    state.setState(() => state.videoUrl = url);
  }
}

/// Removes an image at index; tracks server-side deletions.
void removeEditImage(EditProductPageState state, int index) {
  final n = state.existingImages.length;
  state.setState(() {
    if (index < n) {
      state.imagesToDelete.add(state.existingImages.removeAt(index));
    } else {
      state.newImages.removeAt(index - n);
    }
  });
}

/// Shows delete confirmation, then executes deletion.
Future<void> confirmDeleteProduct(
    BuildContext ctx, EditProductPageState state) async {
  final isVi = ctx.read<AppProvider>().locale.languageCode == 'vi';
  final ok = await showDialog<bool>(context: ctx,
    builder: (c) => AlertDialog(
      title: Text(isVi ? 'Xóa sản phẩm?' : 'Delete product?'),
      content: Text(isVi
          ? 'Sản phẩm sẽ bị xóa vĩnh viễn. Bạn có chắc?'
          : 'This will be permanently deleted. Sure?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false),
          child: Text(isVi ? 'Hủy' : 'Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true),
          child: Text(isVi ? 'Xóa' : 'Delete',
            style: const TextStyle(color: Colors.red))),
      ]));
  if (ok != true || !state.mounted) return;
  state.setState(() => state.saving = true);
  try {
    final token = await TokenManager().getToken();
    if (token == null) throw Exception('No token');
    await ProductEditDatasource().deleteProduct(
      token: token,
      productId: state.widget.product['id'] as String);
    if (!state.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(isVi ? 'Đã xóa' : 'Deleted'),
      backgroundColor: Colors.green));
    Navigator.pop(ctx, true);
  } catch (e) {
    if (!state.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('Error: $e'), backgroundColor: Colors.red));
  } finally {
    if (state.mounted) state.setState(() => state.saving = false);
  }
}
