import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'shop_identity_helpers.dart';
import 'country_picker_sheet.dart';
import 'country_data.dart';

/// Step 2: Identity verification — nationality and CCCD.
class ShopIdentityStep extends StatefulWidget {
  /// Creates the ShopIdentityStep widget.
  const ShopIdentityStep({super.key});

  @override
  ShopIdentityStepState createState() => ShopIdentityStepState();
}

class ShopIdentityStepState extends State<ShopIdentityStep> {
  /// Currently selected country.
  CountryItem _selectedCountry = commonCountries.first; // Default: Vietnam

  /// Controller for the national ID input.
  final _idController = TextEditingController();

  /// Returns the identity data as a map for the API request.
  Map<String, dynamic> getData() => {
    'nationality': _selectedCountry.name,
    'national_id_number': _idController.text.trim(),
  };

  /// Validates the identity fields.
  bool validate() => _idController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        IdentityHelpers.infoBanner(isDark, isVi),
        const SizedBox(height: 20),
        _nationalityField(isDark, isVi),
        Divider(height: 32, color: isDark
            ? DarkColors.textSecondary.withOpacity(0.2) : null),
        _nationalIdField(isDark, isVi),
      ],
    );
  }

  /// Nationality field that opens the country picker sheet.
  Widget _nationalityField(bool isDark, bool isVi) {
    return InkWell(
      onTap: () => _openCountryPicker(isVi),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Text(
            '${isVi ? "Quốc Tịch" : "Nationality"} *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary : Colors.black87)),
          const Spacer(),
          Text(_selectedCountry.flag,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(_selectedCountry.name,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? DarkColors.textPrimary : Colors.black87)),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, size: 18,
              color: isDark ? DarkColors.textSecondary
                  : Colors.grey.shade400),
        ])),
    );
  }

  /// Opens the country picker bottom sheet.
  Future<void> _openCountryPicker(bool isVi) async {
    final result = await CountryPickerSheet.show(
      context,
      selectedCode: _selectedCountry.code,
      isVi: isVi,
    );
    if (result != null) {
      setState(() => _selectedCountry = result);
    }
  }

  /// National ID (CCCD) input field.
  Widget _nationalIdField(bool isDark, bool isVi) {
    return TextField(
      controller: _idController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: isVi ? 'Số Căn Cước Công Dân (CCCD) *'
            : 'National ID Number *',
        hintText: isVi ? 'Nhập số CCCD' : 'Enter ID number',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14)),
    );
  }
}
