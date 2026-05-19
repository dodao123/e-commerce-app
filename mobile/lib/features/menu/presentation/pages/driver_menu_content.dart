import 'package:flutter/material.dart';
import '../widgets/menu_profile_header.dart';
import '../widgets/menu_utilities.dart';
import '../widgets/menu_support.dart';
import '../widgets/driver_delivery_stats.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../driver/presentation/pages/driver_wallet_page.dart';
import '../../../driver/presentation/pages/driver_profile_page.dart';

/// Driver specific menu content.
class DriverMenuContent extends StatelessWidget {
  final bool isVi;
  final String driverName;
  final String driverEmail;
  final String avatarUrl;

  /// Creates DriverMenuContent.
  const DriverMenuContent({
    super.key,
    required this.isVi,
    required this.driverName,
    required this.driverEmail,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(children: [
        MenuProfileHeader(
          userName: driverName,
          userEmail: driverEmail,
          avatarUrl: avatarUrl,
          roleLabel: isVi ? 'Tài xế' : 'Driver',
        ),
        const SizedBox(height: 16),
        DriverDeliveryStats(isVi: isVi),
        const SizedBox(height: 16),
        MenuUtilities(isVi: isVi),
        const SizedBox(height: 16),
        _buildProfileButton(context, isDark, isVi),
        const SizedBox(height: 16),
        _buildWalletButton(context, isDark),
        const SizedBox(height: 16),
        MenuSupport(isVi: isVi),
      ]),
    );
  }

  Widget _buildProfileButton(BuildContext context, bool isDark, bool isVi) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DriverProfilePage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IndieFolkTheme.surface(isDark),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: IndieFolkTheme.primary(isDark).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.assignment_ind_outlined,
                size: 24,
                color: IndieFolkTheme.primary(isDark),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isVi ? 'Hồ Sơ Tài Xế' : 'Driver Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: IndieFolkTheme.primary(isDark),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: IndieFolkTheme.secondary(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DriverWalletPage()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IndieFolkTheme.surface(isDark),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: IndieFolkTheme.tertiary(isDark).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 24,
                color: IndieFolkTheme.tertiary(isDark),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVi ? 'Ví Tài Xế' : 'Driver Wallet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: IndieFolkTheme.primary(isDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVi ? 'Xem số dư & lịch sử giao dịch' : 'View balance & transactions',
                    style: TextStyle(
                      fontSize: 12,
                      color: IndieFolkTheme.secondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: IndieFolkTheme.secondary(isDark),
            ),
          ],
        ),
      ),
    );
  }
}
