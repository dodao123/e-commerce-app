import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/shop_info_step.dart';
import '../widgets/shop_identity_step.dart';
import '../widgets/shop_tax_step.dart';

/// Multi-step shop registration page.
/// Steps: Shop Info → Identity → Tax.
class ShopRegistrationPage extends StatefulWidget {
  /// Creates the ShopRegistrationPage widget.
  const ShopRegistrationPage({super.key});

  @override
  State<ShopRegistrationPage> createState() =>
      _ShopRegistrationPageState();
}

class _ShopRegistrationPageState
    extends State<ShopRegistrationPage> {
  int _currentStep = 0;
  static const _lastStep = 2;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final labels = [
      isVi ? 'Thông tin\nShop' : 'Shop\nInfo',
      isVi ? 'Thông tin\nđịnh danh' : 'Identity\nInfo',
      isVi ? 'Thông tin\nthuế' : 'Tax\nInfo',
    ];
    final steps = const [
      ShopInfoStep(), ShopIdentityStep(), ShopTaxStep(),
    ];
    return Scaffold(
      backgroundColor: isDark
          ? DarkColors.background : Colors.white,
      appBar: _appBar(isDark, isVi, labels),
      body: Column(children: [
        _stepIndicator(isDark, labels),
        Expanded(child: steps[_currentStep]),
      ]),
      bottomNavigationBar: _bottomBtns(isDark, isVi),
    );
  }

  PreferredSizeWidget _appBar(
      bool isDark, bool isVi, List<String> labels) {
    return AppBar(
      backgroundColor: isDark
          ? DarkColors.surface : Colors.white,
      elevation: 0.5,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_ios_rounded,
            color: isDark ? DarkColors.textPrimary
                : Colors.black87, size: 20)),
      title: Text(
        labels[_currentStep].replaceAll('\n', ' '),
        style: TextStyle(
            color: isDark ? DarkColors.textPrimary
                : Colors.black87,
            fontSize: 17, fontWeight: FontWeight.w600)),
      actions: [
        TextButton(onPressed: _save,
          child: Text(isVi ? 'Lưu' : 'Save',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600))),
      ]);
  }

  Widget _stepIndicator(bool isDark, List<String> labels) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(children: List.generate(3,
          (i) => Expanded(child: _dot(i, isDark, labels)))));
  }

  Widget _dot(int i, bool isDark, List<String> labels) {
    final active = i == _currentStep;
    final done = i < _currentStep;
    final color = (active || done)
        ? AppColors.primary : (isDark
            ? DarkColors.textSecondary
            : Colors.grey.shade400);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        if (i > 0) Expanded(child: Container(height: 2,
            color: done ? color : (isDark
                ? DarkColors.textSecondary.withOpacity(0.3)
                : Colors.grey.shade300))),
        _circle(i, done, color),
        if (i < _lastStep) Expanded(child: Container(
            height: 2,
            color: active || done ? color : (isDark
                ? DarkColors.textSecondary.withOpacity(0.3)
                : Colors.grey.shade300))),
      ]),
      const SizedBox(height: 4),
      Text(labels[i], textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9, color: color,
              fontWeight: active
                  ? FontWeight.w600 : FontWeight.normal)),
    ]);
  }

  Widget _circle(int i, bool done, Color color) {
    return Container(width: 28, height: 28,
      decoration: BoxDecoration(shape: BoxShape.circle,
        color: done ? color : Colors.transparent,
        border: Border.all(color: color, width: 2)),
      child: done ? const Icon(Icons.check, size: 16,
          color: Colors.white)
        : Center(child: Text('${i + 1}',
            style: TextStyle(fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold))));
  }

  Widget _bottomBtns(bool isDark, bool isVi) {
    return SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: _back,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            side: BorderSide(color: isDark
                ? DarkColors.textSecondary
                : Colors.grey.shade300)),
          child: Text(isVi ? 'Quay lại' : 'Back',
              style: TextStyle(color: isDark
                  ? DarkColors.textPrimary
                  : Colors.black54)))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(
          onPressed: _currentStep < _lastStep ? _next : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
          child: Text(
              _currentStep < _lastStep
                  ? (isVi ? 'Tiếp theo' : 'Next')
                  : (isVi ? 'Hoàn tất' : 'Complete'),
              style: const TextStyle(
                  fontWeight: FontWeight.w600)))),
      ])));
  }

  void _next() {
    if (_currentStep < _lastStep) {
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) setState(() => _currentStep--);
    else Navigator.pop(context);
  }

  void _save() {
    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<AppProvider>()
                .locale.languageCode == 'vi'
            ? 'Thông tin Shop đã được lưu!'
            : 'Shop info saved!')));
  }
}
