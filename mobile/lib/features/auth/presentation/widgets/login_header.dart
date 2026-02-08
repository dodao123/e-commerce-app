import 'package:flutter/material.dart';

/// Gradient header with logo and title for auth pages.
class LoginHeader extends StatelessWidget {
  /// Title text to display.
  final String title;

  /// Subtitle text to display.
  final String subtitle;

  /// Creates a LoginHeader.
  const LoginHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A3ADB), // Deep purple
            Color(0xFF6C5CE7), // Medium purple
            Color(0xFF8B7FE8), // Light purple
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo icon
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 14,
                  height: 1.5)),
        ],
      ),
    );
  }
}
