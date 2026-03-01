import 'package:flutter/material.dart';
import '../widgets/seller_profile_header.dart';
import '../widgets/seller_order_stats.dart';
import '../widgets/seller_tools.dart';
import '../widgets/seller_suggestions.dart';
import '../widgets/menu_role_upgrade.dart';

/// Seller menu layout with shop profile, order stats,
/// seller tools, and promotional suggestions.
class SellerMenuContent extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Shop owner name.
  final String shopName;

  /// Shop owner email.
  final String shopEmail;

  /// Avatar URL.
  final String avatarUrl;

  /// Shop ID for order queries.
  final String shopId;

  /// Creates the SellerMenuContent widget.
  const SellerMenuContent({
    super.key,
    required this.isVi,
    required this.shopName,
    required this.shopEmail,
    required this.avatarUrl,
    required this.shopId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(children: [
        // 1. Shop profile header
        SellerProfileHeader(
          shopName: shopName,
          shopEmail: shopEmail,
          avatarUrl: avatarUrl,
          isVi: isVi),
        const SizedBox(height: 16),

        // 2. Order stats
        SellerOrderStats(isVi: isVi, shopId: shopId),
        const SizedBox(height: 16),

        // 3. Seller tools
        SellerTools(isVi: isVi),
        const SizedBox(height: 16),

        // 4. Role switching
        MenuRoleUpgrade(isVi: isVi),
        const SizedBox(height: 20),

        // 5. Suggestions
        SellerSuggestions(isVi: isVi),
      ]),
    );
  }
}
