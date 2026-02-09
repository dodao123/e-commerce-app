import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/address_form_section.dart';
import '../widgets/address_map_section.dart';
import '../widgets/address_options_section.dart';
import '../widgets/area_picker_sheet.dart';

/// Address picker page with form, map, and options.
/// Requests GPS permission and auto-detects user location.
class AddressPickerPage extends StatefulWidget {
  /// Creates the AddressPickerPage widget.
  const AddressPickerPage({super.key});

  @override
  State<AddressPickerPage> createState() =>
      _AddressPickerPageState();
}

class _AddressPickerPageState
    extends State<AddressPickerPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _mapCtrl = MapController();

  LatLng _center = const LatLng(21.0285, 105.8542);
  String _areaText = '';
  bool _isDefault = false;
  bool _isPickup = true;
  int _typeIndex = 0;
  bool _locating = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _streetCtrl.addListener(_streetListener);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _detectCurrentLocation();
    });
  }

  void _streetListener() => _onStreetChanged(_streetCtrl.text);

  @override
  void dispose() {
    _streetCtrl.removeListener(_streetListener);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _debounce?.cancel();
    _mapCtrl.dispose();
    super.dispose();
  }

  /// Request permission and get current GPS position.
  Future<void> _detectCurrentLocation() async {
    try {
      final enabled =
          await Geolocator.isLocationServiceEnabled();
      if (!enabled) { _finishLocating(); return; }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _finishLocating(); return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final newCenter = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() => _center = newCenter);
        try { _mapCtrl.move(newCenter, 17); } catch (_) {}
        await _reverseGeocode(newCenter);
      }
    } catch (_) {}
    _finishLocating();
  }

  void _finishLocating() {
    if (mounted) setState(() => _locating = false);
  }

  /// Opens cascading area picker and moves map.
  Future<void> _openAreaPicker() async {
    final result = await AreaPickerSheet.show(context);
    if (result == null || !mounted) return;
    final province = result['province'] ?? '';
    final district = result['district'] ?? '';
    final ward = result['ward'] ?? '';
    final display = [province, district, ward]
        .where((s) => s.isNotEmpty).join(', ');
    setState(() => _areaText = display);
    // Strip VN admin prefixes for Nominatim
    final p = _stripPrefix(province);
    final d = _stripPrefix(district);
    final w = _stripPrefix(ward);
    // Fallback: full → district+province → province
    final queries = <String>[
      [w, d, p].where((s) => s.isNotEmpty).join(', '),
      [d, p].where((s) => s.isNotEmpty).join(', '),
      p,
    ];
    for (final q in queries) {
      if (q.isEmpty) continue;
      debugPrint('[AreaPicker] Trying: $q');
      final ok = await _searchAndMoveMap(q);
      if (ok) return;
    }
  }

  /// Strip Vietnamese admin prefixes for geocoding.
  String _stripPrefix(String name) {
    const prefixes = [
      'Thành phố ', 'Tỉnh ', 'Quận ', 'Huyện ',
      'Thị xã ', 'Phường ', 'Xã ', 'Thị trấn ',
    ];
    for (final p in prefixes) {
      if (name.startsWith(p)) return name.substring(p.length);
    }
    return name;
  }

  /// Search address on street field change (debounced).
  void _onStreetChanged(String street) {
    _debounce?.cancel();
    if (street.length < 5 || _areaText.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 800),
        () {
      // Combine street with stripped area
      final parts = _areaText.split(', ')
          .map(_stripPrefix)
          .where((s) => s.isNotEmpty).join(', ');
      final query = '$street, $parts';
      debugPrint('[Street] Searching: $query');
      _searchAndMoveMap(query);
    });
  }

  /// Nominatim search. Returns true if a result was found.
  Future<bool> _searchAndMoveMap(String query) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?format=json&q=${Uri.encodeComponent(query)}'
          '&countrycodes=vn&limit=1&accept-language=vi');
      final res = await http.get(url,
          headers: {'User-Agent': 'DeliveryApp/1.0'});
      debugPrint('[Map] Status: ${res.statusCode}');
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        debugPrint('[Map] Results: ${list.length}');
        if (list.isNotEmpty && mounted) {
          final lat = double.parse(list[0]['lat']);
          final lon = double.parse(list[0]['lon']);
          final pos = LatLng(lat, lon);
          setState(() => _center = pos);
          try { _mapCtrl.move(pos, 15); } catch (_) {}
          return true;
        }
      }
    } catch (e) {
      debugPrint('[Map] Error: $e');
    }
    return false;
  }

  /// Debounced reverse geocode on map move.
  void _onMapMoved(LatLng newCenter) {
    _center = newCenter;
    _debounce?.cancel();
    _debounce = Timer(
        const Duration(milliseconds: 600),
        () => _reverseGeocode(newCenter));
  }

  Future<void> _reverseGeocode(LatLng pos) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?format=json&lat=${pos.latitude}'
          '&lon=${pos.longitude}&accept-language=vi');
      final res = await http.get(url,
          headers: {'User-Agent': 'DeliveryApp/1.0'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final addr =
            data['address'] as Map<String, dynamic>?;
        if (addr != null && mounted) {
          setState(() {
            _areaText = _fmtArea(addr);
            _streetCtrl.text = _fmtStreet(addr);
          });
        }
      }
    } catch (_) {}
  }

  String _fmtArea(Map<String, dynamic> a) => <String>[
    a['city'] ?? a['town'] ?? a['state'] ?? '',
    a['suburb'] ?? a['county'] ?? a['district'] ?? '',
    a['quarter'] ?? a['village'] ?? '',
  ].where((s) => s.isNotEmpty).join('\n');

  String _fmtStreet(Map<String, dynamic> a) => <String>[
    a['house_number'] ?? '', a['road'] ?? '',
  ].where((s) => s.isNotEmpty).join(', ');

  void _submit() {
    Navigator.pop(context, {
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'area': _areaText,
      'street': _streetCtrl.text,
      'lat': _center.latitude,
      'lng': _center.longitude,
      'isDefault': _isDefault,
      'isPickup': _isPickup,
      'type': _typeIndex == 0 ? 'office' : 'home',
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background
          : const Color(0xFFF5F5F5),
      appBar: _appBar(isDark, isVi),
      body: _body(isDark, isVi),
      bottomNavigationBar: _submitBtn(isDark, isVi),
    );
  }

  PreferredSizeWidget _appBar(bool isDark, bool isVi) {
    return AppBar(
      backgroundColor: isDark
          ? DarkColors.surface : Colors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87, size: 20)),
      title: Text(isVi ? 'Địa chỉ mới' : 'New Address',
          style: TextStyle(
              color: isDark ? DarkColors.textPrimary
                  : Colors.black87,
              fontSize: 17, fontWeight: FontWeight.w600)));
  }

  Widget _body(bool isDark, bool isVi) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [
        AddressFormSection(
          nameController: _nameCtrl,
          phoneController: _phoneCtrl,
          streetController: _streetCtrl,
          areaText: _areaText,
          isDark: isDark, isVi: isVi,
          onAreaTap: _openAreaPicker),
        const SizedBox(height: 16),
        Stack(children: [
          AddressMapSection(
            mapController: _mapCtrl,
            center: _center,
            isDark: isDark,
            onMapMoved: _onMapMoved),
          if (_locating) _locatingBadge(isDark, isVi),
        ]),
        const SizedBox(height: 16),
        AddressOptionsSection(
          isDefault: _isDefault, isPickup: _isPickup,
          typeIndex: _typeIndex, isDark: isDark, isVi: isVi,
          onDefaultChanged: (v) =>
              setState(() => _isDefault = v),
          onPickupChanged: (v) =>
              setState(() => _isPickup = v),
          onTypeChanged: (v) =>
              setState(() => _typeIndex = v)),
      ]));
  }

  Widget _locatingBadge(bool isDark, bool isVi) {
    return Positioned(top: 8, right: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6)]),
        child: Row(
          mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(width: 14, height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary)),
            const SizedBox(width: 6),
            Text(isVi ? 'Đang định vị...' : 'Locating...',
                style: TextStyle(fontSize: 11,
                    color: isDark ? DarkColors.textPrimary
                        : Colors.black87)),
          ])));
  }

  Widget _submitBtn(bool isDark, bool isVi) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0),
          child: Text(
              isVi ? 'HOÀN THÀNH' : 'COMPLETE',
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1))))));
  }
}
