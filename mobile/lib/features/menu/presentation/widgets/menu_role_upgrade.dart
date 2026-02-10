import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import 'role_upgrade_tile.dart';

/// Section displaying role switch options.
/// Shows all roles except the current one for switching.
class MenuRoleUpgrade extends StatelessWidget {
  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates a MenuRoleUpgrade widget.
  const MenuRoleUpgrade({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = context.watch<AuthProvider>().userRole;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              isVi ? 'Chuyển đổi vai trò' : 'Switch Role',
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600))),
          ..._buildTiles(context, role),
        ]),
    );
  }

  List<Widget> _buildTiles(BuildContext context, String role) {
    final allRoles = [
      _RoleOption('buyer', Icons.shopping_bag_outlined,
        isVi ? 'Người mua hàng' : 'Buyer',
        isVi ? 'Mua sắm sản phẩm' : 'Shop for products',
        const [Color(0xFF4A3ADB), Color(0xFF6C5CE7)]),
      _RoleOption('seller', Icons.store_outlined,
        isVi ? 'Người bán hàng' : 'Seller',
        isVi ? 'Bán hàng trực tuyến' : 'Sell products online',
        const [Color(0xFFEF6C4A), Color(0xFFFF8C6B)]),
      _RoleOption('driver', Icons.delivery_dining_outlined,
        isVi ? 'Tài xế giao hàng' : 'Driver',
        isVi ? 'Giao hàng kiếm tiền' : 'Deliver & earn',
        const [Color(0xFF00D2D3), Color(0xFF00E5C9)]),
    ];

    return allRoles
        .where((option) => option.role != role)
        .map((option) => RoleUpgradeTile(
              icon: option.icon,
              title: option.title,
              subtitle: option.subtitle,
              gradientColors: option.colors,
              onTap: () => _switchRole(context, option)))
        .toList();
  }

  void _switchRole(BuildContext context, _RoleOption option) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          isVi ? 'Chuyển sang ${option.title}' : 'Switch to ${option.title}'),
        content: Text(isVi
          ? 'Bạn có muốn chuyển sang vai trò ${option.title}?'
          : 'Switch your role to ${option.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isVi ? 'Hủy' : 'Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeSwitch(context, option.role);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: Text(isVi ? 'Xác nhận' : 'Confirm')),
        ]));
  }

  Future<void> _executeSwitch(BuildContext context, String role) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateRole(role);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
          ? 'Đã chuyển vai trò thành công!'
          : 'Role switched successfully!'),
        backgroundColor: Colors.green));
    }
  }
}

/// Internal data class for role option configuration.
class _RoleOption {
  final String role;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _RoleOption(
    this.role, this.icon, this.title, this.subtitle, this.colors);
}
