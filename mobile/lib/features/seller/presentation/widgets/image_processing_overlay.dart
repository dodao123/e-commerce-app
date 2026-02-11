import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen loading overlay shown during image processing.
/// Displays a progress indicator and status message.
class ImageProcessingOverlay extends StatelessWidget {
  /// Current status message to display.
  final String message;

  /// Whether to show Vietnamese text.
  final bool isVi;

  /// Creates the ImageProcessingOverlay.
  const ImageProcessingOverlay({
    super.key,
    required this.message,
    required this.isVi,
  });

  /// Shows the overlay as a modal barrier.
  static void show(BuildContext context, {
    required bool isVi,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => ImageProcessingOverlay(
        isVi: isVi,
        message: message ?? (isVi
            ? 'Đang xử lý ảnh...'
            : 'Processing images...')),
    );
  }

  /// Dismisses the overlay.
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.symmetric(
            horizontal: 32, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _animatedIcon(),
            const SizedBox(height: 20),
            Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
                color: Colors.black87)),
            const SizedBox(height: 8),
            Text(isVi
                ? 'Vui lòng không thoát'
                : 'Please do not exit',
              style: TextStyle(fontSize: 12,
                decoration: TextDecoration.none,
                color: Colors.grey.shade500)),
          ]))));
  }

  Widget _animatedIcon() {
    return SizedBox(width: 56, height: 56,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.primary)));
  }
}
