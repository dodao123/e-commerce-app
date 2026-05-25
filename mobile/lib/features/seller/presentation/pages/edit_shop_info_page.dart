import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/shop_remote_datasource.dart';
import 'address_picker_page.dart';

/// Page to edit shop information.
class EditShopInfoPage extends StatefulWidget {
  /// The current shop data.
  final Map<String, dynamic> shopData;

  /// Creates the EditShopInfoPage widget.
  const EditShopInfoPage({super.key, required this.shopData});

  @override
  State<EditShopInfoPage> createState() => _EditShopInfoPageState();
}

class _EditShopInfoPageState extends State<EditShopInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _identityCtrl;
  
  String _addressDisplay = '';
  Map<String, dynamic> _addressData = {};
  
  final _datasource = ShopRemoteDatasource();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _shopNameCtrl = TextEditingController(text: widget.shopData['shop_name']);
    _emailCtrl = TextEditingController(text: widget.shopData['email']);
    _phoneCtrl = TextEditingController(text: widget.shopData['phone']);
    _identityCtrl = TextEditingController(text: widget.shopData['national_id_number']);
    
    _addressDisplay = widget.shopData['detail_address'] ?? '';
    _addressData = {
      'province': widget.shopData['province'] ?? '',
      'district': widget.shopData['district'] ?? '',
      'ward': widget.shopData['ward'] ?? '',
      'street': widget.shopData['detail_address'] ?? '',
      'lat': (widget.shopData['lat'] ?? widget.shopData['latitude'] ?? 0.0).toDouble(),
      'lng': (widget.shopData['lng'] ?? widget.shopData['longitude'] ?? 0.0).toDouble(),
    };
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _identityCtrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    if (_addressDisplay.isEmpty) {
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi
            ? 'Vui lòng thiết lập địa chỉ lấy hàng'
            : 'Please set up pickup address'),
        backgroundColor: Colors.red.shade400));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final shopData = {
        'shop_name': _shopNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'national_id_number': _identityCtrl.text.trim(),
        'province': _addressData['province'] ?? '',
        'district': _addressData['district'] ?? '',
        'ward': _addressData['ward'] ?? '',
        'detail_address': _addressData['street'] ?? '',
        'lat': _addressData['lat'] ?? 0.0,
        'lng': _addressData['lng'] ?? 0.0,
        'category': widget.shopData['category'] ?? 'other',
      };

      final token = await TokenManager().getToken();
      if (token == null) throw Exception('Not authenticated');

      final shopId = widget.shopData['id'].toString();
      await _datasource.updateShop(
          token: token, shopId: shopId, shopData: shopData);

      if (!mounted) return;
      
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi ? 'Đã cập nhật thông tin Cửa hàng' : 'Shop info updated'),
        backgroundColor: Colors.green));
        
      Navigator.pop(context, true); // Return true to trigger refresh
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red.shade400));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    
    return Scaffold(
      backgroundColor: IndieFolkTheme.neutral(isDark),
      appBar: AppBar(
        backgroundColor: IndieFolkTheme.neutral(isDark),
        elevation: 0,
        title: Text(isVi ? 'Chỉnh sửa Cửa hàng' : 'Edit Shop Info',
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 18)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)))),
          if (!_isSaving)
            TextButton(
              onPressed: _save,
              child: Text(isVi ? 'Lưu' : 'Save',
                  style: TextStyle(
                      color: IndieFolkTheme.primary(isDark),
                      fontWeight: FontWeight.bold))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            const SizedBox(height: 20),
            _field(isVi ? 'CCCD/CMND' : 'National ID',
                isVi ? 'Nhập số CCCD/CMND' : 'Enter national ID',
                Icons.badge_outlined, isDark,
                controller: _identityCtrl,
                keyboard: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? (isVi ? 'Vui lòng nhập CCCD' : 'ID required')
                    : null),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String hint,
      IconData icon, bool isDark,
      {int? maxLen, TextInputType? keyboard,
       TextEditingController? controller,
       String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary : Colors.black87)),
          const Text(' *', style: TextStyle(color: AppColors.primary)),
        ]),
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
        Row(children: [
          Text(label, style: TextStyle(fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary : Colors.black87)),
          const Text(' *', style: TextStyle(color: AppColors.primary)),
        ]),
        const SizedBox(height: 8),
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
}
