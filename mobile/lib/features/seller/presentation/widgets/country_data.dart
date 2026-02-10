import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Country data model for the nationality picker.
class CountryItem {
  /// Country display name.
  final String name;

  /// Country flag emoji.
  final String flag;

  /// Country ISO code.
  final String code;

  /// Creates a CountryItem.
  const CountryItem(this.name, this.flag, this.code);
}

/// List of commonly used countries for nationality selection.
const List<CountryItem> commonCountries = [
  CountryItem('Việt Nam', '🇻🇳', 'VN'),
  CountryItem('United States', '🇺🇸', 'US'),
  CountryItem('Japan', '🇯🇵', 'JP'),
  CountryItem('South Korea', '🇰🇷', 'KR'),
  CountryItem('China', '🇨🇳', 'CN'),
  CountryItem('Thailand', '🇹🇭', 'TH'),
  CountryItem('Singapore', '🇸🇬', 'SG'),
  CountryItem('Malaysia', '🇲🇾', 'MY'),
  CountryItem('Indonesia', '🇮🇩', 'ID'),
  CountryItem('Philippines', '🇵🇭', 'PH'),
  CountryItem('India', '🇮🇳', 'IN'),
  CountryItem('Australia', '🇦🇺', 'AU'),
  CountryItem('United Kingdom', '🇬🇧', 'GB'),
  CountryItem('France', '🇫🇷', 'FR'),
  CountryItem('Germany', '🇩🇪', 'DE'),
  CountryItem('Canada', '🇨🇦', 'CA'),
  CountryItem('Taiwan', '🇹🇼', 'TW'),
  CountryItem('Cambodia', '🇰🇭', 'KH'),
  CountryItem('Laos', '🇱🇦', 'LA'),
  CountryItem('Myanmar', '🇲🇲', 'MM'),
];
