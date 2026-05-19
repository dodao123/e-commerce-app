import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../seller/presentation/pages/address_picker_page.dart';
import '../../data/datasources/shipper_datasource.dart';

/// Page for shippers to register/update their delivery profile.
class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _ds = ShipperDataSource();

  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  String _vehicleType = 'motorcycle';
  double _radius = 10.0;
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, dynamic>? _addressData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _ds.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _nameCtrl.text = profile['full_name'] ?? '';
          _idCtrl.text = profile['national_id'] ?? '';
          _vehicleType = profile['vehicle_type'] ?? 'motorcycle';
          _plateCtrl.text = profile['license_plate'] ?? '';
          _radius = (profile['operating_radius_km'] ?? 10.0).toDouble();
          if (profile['lat'] != null && profile['lng'] != null) {
            _addressData = {
              'lat': profile['lat'],
              'lng': profile['lng'],
              'province': profile['province'],
              'district': profile['district'],
              'ward': profile['ward'],
              'street': profile['detail_address'],
              'area': '${profile['district'] ?? ''}, ${profile['province'] ?? ''}',
            };
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading driver profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi khi tải dữ liệu: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await _ds.updateProfile({
        'full_name': _nameCtrl.text.trim(),
        'national_id': _idCtrl.text.trim(),
        'vehicle_type': _vehicleType,
        'license_plate': _plateCtrl.text.trim(),
        'operating_radius_km': _radius,
        'lat': _addressData?['lat'],
        'lng': _addressData?['lng'],
        'province': _addressData?['province'],
        'district': _addressData?['district'],
        'ward': _addressData?['ward'],
        'detail_address': _addressData?['street'],
      });

      if (!mounted) return;
      context.read<AppProvider>().notifyOrderUpdate();
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi ? 'Đã lưu hồ sơ' : 'Profile saved'),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final isVi = context.read<AppProvider>().locale.languageCode == 'vi';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isVi ? 'Lỗi khi lưu hồ sơ' : 'Failed to save profile'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return Scaffold(
      backgroundColor: isDark ? IndieFolkTheme.neutral(isDark) : AppColors.background,
      appBar: AppBar(
        title: Text(isVi ? 'Hồ Sơ Tài Xế' : 'Driver Profile'),
        backgroundColor: isDark ? IndieFolkTheme.surface(isDark) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionHeader(isVi ? 'Thông tin cá nhân' : 'Personal Info', Icons.person_outline, isDark),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: isVi ? 'Họ và tên' : 'Full Name',
                    controller: _nameCtrl,
                    icon: Icons.badge_outlined,
                    isDark: isDark,
                    validator: (v) => v!.isEmpty ? (isVi ? 'Vui lòng nhập tên' : 'Required') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: isVi ? 'Số CCCD' : 'National ID',
                    controller: _idCtrl,
                    icon: Icons.credit_card_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? (isVi ? 'Vui lòng nhập CCCD' : 'Required') : null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(isVi ? 'Phương tiện' : 'Vehicle Info', Icons.directions_bike_outlined, isDark),
                  const SizedBox(height: 16),
                  _buildVehicleDropdown(isDark, isVi),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: isVi ? 'Biển số xe' : 'License Plate',
                    controller: _plateCtrl,
                    icon: Icons.pin_outlined,
                    isDark: isDark,
                    validator: (v) => v!.isEmpty ? (isVi ? 'Vui lòng nhập biển số' : 'Required') : null,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader(isVi ? 'Phạm vi giao hàng' : 'Delivery Range', Icons.radar_outlined, isDark),
                  const SizedBox(height: 16),
                  _buildLocationPicker(isDark, isVi),
                  const SizedBox(height: 16),
                  _buildRadiusSlider(isDark, isVi),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IndieFolkTheme.primary(isDark),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? CircularProgressIndicator(color: IndieFolkTheme.onPrimary(isDark))
                          : Text(
                              isVi ? 'Lưu Hồ Sơ' : 'Save Profile',
                              style: IndieFolkTheme.body(isDark).copyWith(
                                color: IndieFolkTheme.onPrimary(isDark),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: IndieFolkTheme.tertiary(isDark)),
        const SizedBox(width: 8),
        Text(
          title,
          style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 22),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: IndieFolkTheme.body(isDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: IndieFolkTheme.label(isDark),
        prefixIcon: Icon(icon, color: IndieFolkTheme.secondary(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: IndieFolkTheme.surface(isDark),
      ),
    );
  }

  Widget _buildVehicleDropdown(bool isDark, bool isVi) {
    final items = {
      'motorcycle': isVi ? 'Xe máy' : 'Motorcycle',
      'car': isVi ? 'Ô tô con' : 'Car',
      'truck': isVi ? 'Xe tải' : 'Truck',
      'bicycle': isVi ? 'Xe đạp' : 'Bicycle',
    };

    return DropdownButtonFormField<String>(
      value: _vehicleType,
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: IndieFolkTheme.body(isDark))))
          .toList(),
      onChanged: (v) => setState(() => _vehicleType = v!),
      decoration: InputDecoration(
        labelText: isVi ? 'Loại phương tiện' : 'Vehicle Type',
        labelStyle: IndieFolkTheme.label(isDark),
        prefixIcon: Icon(Icons.two_wheeler, color: IndieFolkTheme.secondary(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: IndieFolkTheme.surface(isDark),
      ),
    );
  }

  Widget _buildLocationPicker(bool isDark, bool isVi) {
    final hasLoc = _addressData != null;
    final locText = hasLoc
        ? '${_addressData!['street']}\n${_addressData!['area']}'
        : (isVi ? 'Chọn vị trí hoạt động' : 'Select operating location');

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (_) => const AddressPickerPage()),
        );
        if (result != null && mounted) {
          setState(() => _addressData = result);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? IndieFolkTheme.surface(isDark) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasLoc ? IndieFolkTheme.primary(isDark) : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: IndieFolkTheme.primary(isDark)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locText,
                style: IndieFolkTheme.body(isDark).copyWith(
                  color: hasLoc ? IndieFolkTheme.primary(isDark) : IndieFolkTheme.secondary(isDark),
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.map, color: IndieFolkTheme.secondary(isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSlider(bool isDark, bool isVi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? IndieFolkTheme.surface(isDark) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isVi ? 'Bán kính tối đa' : 'Maximum radius', style: IndieFolkTheme.body(isDark)),
              Text(
                '${_radius.toStringAsFixed(1)} km',
                style: IndieFolkTheme.h1(isDark).copyWith(fontSize: 18),
              ),
            ],
          ),
          Slider(
            value: _radius,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            activeColor: IndieFolkTheme.tertiary(isDark),
            onChanged: (v) => setState(() => _radius = v),
          ),
        ],
      ),
    );
  }
}
