import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'country_data.dart';

/// Bottom sheet for selecting a country/nationality.
/// Shows a searchable list of countries with flags.
class CountryPickerSheet extends StatefulWidget {
  /// Currently selected country code.
  final String selectedCode;

  /// Whether to show Vietnamese labels.
  final bool isVi;

  /// Creates a CountryPickerSheet widget.
  const CountryPickerSheet({
    super.key,
    required this.selectedCode,
    required this.isVi,
  });

  /// Shows the picker and returns the selected country.
  static Future<CountryItem?> show(
    BuildContext context, {
    required String selectedCode,
    required bool isVi,
  }) {
    return showModalBottomSheet<CountryItem>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CountryPickerSheet(
        selectedCode: selectedCode, isVi: isVi),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  String _query = '';

  List<CountryItem> get _filtered => commonCountries
      .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(children: [
        _header(isDark),
        _searchBar(isDark),
        Expanded(child: _countryList(controller, isDark)),
      ]),
    );
  }

  Widget _header(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        widget.isVi ? 'Chọn quốc tịch' : 'Select Nationality',
        style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }

  Widget _searchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: widget.isVi ? 'Tìm quốc gia...' : 'Search country...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: isDark ? DarkColors.background : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 10))),
    );
  }

  Widget _countryList(ScrollController controller, bool isDark) {
    final items = _filtered;
    return ListView.builder(
      controller: controller,
      itemCount: items.length,
      itemBuilder: (_, i) => _countryTile(items[i], isDark),
    );
  }

  Widget _countryTile(CountryItem country, bool isDark) {
    final selected = country.code == widget.selectedCode;
    return ListTile(
      leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
      title: Text(country.name),
      trailing: selected
        ? const Icon(Icons.check_circle, color: AppColors.primary)
        : null,
      onTap: () => Navigator.pop(context, country),
    );
  }
}
