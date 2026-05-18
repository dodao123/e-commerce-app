import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';

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
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        backgroundColor: IndieFolkTheme.neutral(isDark),
        elevation: 0,
        title: Text(isVi ? 'Cài Đặt' : 'Settings',
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle(isVi ? 'Giao Diện' : 'Appearance', isDark),
          const SizedBox(height: 12),
          _buildThemeCard(provider, isDark, isVi),
          const SizedBox(height: 28),
          _buildSectionTitle(isVi ? 'Ngôn Ngữ' : 'Language', isDark),
          const SizedBox(height: 12),
          _buildLanguageCard(provider, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title,
        style: IndieFolkTheme.body(isDark).copyWith(
            fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildThemeCard(AppProvider provider, bool isDark, bool isVi) {
    return Card(
      color: IndieFolkTheme.surface(isDark),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(isVi ? 'Chế Độ Tối' : 'Dark Mode',
              style: IndieFolkTheme.body(isDark).copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(isDark
              ? (isVi ? 'Đang bật giao diện tối' : 'Dark theme active')
              : (isVi ? 'Đang bật giao diện sáng' : 'Light theme active'),
              style: IndieFolkTheme.label(isDark).copyWith(color: IndieFolkTheme.secondary(isDark))),
          secondary: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: IndieFolkTheme.tertiary(isDark),
            size: 28,
          ),
          value: isDark,
          activeColor: IndieFolkTheme.tertiary(isDark),
          onChanged: (_) => provider.toggleTheme(),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(AppProvider provider, bool isDark) {
    final currentLang = provider.locale.languageCode;
    return Card(
      color: IndieFolkTheme.surface(isDark),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildLangTile(provider, 'en', 'English', '🇺🇸', currentLang == 'en', isDark),
          Divider(height: 1, indent: 20, endIndent: 20, color: IndieFolkTheme.secondary(isDark).withOpacity(0.2)),
          _buildLangTile(
              provider, 'vi', 'Tiếng Việt', '🇻🇳', currentLang == 'vi', isDark),
        ],
      ),
    );
  }

  Widget _buildLangTile(
      AppProvider provider, String code, String label,
      String flag, bool selected, bool isDark) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: IndieFolkTheme.body(isDark).copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? IndieFolkTheme.tertiary(isDark) : IndieFolkTheme.primary(isDark))),
      trailing: selected
          ? Icon(Icons.check_circle, color: IndieFolkTheme.tertiary(isDark))
          : Icon(Icons.circle_outlined, color: IndieFolkTheme.secondary(isDark)),
      onTap: () => provider.setLocale(code),
    );
  }
}
