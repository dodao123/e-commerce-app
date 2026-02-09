import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/role_card.dart';
import '../../../shell/main_shell.dart';

/// Page for selecting user role after successful social login.
/// Displays buyer, seller, and shipper options.
class RoleSelectionPage extends StatelessWidget {
  /// Creates the RoleSelectionPage widget.
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              _buildHeader(isVi, authProvider),
              const SizedBox(height: 40),
              _buildRoleGrid(context, isVi, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the greeting header with user name.
  Widget _buildHeader(bool isVi, AuthProvider authProvider) {
    final userName = authProvider.userName;
    return Column(
      children: [
        Text(
          isVi ? 'Xin chào, $userName!' : 'Welcome, $userName!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isVi ? 'Bạn muốn sử dụng ứng dụng với vai trò nào?'
              : 'How would you like to use the app?',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the grid of role selection cards.
  Widget _buildRoleGrid(
    BuildContext context,
    bool isVi,
    AuthProvider authProvider,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleCard(
            icon: Icons.shopping_bag_outlined,
            title: isVi ? 'Người Mua' : 'Buyer',
            subtitle: isVi ? 'Mua sắm sản phẩm' : 'Shop for products',
            color: const Color(0xFF4A3ADB),
            onTap: () => _selectRole(context, 'buyer', authProvider),
          ),
          const SizedBox(height: 16),
          RoleCard(
            icon: Icons.store_outlined,
            title: isVi ? 'Người Bán' : 'Seller',
            subtitle: isVi ? 'Bán hàng trực tuyến' : 'Sell products online',
            color: const Color(0xFFEF6C4A),
            onTap: () => _selectRole(context, 'seller', authProvider),
          ),
          const SizedBox(height: 16),
          RoleCard(
            icon: Icons.delivery_dining_outlined,
            title: isVi ? 'Tài Xế' : 'Shipper',
            subtitle: isVi ? 'Giao hàng kiếm tiền' : 'Deliver & earn',
            color: const Color(0xFF00D2D3),
            onTap: () => _selectRole(context, 'driver', authProvider),
          ),
        ],
      ),
    );
  }

  /// Handles role selection and navigates to home page.
  Future<void> _selectRole(
    BuildContext context,
    String role,
    AuthProvider authProvider,
  ) async {
    final success = await authProvider.updateRole(role);
    if (success && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    }
  }
}
