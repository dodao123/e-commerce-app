import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Tab content displaying detailed store profile information, coordinates, and contact details.
class ShopDetailAbout extends StatelessWidget {
  final Map<String, dynamic> shop;
  final bool isDark;
  final bool isVi;

  const ShopDetailAbout({
    super.key,
    required this.shop,
    required this.isDark,
    required this.isVi,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context,
            title: isVi ? 'Thông tin liên hệ' : 'Contact Information',
            children: [
              _infoRow(Icons.phone_outlined, isVi ? 'Số điện thoại' : 'Phone', shop['phone'] ?? ''),
              _infoRow(Icons.mail_outline, isVi ? 'Thư điện tử' : 'Email', shop['email'] ?? ''),
            ],
          ),
          const SizedBox(height: 16),
          _buildCard(
            context,
            title: isVi ? 'Địa chỉ cửa hàng' : 'Store Location',
            children: [
              _infoRow(
                Icons.location_on_outlined,
                isVi ? 'Địa chỉ chi tiết' : 'Full Address',
                '${shop['detail_address'] ?? ''}, ${shop['ward'] ?? ''}, ${shop['district'] ?? ''}, ${shop['province'] ?? ''}',
              ),
              if (shop['lat'] != null && shop['lng'] != null)
                _infoRow(
                  Icons.gps_fixed_outlined,
                  isVi ? 'Tọa độ GPS' : 'GPS Coordinates',
                  'Lat: ${shop['lat']}, Lng: ${shop['lng']}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Card(
      color: isDark ? DarkColors.surface : Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const Divider(height: 24, thickness: 0.5),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
