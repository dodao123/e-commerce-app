import 'package:flutter/material.dart';

/// Reusable back button with glass morphism effect.
/// Used in Login and Register pages over the header gradient.
class AuthBackButton extends StatelessWidget {
  /// Creates AuthBackButton widget.
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(top: 64, left: 14,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Colors.white.withOpacity(0.3))),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 25))));
  }
}
