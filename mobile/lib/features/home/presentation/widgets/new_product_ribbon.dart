import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A diagonal "New Product" ribbon widget for the top-right corner of cards.
class NewProductRibbon extends StatelessWidget {
  /// Creates a NewProductRibbon.
  const NewProductRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final text = lang == 'vi' ? 'MỚI' : 'NEW';

    return Positioned(
      top: -6,
      right: -28,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 100,
          height: 38,
          padding: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6B6B),
                Color(0xFFFF1E56),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
