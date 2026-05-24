import 'package:flutter/material.dart';

/// A reusable placeholder widget shown when no products are found on the home page.
class HomeEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const HomeEmptyState({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('No products found'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
