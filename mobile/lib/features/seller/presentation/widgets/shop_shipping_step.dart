import 'package:flutter/material.dart';

/// Step 2: Shipping configuration.
/// Allows seller to enable/disable shipping methods.
class ShopShippingStep extends StatefulWidget {
  /// Creates the ShopShippingStep widget.
  const ShopShippingStep({super.key});

  @override
  State<ShopShippingStep> createState() => _ShopShippingStepState();
}

class _ShopShippingStepState extends State<ShopShippingStep> {
  final _methods = {
    'standard': true, 'express': false, 'economy': false};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Chọn phương thức vận chuyển',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Bật các phương thức vận chuyển bạn muốn sử dụng',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 20),
        _shippingTile(
          icon: Icons.local_shipping_outlined,
          title: 'Giao hàng tiêu chuẩn',
          subtitle: '3-5 ngày • Phí cơ bản',
          key: 'standard'),
        const SizedBox(height: 12),
        _shippingTile(
          icon: Icons.bolt_rounded,
          title: 'Giao hàng nhanh',
          subtitle: '1-2 ngày • Phí cao hơn',
          key: 'express'),
        const SizedBox(height: 12),
        _shippingTile(
          icon: Icons.savings_outlined,
          title: 'Giao hàng tiết kiệm',
          subtitle: '5-7 ngày • Phí thấp nhất',
          key: 'economy'),
      ]);
  }

  Widget _shippingTile({
    required IconData icon, required String title,
    required String subtitle, required String key,
  }) {
    final active = _methods[key] ?? false;
    final color = active ? const Color(0xFFEF6C4A) : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: active ? color.withOpacity(0.5) : Colors.grey.shade200,
            width: active ? 1.5 : 1),
        color: active ? color.withOpacity(0.04) : Colors.white),
      child: Row(children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black87 : Colors.grey.shade600)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 11,
                color: Colors.grey.shade500)),
          ])),
        Switch.adaptive(
          value: active, activeColor: const Color(0xFFEF6C4A),
          onChanged: (v) => setState(() => _methods[key] = v)),
      ]));
  }
}
