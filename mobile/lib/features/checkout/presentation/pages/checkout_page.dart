import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../seller/presentation/pages/address_picker_page.dart';
import '../../data/address_datasource.dart';
import '../../data/order_datasource.dart';
import '../widgets/checkout_address_section.dart';
import '../widgets/checkout_products_section.dart';
import '../widgets/checkout_summary_section.dart';

/// Checkout page matching Shopee-style layout.
class CheckoutPage extends StatefulWidget {
  /// Items to checkout (each includes shipping_fee).
  final List<Map<String, dynamic>> items;

  /// Creates CheckoutPage.
  const CheckoutPage({super.key, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addrDS = AddressDatasource();
  final _orderDS = OrderDatasource();
  List<Map<String, dynamic>> _addresses = [];
  Map<String, dynamic>? _selectedAddr;
  bool _loading = true;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _loading = true);
    _addresses = await _addrDS.fetchAll();
    if (_addresses.isNotEmpty) {
      _selectedAddr = _addresses.firstWhere(
          (a) => a['is_default'] == true,
          orElse: () => _addresses.first);
    }
    if (mounted) setState(() => _loading = false);
  }

  double get _subtotal {
    double sum = 0;
    for (final item in widget.items) {
      sum += (item['price'] as num).toDouble()
          * (item['quantity'] as num).toInt();
    }
    return sum;
  }

  double get _shippingFee {
    double sum = 0;
    for (final item in widget.items) {
      sum += (item['shipping_fee'] as num?)?.toDouble()
          ?? 32700;
    }
    return sum;
  }

  double get _total => _subtotal + _shippingFee;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(isVi ? 'Thanh toán' : 'Checkout'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, elevation: 0.5),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(isDark, isVi),
      bottomNavigationBar: _buildBottom(isDark, isVi));
  }

  Widget _buildBody(bool isDark, bool isVi) {
    return SingleChildScrollView(
      child: Column(children: [
        CheckoutAddressSection(
          address: _selectedAddr, isVi: isVi,
          isDark: isDark, onTap: _navigateToAddAddress),
        const SizedBox(height: 8),
        CheckoutProductsSection(
          items: widget.items, isDark: isDark),
        const SizedBox(height: 8),
        _shippingSection(isDark, isVi),
        const SizedBox(height: 8),
        _paymentMethodSection(isDark, isVi),
        const SizedBox(height: 8),
        CheckoutSummarySection(
          subtotal: _subtotal, shippingFee: _shippingFee,
          total: _total, isVi: isVi, isDark: isDark),
        const SizedBox(height: 8),
        _termsSection(isVi),
        const SizedBox(height: 16),
      ]));
  }

  /// Shipping method section.
  Widget _shippingSection(bool isDark, bool isVi) {
    return Container(
      width: double.infinity,
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isVi ? 'Phương thức vận chuyển'
                  : 'Shipping method',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const Spacer(),
              Text(isVi ? 'Xem tất cả >' : 'See all >',
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.green.shade200)),
              child: Row(children: [
                const Icon(Icons.check, size: 18,
                    color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(isVi ? 'Nhanh' : 'Fast',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(isVi ? 'Nhận hàng sau 3-5 ngày'
                        : 'Receive in 3-5 days',
                        style: TextStyle(fontSize: 12,
                            color: Colors.grey.shade600)),
                  ])),
                Text('${PriceFormatter.formatFull(
                    _shippingFee)}đ',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ])),
          ])));
  }

  /// Payment method section.
  Widget _paymentMethodSection(bool isDark, bool isVi) {
    return Container(
      width: double.infinity,
      color: isDark ? DarkColors.surface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(isVi ? 'Phương thức thanh toán'
                  : 'Payment method',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const Spacer(),
              Text(isVi ? 'Xem tất cả >' : 'See all >',
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.payments_outlined,
                    color: Colors.deepOrange, size: 20)),
              const SizedBox(width: 10),
              Text(isVi ? 'Thanh toán khi nhận hàng'
                  : 'Cash on delivery',
                  style: const TextStyle(fontSize: 13)),
              const Spacer(),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
            ]),
          ])));
  }

  /// Terms text.
  Widget _termsSection(bool isVi) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(text: TextSpan(
        style: TextStyle(fontSize: 12,
            color: Colors.grey.shade600),
        children: [
          TextSpan(text: isVi
              ? 'Nhấn "Đặt hàng" đồng nghĩa với việc bạn đồng ý tuân theo '
              : 'By pressing "Place Order" you agree to '),
          TextSpan(text: isVi
              ? 'Điều khoản Shopee'
              : 'Terms of Service',
              style: const TextStyle(color: Colors.blue)),
        ])));
  }

  /// Bottom bar with total + order button.
  Widget _buildBottom(bool isDark, bool isVi) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2))]),
      child: SafeArea(top: false, child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isVi ? 'Tổng cộng' : 'Total',
                style: TextStyle(fontSize: 12,
                    color: Colors.grey.shade500)),
            Text('${PriceFormatter.formatFull(_total)}đ',
                style: const TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ])),
        SizedBox(width: 140, child: ElevatedButton(
          onPressed: _placing ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8))),
          child: _placing
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(isVi ? 'Đặt hàng' : 'Place Order',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15)))),
      ])));
  }

  Future<void> _placeOrder() async {
    if (_selectedAddr == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read<AppProvider>()
              .locale.languageCode == 'vi'
              ? 'Vui lòng thêm địa chỉ giao hàng'
              : 'Please add a delivery address')));
      return;
    }
    setState(() => _placing = true);
    final body = {
      'address_id': _selectedAddr!['id'],
      'shipping_method': 'standard',
      'payment_method': 'cod',
      'note': '',
      'items': widget.items.map((i) {
        return <String, dynamic>{
          'product_id': i['product_id'] ?? i['id'],
          'product_name': i['product_name'] ?? i['name'],
          'product_image': i['product_image'] ?? '',
          'price': i['price'],
          'quantity': i['quantity'],
          'shop_id': i['shop_id'] ?? '',
          'shop_name': i['shop_name'] ?? '',
        };
      }).toList(),
    };
    final result = await _orderDS.placeOrder(body);
    if (mounted) {
      setState(() => _placing = false);
      if (result != null) {
        context.read<CartProvider>().fetchCart();
        context.read<AppProvider>().notifyOrderUpdate();
        final isVi = context.read<AppProvider>()
            .locale.languageCode == 'vi';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isVi
                ? '✅ Đặt hàng thành công!'
                : '✅ Order placed successfully!')));
        Navigator.pop(context, true);
      } else {
        final isVi = context.read<AppProvider>()
            .locale.languageCode == 'vi';
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isVi
                ? '❌ Đặt hàng thất bại'
                : '❌ Failed to place order')));
      }
    }
  }

  void _navigateToAddAddress() async {
    final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
            builder: (_) => const AddressPickerPage()));
    if (result == null) return;
    final areaParts = (result['area'] ?? '').toString()
        .split('\n');
    final addrData = <String, dynamic>{
      'receiver_name': result['name'] ?? '',
      'phone': result['phone'] ?? '',
      'province': result['province'] ?? '',
      'district': result['district'] ?? '',
      'ward': result['ward'] ?? '',
      'detail_address': result['street'] ?? '',
      'lat': result['lat'] ?? 0.0,
      'lng': result['lng'] ?? 0.0,
      'is_default': result['isDefault'] ?? false,
    };
    await _addrDS.create(addrData);
    _loadAddresses();
  }
}
