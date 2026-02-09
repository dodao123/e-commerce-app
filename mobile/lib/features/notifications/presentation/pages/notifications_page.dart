import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Notifications page — displays user notifications.
class NotificationsPage extends StatelessWidget {
  /// Creates the NotificationsPage widget.
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVi ? 'Thông Báo' : 'Notifications',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildEmptyState(isVi, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isVi, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80,
              color: isDark
                  ? DarkColors.textSecondary
                  : AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            isVi ? 'Chưa có thông báo' : 'No notifications yet',
            style: TextStyle(fontSize: 16,
                color: isDark
                    ? DarkColors.textSecondary
                    : AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            isVi
                ? 'Bạn sẽ nhận thông báo về\nđơn hàng và khuyến mãi tại đây.'
                : 'You\'ll receive order updates\nand promotions here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13,
                color: isDark
                    ? DarkColors.textSecondary.withOpacity(0.7)
                    : AppColors.textSecondary.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}
