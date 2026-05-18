import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/providers/app_provider.dart';
import 'package:provider/provider.dart';

/// Driver Wallet Page matching Indie Folk aesthetic.
class DriverWalletPage extends StatelessWidget {
  const DriverWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        title: Text(
          isVi ? 'Ví Tài Xế' : 'Driver Wallet',
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: IndieFolkTheme.neutral(isDark),
        foregroundColor: IndieFolkTheme.primary(isDark),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: IndieFolkTheme.tertiary(isDark),
                borderRadius: BorderRadius.circular(6.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVi ? 'Tổng số dư' : 'Total Balance',
                    style: IndieFolkTheme.label(isDark).copyWith(
                      color: IndieFolkTheme.onPrimary(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0đ',
                    style: IndieFolkTheme.display(isDark).copyWith(
                      fontSize: 36,
                      color: IndieFolkTheme.onPrimary(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.account_balance,
                    label: isVi ? 'Rút tiền' : 'Withdraw',
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionBtn(
                    icon: Icons.history,
                    label: isVi ? 'Lịch sử' : 'History',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Empty State
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: IndieFolkTheme.secondary(isDark).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isVi ? 'Chưa có giao dịch nào' : 'No transactions yet',
                    style: IndieFolkTheme.body(isDark).copyWith(
                      color: IndieFolkTheme.secondary(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon, 
    required String label, 
    required bool isDark
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: IndieFolkTheme.secondary(isDark).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: IndieFolkTheme.tertiary(isDark)),
          const SizedBox(height: 8),
          Text(
            label,
            style: IndieFolkTheme.body(isDark).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
