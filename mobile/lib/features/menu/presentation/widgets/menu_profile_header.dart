import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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
    final hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF6C4A), Color(0xFFFF8A65)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        CircleAvatar(radius: 30,
          backgroundColor: Colors.white.withOpacity(0.3),
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
          child: hasAvatar ? null : Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white,
                fontSize: 24, fontWeight: FontWeight.bold))),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(userName, style: const TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(userEmail, style: TextStyle(fontSize: 12,
                color: Colors.white.withOpacity(0.85))),
          ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12)),
          child: Text(roleLabel, style: const TextStyle(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
