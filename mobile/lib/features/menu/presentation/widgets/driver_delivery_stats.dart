import 'package:flutter/material.dart';
import '../../../checkout/data/order_datasource.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../driver/presentation/pages/driver_order_list_page.dart';

/// Driver delivery stats widget for the menu page.
class DriverDeliveryStats extends StatefulWidget {
  final bool isVi;

  const DriverDeliveryStats({super.key, required this.isVi});

  @override
  State<DriverDeliveryStats> createState() => _DriverDeliveryStatsState();
}

class _DriverDeliveryStatsState extends State<DriverDeliveryStats> {
  final _ds = OrderDatasource();
  int _pickingUp = 0;
  int _shipping = 0;
  int _delivered = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final orders = await _ds.fetchDriverOrders();
      if (!mounted) return;
      int pickingUp = 0;
      int shipping = 0;
      int delivered = 0;

      for (var o in orders) {
        final status = o['status']?.toString() ?? '';
        // Since driver only accepts orders in 'finding_driver',
        // 'shipping' could mean either picking up or shipping.
        // For simplicity, we can just group them or differentiate by another logic.
        // Let's assume 'shipping' is the main active state, and 'delivered' is done.
        // If the system expands, we can add 'picking_up'. For now, we'll map:
        if (status == 'finding_driver') pickingUp++;
        if (status == 'shipping') shipping++;
        if (status == 'delivered') delivered++;
      }

      setState(() {
        _pickingUp = pickingUp;
        _shipping = shipping;
        _delivered = delivered;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : IndieFolkTheme.surface(isDark),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isVi ? 'Đơn hàng của tôi' : 'My Orders',
                  style: IndieFolkTheme.body(isDark).copyWith(
                    fontWeight: FontWeight.bold,
                    color: IndieFolkTheme.primary(isDark),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderListPage(
                        initialTab: 0,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.isVi ? 'Xem lịch sử' : 'View history',
                    style: IndieFolkTheme.label(isDark).copyWith(
                      color: IndieFolkTheme.tertiary(isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: Icons.storefront,
                  label: widget.isVi ? 'Đang lấy' : 'Picking Up',
                  count: _pickingUp,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderListPage(initialTab: 1),
                    ),
                  ),
                ),
                _buildStatItem(
                  icon: Icons.local_shipping_outlined,
                  label: widget.isVi ? 'Đang giao' : 'Shipping',
                  count: _shipping,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderListPage(initialTab: 2),
                    ),
                  ),
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: widget.isVi ? 'Đã giao' : 'Delivered',
                  count: _delivered,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DriverOrderListPage(initialTab: 3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: IndieFolkTheme.secondary(isDark),
                ),
                if (count > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: IndieFolkTheme.primary(isDark),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
