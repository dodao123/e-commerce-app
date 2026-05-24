import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A diagonal ribbon that wraps the card corner without covering the corner tip.
class NewProductRibbon extends StatelessWidget {
  /// Creates a NewProductRibbon widget.
  const NewProductRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final text = lang == 'vi' ? 'MỚI' : 'NEW';

    return Positioned(
      top: 16,
      right: -24,
      child: Transform.rotate(
        angle: math.pi / 4,
        child: Container(
          width: 90,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF6B6B),
                Color(0xFFFF1E56),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
