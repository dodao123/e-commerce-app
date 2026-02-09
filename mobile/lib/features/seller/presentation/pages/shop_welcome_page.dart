import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'shop_registration_page.dart';

/// Welcome page shown when seller accesses shop for the first time.
/// Prompts the user to begin the seller registration process.
class ShopWelcomePage extends StatelessWidget {
  /// Creates the ShopWelcomePage widget.
  const ShopWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.background,
      appBar: _buildAppBar(isDark, isVi),
      body: _buildBody(context, isDark, isVi));
  }

  PreferredSizeWidget _buildAppBar(bool isDark, bool isVi) {
    return AppBar(
      backgroundColor: isDark ? DarkColors.surface : Colors.white,
      elevation: 0.5,
      title: Text(isVi ? 'Shop của tôi' : 'My Shop',
          style: TextStyle(
              color: isDark ? DarkColors.textPrimary
                  : AppColors.textPrimary,
              fontSize: 17, fontWeight: FontWeight.w600)),
      iconTheme: IconThemeData(
          color: isDark ? DarkColors.textPrimary
              : AppColors.textPrimary));
  }

  Widget _buildBody(BuildContext ctx, bool isDark, bool isVi) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.storefront_outlined, size: 80,
              color: isDark ? DarkColors.textSecondary
                  : AppColors.textSecondary),
          const SizedBox(height: 24),
          Text(isVi ? 'Chào mừng đến với Shop!'
              : 'Welcome to your Shop!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? DarkColors.textPrimary
                      : AppColors.textPrimary)),
          const SizedBox(height: 12),
          Text(isVi ? 'Đăng ký ngay để bắt đầu bán hàng'
              : 'Register now to start selling',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14,
                  color: isDark ? DarkColors.textSecondary
                      : AppColors.textSecondary)),
          const SizedBox(height: 32),
          _buildStartButton(ctx, isVi),
        ])));
  }

  Widget _buildStartButton(BuildContext ctx, bool isVi) {
    return SizedBox(width: double.infinity, height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => const ShopRegistrationPage())),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0),
        child: Text(isVi ? 'Bắt đầu đăng ký' : 'Start Registration',
            style: const TextStyle(fontSize: 16,
                fontWeight: FontWeight.w700))));
  }
}
