import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'product_image_helpers.dart';

/// Image/video picker section for the add product form.
/// Supports up to 10 images and 1 video URL.
class ProductImagePicker extends StatelessWidget {
  /// List of picked image paths.
  final List<String> imagePaths;

  /// Video URL string.
  final String videoUrl;

  /// Called when user taps to add images.
  final VoidCallback onAddImage;

  /// Called when user taps to add video URL.
  final VoidCallback onAddVideo;

  /// Called when user removes an image at index.
  final ValueChanged<int> onRemoveImage;

  /// Called when user removes the video.
  final VoidCallback onRemoveVideo;

  /// Whether the theme is dark.
  final bool isDark;

  /// Whether Vietnamese locale is active.
  final bool isVi;

  /// Creates the ProductImagePicker widget.
  const ProductImagePicker({
    super.key,
    required this.imagePaths,
    required this.videoUrl,
    required this.onAddImage,
    required this.onAddVideo,
    required this.onRemoveImage,
    required this.onRemoveVideo,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? DarkColors.surface : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          _imageGrid(),
          if (videoUrl.isEmpty) ...[
            const SizedBox(height: 12),
            buildAddVideoButton(
                onTap: onAddVideo, isDark: isDark, isVi: isVi),
          ] else ...[
            const SizedBox(height: 8),
            buildVideoChip(
                url: videoUrl, onRemove: onRemoveVideo, isDark: isDark),
          ],
        ]));
  }

  Widget _header() {
    return Row(children: [
      Text(isVi ? 'Hình ảnh/video sản phẩm' : 'Product images/video',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const Text(' *', style: TextStyle(color: Colors.red)),
      const Spacer(),
      Text(isVi ? 'Tỉ lệ 1:1' : 'Ratio 1:1',
        style: TextStyle(fontSize: 12,
          color: isDark ? DarkColors.textSecondary : Colors.grey)),
    ]);
  }

  Widget _imageGrid() {
    final count = imagePaths.length;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      ...List.generate(count, (i) => _imageThumb(i)),
      if (count < 10)
        buildAddImageButton(
            onTap: onAddImage, isDark: isDark, isVi: isVi),
    ]);
  }

  Widget _imageThumb(int index) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(width: 72, height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade200)),
      Positioned(top: -6, right: -6,
        child: GestureDetector(
          onTap: () => onRemoveImage(index),
          child: Container(width: 20, height: 20,
            decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.close,
                size: 12, color: Colors.white)))),
    ]);
  }
}
