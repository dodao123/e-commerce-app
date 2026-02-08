import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/pages/settings_page.dart';

/// Custom app bar with settings, search, and login button.
class HomeAppBar extends StatelessWidget {
  /// Creates the HomeAppBar widget.
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Settings button (green icon)
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, size: 22,
                  color: Colors.black87),
            ),
          ),
          const Spacer(),
          // Search icon
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 26),
          ),
          const SizedBox(width: 8),
          // Log In button (when not authenticated)
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(isVi ? 'Đăng Nhập' : 'Log In',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
