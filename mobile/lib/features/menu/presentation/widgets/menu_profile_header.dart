import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// Profile header card for the Menu page.
class MenuProfileHeader extends StatelessWidget {
  /// User's display name.
  final String userName;

  /// User's email address.
  final String userEmail;

  /// User's avatar URL (empty = show initial).
  final String avatarUrl;

  /// User's role label (e.g., 'Buyer').
  final String roleLabel;

  /// Creates the MenuProfileHeader widget.
  const MenuProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedUrl = ApiConstants.resolveImageUrl(avatarUrl);
    final hasAvatar = resolvedUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF6C4A), Color(0xFFFF8A65)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(6)),
      child: Row(children: [
        CircleAvatar(radius: 30,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: (hasAvatar && !resolvedUrl.toLowerCase().endsWith('.svg')) ? NetworkImage(resolvedUrl) : null,
          child: (hasAvatar && !resolvedUrl.toLowerCase().endsWith('.svg')) ? null : Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
            style: IndieFolkTheme.h1(true).copyWith(color: Colors.white,
                fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(userName, style: IndieFolkTheme.h1(true).copyWith(fontSize: 18,
                fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(userEmail, style: IndieFolkTheme.body(true).copyWith(fontSize: 12,
                color: Colors.white.withValues(alpha: 0.85))),
          ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(6)),
          child: Text(roleLabel, style: IndieFolkTheme.body(true).copyWith(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
