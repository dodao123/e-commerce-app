import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Settings page with theme and language options.
class SettingsPage extends StatelessWidget {
  /// Creates the SettingsPage widget.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final isVi = provider.locale.languageCode == 'vi';

    return Scaffold(
      appBar: AppBar(
        title: Text(isVi ? 'Cài Đặt' : 'Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(isVi ? 'Giao Diện' : 'Appearance'),
          const SizedBox(height: 12),
          _buildThemeCard(provider, isDark, isVi),
          const SizedBox(height: 28),
          _buildSectionTitle(isVi ? 'Ngôn Ngữ' : 'Language'),
          const SizedBox(height: 12),
          _buildLanguageCard(provider),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildThemeCard(AppProvider provider, bool isDark, bool isVi) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(isVi ? 'Chế Độ Tối' : 'Dark Mode',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(isDark
              ? (isVi ? 'Đang bật giao diện tối' : 'Dark theme active')
              : (isVi ? 'Đang bật giao diện sáng' : 'Light theme active')),
          secondary: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: AppColors.primary,
            size: 28,
          ),
          value: isDark,
          activeColor: AppColors.primary,
          onChanged: (_) => provider.toggleTheme(),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(AppProvider provider) {
    final currentLang = provider.locale.languageCode;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildLangTile(provider, 'en', 'English', '🇺🇸', currentLang == 'en'),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildLangTile(
              provider, 'vi', 'Tiếng Việt', '🇻🇳', currentLang == 'vi'),
        ],
      ),
    );
  }

  Widget _buildLangTile(
      AppProvider provider, String code, String label,
      String flag, bool selected) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () => provider.setLocale(code),
    );
  }
}
