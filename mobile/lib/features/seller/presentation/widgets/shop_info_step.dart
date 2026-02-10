import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../pages/address_picker_page.dart';

/// Step 1: Shop basic information form.
/// Fields: Shop name, Pickup address, Email, Phone number.
class ShopInfoStep extends StatefulWidget {
  /// Creates the ShopInfoStep widget.
  const ShopInfoStep({super.key});

  @override
  ShopInfoStepState createState() => ShopInfoStepState();
}

class ShopInfoStepState extends State<ShopInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _addressDisplay = '';
  Map<String, dynamic> _addressData = {};

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Returns the form data as a map for the API request.
  Map<String, dynamic> getData() => {
    'shop_name': _shopNameCtrl.text.trim(),
    'email': _emailCtrl.text.trim(),
    'phone': _phoneCtrl.text.trim(),
    'province': _addressData['province'] ?? '',
    'district': _addressData['district'] ?? '',
    'ward': _addressData['ward'] ?? '',
    'detail_address': _addressData['street'] ?? '',
  };

  /// Validates all fields in step 1.
  bool validate() {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (_addressDisplay.isEmpty) {
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
            ? 'Vui lòng thiết lập địa chỉ lấy hàng'
            : 'Please set up pickup address'),
        backgroundColor: Colors.red.shade400));
      return false;
    }
    return formValid;
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
        context, MaterialPageRoute(
            builder: (_) => const AddressPickerPage()));
    if (result != null && mounted) {
      setState(() {
        _addressData = result;
        _addressDisplay = [
          result['area'] ?? '',
          result['street'] ?? '',
        ].where((s) => s.toString().isNotEmpty).join(', ');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20), children: [
          _field(isVi ? 'Tên Shop' : 'Shop Name',
              isVi ? 'Nhập tên Shop của bạn' : 'Enter shop name',
              Icons.storefront_outlined, isDark,
              controller: _shopNameCtrl,
              maxLen: 30,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isVi ? 'Vui lòng nhập tên Shop' : 'Shop name required')
                  : null),
          const SizedBox(height: 20),
          _tapField(
              isVi ? 'Địa chỉ lấy hàng' : 'Pickup Address',
              _addressDisplay,
              isVi ? 'Thiết lập' : 'Set up',
              Icons.location_on_outlined, isDark,
              onTap: _openAddressPicker),
          const SizedBox(height: 20),
          _field('Email', isVi ? 'Nhập email' : 'Enter email',
              Icons.email_outlined, isDark,
              controller: _emailCtrl,
              keyboard: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isVi ? 'Vui lòng nhập email' : 'Email required')
                  : null),
          const SizedBox(height: 20),
          _field(isVi ? 'Số điện thoại' : 'Phone',
              isVi ? 'Nhập số điện thoại' : 'Enter phone',
              Icons.phone_outlined, isDark,
              controller: _phoneCtrl,
              keyboard: TextInputType.phone,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? (isVi ? 'Vui lòng nhập SĐT' : 'Phone required')
                  : null),
        ]));
  }

  Widget _field(String label, String hint,
      IconData icon, bool isDark,
      {int? maxLen, TextInputType? keyboard,
       TextEditingController? controller,
       String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark),
        const SizedBox(height: 8),
        TextFormField(maxLength: maxLen, keyboardType: keyboard,
          controller: controller,
          validator: validator,
          style: TextStyle(color: isDark
              ? DarkColors.textPrimary : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark
                ? DarkColors.textSecondary
                : Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 20,
                color: isDark ? DarkColors.textSecondary
                    : Colors.grey.shade500),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark
                    ? DarkColors.textSecondary.withOpacity(0.3)
                    : Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            filled: isDark, fillColor: DarkColors.surface)),
      ]);
  }

  Widget _tapField(String label, String value, String hint,
      IconData icon, bool isDark, {VoidCallback? onTap}) {
    final hasVal = value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark), const SizedBox(height: 8),
        InkWell(onTap: onTap ?? () {},
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? DarkColors.surface : null,
              border: Border.all(color: isDark
                  ? DarkColors.textSecondary.withOpacity(0.3)
                  : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(icon, size: 20, color: isDark
                  ? DarkColors.textSecondary
                  : Colors.grey.shade500),
              const SizedBox(width: 12),
              Expanded(child: Text(hasVal ? value : hint,
                  style: TextStyle(fontSize: 14,
                      color: hasVal
                          ? (isDark ? DarkColors.textPrimary
                              : Colors.black87)
                          : (isDark ? DarkColors.textSecondary
                              : Colors.grey.shade400)))),
              Icon(Icons.chevron_right, color: isDark
                  ? DarkColors.textSecondary
                  : Colors.grey.shade400),
            ]))),
      ]);
  }

  Widget _label(String text, bool isDark) {
    return Row(children: [
      Text(text, style: TextStyle(fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? DarkColors.textPrimary
              : Colors.black87)),
      const Text(' *',
          style: TextStyle(color: AppColors.primary)),
    ]);
  }
}
