import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';

/// "Suggestions for you" section with promotional cards.
class SellerSuggestions extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates the SellerSuggestions widget.
  const SellerSuggestions({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(isVi ? 'Đề xuất cho bạn' : 'Suggestions for you',
            style: IndieFolkTheme.body(isDark).copyWith(
                fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _suggestionCard(
          icon: Icons.rocket_launch_rounded,
          title: isVi ? 'Quảng cáo Shop' : 'Promote Shop',
          subtitle: isVi
              ? 'Tăng trung bình 30% lượng truy cập và doanh thu'
              : 'Increase traffic and revenue by 30% on average',
          buttonLabel: isVi ? 'Thử ngay' : 'Try Now',
          gradientColors: const [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
          isDark: isDark),
        const SizedBox(height: 10),
        _suggestionCard(
          icon: Icons.people_alt_rounded,
          title: isVi ? 'Tiếp thị liên kết' : 'Affiliate Marketing',
          subtitle: isVi
              ? 'Đẩy mạnh quảng bá Shop với mạng lưới tiếp thị'
              : 'Boost your shop with affiliate marketing network',
          buttonLabel: isVi ? 'Khám phá' : 'Explore',
          gradientColors: const [Color(0xFFFF6D00), Color(0xFFFF9800)],
          isDark: isDark),
      ]);
  }

  Widget _suggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: gradientColors.first.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 28, color: Colors.white)),
        const SizedBox(width: 14),
        // Text
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: IndieFolkTheme.body(isDark).copyWith(
                fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: IndieFolkTheme.body(isDark).copyWith(fontSize: 11,
                    color: IndieFolkTheme.secondary(isDark))),
          ])),
        const SizedBox(width: 8),
        // Action button
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors),
            borderRadius: BorderRadius.circular(6)),
          child: Text(buttonLabel, style: IndieFolkTheme.body(true).copyWith(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
