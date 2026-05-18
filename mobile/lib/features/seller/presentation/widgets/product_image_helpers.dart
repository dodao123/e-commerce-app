import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

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
        color: IndieFolkTheme.neutral(isDark),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: IndieFolkTheme.tertiary(isDark).withOpacity(0.5),
          style: BorderStyle.solid, width: 1.5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
            color: IndieFolkTheme.tertiary(isDark), size: 24),
          const SizedBox(height: 2),
          Text(isVi ? 'Thêm ảnh' : 'Add photo',
            style: IndieFolkTheme.label(isDark).copyWith(
              color: IndieFolkTheme.tertiary(isDark))),
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
        color: IndieFolkTheme.secondary(isDark)),
      const SizedBox(width: 6),
      Text(isVi ? 'Thêm video (URL)' : 'Add video (URL)',
        style: IndieFolkTheme.body(isDark).copyWith(
          color: IndieFolkTheme.secondary(isDark), fontSize: 13)),
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
      color: IndieFolkTheme.neutral(isDark),
      borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.videocam, size: 16, color: IndieFolkTheme.tertiary(isDark)),
      const SizedBox(width: 6),
      Flexible(child: Text(url, maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: IndieFolkTheme.label(isDark).copyWith(color: IndieFolkTheme.tertiary(isDark)))),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: onRemove,
        child: const Icon(Icons.close, size: 14, color: Colors.red)),
    ]));
}
