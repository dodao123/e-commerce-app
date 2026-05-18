import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import 'product_image_helpers.dart';

/// Image/video picker for product forms.
/// Handles local file paths and server-side URLs.
class ProductImagePicker extends StatelessWidget {
  final List<String> imagePaths;
  final String videoUrl;
  final VoidCallback onAddImage;
  final VoidCallback onAddVideo;
  final ValueChanged<int> onRemoveImage;
  final VoidCallback onRemoveVideo;
  final bool isDark;
  final bool isVi;

  /// Creates the ProductImagePicker widget.
  const ProductImagePicker({
    super.key, required this.imagePaths,
    required this.videoUrl, required this.onAddImage,
    required this.onAddVideo, required this.onRemoveImage,
    required this.onRemoveVideo,
    required this.isDark, required this.isVi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: IndieFolkTheme.surface(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(), const SizedBox(height: 12), _imageGrid(),
          if (videoUrl.isEmpty) ...[
            const SizedBox(height: 12),
            buildAddVideoButton(
                onTap: onAddVideo, isDark: isDark, isVi: isVi),
          ] else ...[
            const SizedBox(height: 8),
            buildVideoChip(url: videoUrl,
                onRemove: onRemoveVideo, isDark: isDark),
          ],
        ]));
  }

  Widget _header() => Row(children: [
    Text(isVi ? 'Hình ảnh/video sản phẩm'
        : 'Product images/video',
      style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
    const Text(' *', style: TextStyle(color: Colors.red)),
    const Spacer(),
    Text(isVi ? 'Tỉ lệ 1:1' : 'Ratio 1:1',
      style: IndieFolkTheme.label(isDark).copyWith(color: IndieFolkTheme.secondary(isDark))),
  ]);

  Widget _imageGrid() => Wrap(spacing: 8, runSpacing: 8,
    children: [
      ...List.generate(imagePaths.length, _imageThumb),
      if (imagePaths.length < 10) buildAddImageButton(
          onTap: onAddImage, isDark: isDark, isVi: isVi),
    ]);

  Widget _imageThumb(int i) {
    return Stack(clipBehavior: Clip.none, children: [
      ClipRRect(borderRadius: BorderRadius.circular(8),
        child: _renderImage(imagePaths[i])),
      Positioned(top: -6, right: -6,
        child: GestureDetector(onTap: () => onRemoveImage(i),
          child: Container(width: 20, height: 20,
            decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.close,
                size: 12, color: Colors.white)))),
    ]);
  }

  Widget _renderImage(String path) {
    if (path.startsWith('uploads/')) {
      return Image.network('${ApiConstants.baseUrl}/$path',
        width: 72, height: 72, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _ph());
    }
    if (path.startsWith('/') || path.contains(':')) {
      return Image.file(File(path), width: 72, height: 72,
        fit: BoxFit.cover, errorBuilder: (_, __, ___) => _ph());
    }
    return _ph();
  }

  Widget _ph() => Container(width: 72, height: 72,
    decoration: BoxDecoration(color: IndieFolkTheme.neutral(isDark),
      borderRadius: BorderRadius.circular(8)),
    child: Icon(Icons.image, size: 28,
      color: IndieFolkTheme.secondary(isDark)));
}
