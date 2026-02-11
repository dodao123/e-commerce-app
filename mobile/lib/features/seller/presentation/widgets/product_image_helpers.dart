import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Additional builder methods for the ProductImagePicker.
/// Separated to keep file sizes within 100 lines.

/// Builds the dashed "Add Image" button.
Widget buildAddImageButton({
  required VoidCallback onTap,
  required bool isDark,
  required bool isVi,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.5),
          style: BorderStyle.solid, width: 1.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
            color: AppColors.primary, size: 24),
          const SizedBox(height: 2),
          Text(isVi ? 'Thêm ảnh' : 'Add photo',
            style: TextStyle(fontSize: 10,
              color: AppColors.primary)),
        ])));
}

/// Builds the "Add Video URL" button.
Widget buildAddVideoButton({
  required VoidCallback onTap,
  required bool isDark,
  required bool isVi,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Icon(Icons.videocam_outlined, size: 18,
        color: isDark ? DarkColors.textSecondary : Colors.grey.shade600),
      const SizedBox(width: 6),
      Text(isVi ? 'Thêm video (URL)' : 'Add video (URL)',
        style: TextStyle(fontSize: 13,
          color: isDark
              ? DarkColors.textSecondary
              : Colors.grey.shade600)),
    ]));
}

/// Builds a chip showing the current video URL.
Widget buildVideoChip({
  required String url,
  required VoidCallback onRemove,
  required bool isDark,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: isDark
          ? DarkColors.background
          : Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.videocam, size: 16, color: Colors.blue),
      const SizedBox(width: 6),
      Flexible(child: Text(url, maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: Colors.blue))),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: onRemove,
        child: const Icon(Icons.close, size: 14, color: Colors.red)),
    ]));
}
