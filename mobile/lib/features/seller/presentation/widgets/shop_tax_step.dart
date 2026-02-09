import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Step 3: Tax information for seller.
/// Collects tax code, business type, and invoice preference.
class ShopTaxStep extends StatefulWidget {
  /// Creates the ShopTaxStep widget.
  const ShopTaxStep({super.key});

  @override
  State<ShopTaxStep> createState() => _ShopTaxStepState();
}

class _ShopTaxStepState extends State<ShopTaxStep> {
  bool _needInvoice = false;
  String _businessType = 'individual';

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    return ListView(
      padding: const EdgeInsets.all(20), children: [
        Text(isVi ? 'Thông tin thuế' : 'Tax Information',
            style: TextStyle(fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkColors.textPrimary
                    : Colors.black87)),
        const SizedBox(height: 4),
        Text(isVi ? 'Cung cấp thông tin thuế để xuất hóa đơn'
            : 'Provide tax info for invoicing',
            style: TextStyle(fontSize: 12,
                color: isDark ? DarkColors.textSecondary
                    : Colors.grey.shade500)),
        const SizedBox(height: 20),
        _dropdown(isDark, isVi),
        const SizedBox(height: 16),
        _textField(isVi ? 'Mã số thuế' : 'Tax Code',
            Icons.receipt_outlined, isDark),
        const SizedBox(height: 16),
        _textField(
            isVi ? 'Tên doanh nghiệp (nếu có)'
                : 'Business name (optional)',
            Icons.business_outlined, isDark),
        const SizedBox(height: 20),
        _invoiceToggle(isDark, isVi),
      ]);
  }

  Widget _textField(String hint, IconData icon, bool isDark) {
    return TextField(
      style: TextStyle(color: isDark
          ? DarkColors.textPrimary : Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark
            ? DarkColors.textSecondary
            : Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 20, color: isDark
            ? DarkColors.textSecondary
            : Colors.grey.shade500),
        filled: isDark, fillColor: DarkColors.surface,
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
            horizontal: 16, vertical: 14)));
  }

  Widget _dropdown(bool isDark, bool isVi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : null,
        border: Border.all(color: isDark
            ? DarkColors.textSecondary.withOpacity(0.3)
            : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true, value: _businessType,
          dropdownColor: isDark ? DarkColors.surface
              : Colors.white,
          style: TextStyle(fontSize: 14, color: isDark
              ? DarkColors.textPrimary : Colors.black87),
          items: [
            DropdownMenuItem(value: 'individual',
                child: Text(isVi ? 'Cá nhân'
                    : 'Individual')),
            DropdownMenuItem(value: 'business',
                child: Text(isVi ? 'Doanh nghiệp'
                    : 'Business')),
            DropdownMenuItem(value: 'household',
                child: Text(isVi ? 'Hộ kinh doanh'
                    : 'Household business')),
          ],
          onChanged: (v) {
            if (v != null) setState(() => _businessType = v);
          })));
  }

  Widget _invoiceToggle(bool isDark, bool isVi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : null,
        border: Border.all(color: isDark
            ? DarkColors.textSecondary.withOpacity(0.3)
            : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Icon(Icons.description_outlined, size: 22,
            color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(
            isVi ? 'Cần xuất hóa đơn VAT'
                : 'Need VAT Invoice',
            style: TextStyle(fontSize: 14, color: isDark
                ? DarkColors.textPrimary
                : Colors.black87))),
        Switch.adaptive(
          value: _needInvoice,
          activeColor: AppColors.primary,
          onChanged: (v) =>
              setState(() => _needInvoice = v)),
      ]));
  }
}
