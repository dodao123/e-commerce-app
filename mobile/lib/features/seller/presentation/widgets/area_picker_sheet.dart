import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/vietnam_address_service.dart';

/// Bottom sheet for cascading province → district → ward.
/// Returns a Map with 'province', 'district', 'ward' names.
class AreaPickerSheet extends StatefulWidget {
  /// Creates the AreaPickerSheet widget.
  const AreaPickerSheet({super.key});

  /// Shows the bottom sheet and returns selected area data.
  static Future<Map<String, String>?> show(BuildContext ctx) {
    return showModalBottomSheet<Map<String, String>>(
      context: ctx, isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AreaPickerSheet());
  }

  @override
  State<AreaPickerSheet> createState() =>
      _AreaPickerSheetState();
}

class _AreaPickerSheetState extends State<AreaPickerSheet> {
  int _level = 0; // 0=province, 1=district, 2=ward
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String _provinceName = '';
  int _provinceCode = 0;
  String _districtName = '';

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _loading = true);
    final data =
        await VietnamAddressService.fetchProvinces();
    if (mounted) {
      setState(() { _items = data; _loading = false; });
    }
  }

  Future<void> _loadDistricts(
      Map<String, dynamic> prov) async {
    _provinceName = prov['name'] as String;
    _provinceCode = prov['code'] as int;
    setState(() { _loading = true; _level = 1; });
    final data = await VietnamAddressService
        .fetchDistricts(_provinceCode);
    if (mounted) {
      setState(() { _items = data; _loading = false; });
    }
  }

  Future<void> _loadWards(
      Map<String, dynamic> dist) async {
    _districtName = dist['name'] as String;
    final code = dist['code'] as int;
    setState(() { _loading = true; _level = 2; });
    final data = await VietnamAddressService.fetchWards(code);
    if (mounted) {
      setState(() { _items = data; _loading = false; });
    }
  }

  void _selectWard(Map<String, dynamic> ward) {
    Navigator.pop(context, {
      'province': _provinceName,
      'district': _districtName,
      'ward': ward['name'] as String,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final title = _level == 0
        ? (isVi ? 'Chọn Tỉnh/Thành phố'
            : 'Select Province')
        : _level == 1
            ? (isVi ? 'Chọn Quận/Huyện'
                : 'Select District')
            : (isVi ? 'Chọn Phường/Xã' : 'Select Ward');
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : Colors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16))),
      child: Column(children: [
        _header(title, isDark),
        if (_loading) const Expanded(child: Center(
            child: CircularProgressIndicator(
                color: AppColors.primary)))
        else Expanded(child: _list(isDark)),
      ]));
  }

  Widget _header(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: [
        if (_level > 0) IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18,
              color: isDark ? DarkColors.textPrimary
                  : Colors.black87),
          onPressed: () {
            if (_level == 2) {
              _loadDistricts({
                'name': _provinceName,
                'code': _provinceCode});
            } else {
              _loadProvinces();
            }
            setState(() =>
                _level = _level > 0 ? _level - 1 : 0);
          }),
        Expanded(child: Text(title, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87))),
        IconButton(
          icon: Icon(Icons.close, size: 20,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade600),
          onPressed: () => Navigator.pop(context)),
      ]));
  }

  Widget _list(bool isDark) {
    return ListView.separated(
      itemCount: _items.length,
      separatorBuilder: (_, __) => Divider(height: 1,
          color: isDark
              ? DarkColors.textSecondary.withOpacity(0.15)
              : null),
      itemBuilder: (_, i) {
        final item = _items[i];
        return ListTile(
          title: Text(item['name'] as String,
              style: TextStyle(fontSize: 14,
                  color: isDark ? DarkColors.textPrimary
                      : Colors.black87)),
          trailing: Icon(Icons.chevron_right, size: 18,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade400),
          onTap: () {
            if (_level == 0) _loadDistricts(item);
            else if (_level == 1) _loadWards(item);
            else _selectWard(item);
          });
      });
  }
}
