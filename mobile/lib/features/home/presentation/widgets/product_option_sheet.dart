import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../data/models/product_model.dart';
import 'option_sheet_header.dart';
import 'option_sheet_body.dart';

/// Shows product option selection bottom sheet.
/// Returns map of {groupName: selectedValue, '_quantity': '1'}
/// or null if dismissed.
Future<Map<String, String>?> showProductOptionSheet(
  BuildContext context,
  ProductModel product,
) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OptionSheet(product: product),
  );
}

class _OptionSheet extends StatefulWidget {
  final ProductModel product;
  const _OptionSheet({required this.product});

  @override
  State<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<_OptionSheet> {
  final Map<String, String> _selections = {};
  int _quantity = 1;

  bool get _allSelected => widget.product.options
      .every((g) => _selections.containsKey(g.name));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: IndieFolkTheme.neutral(isDark),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _dragHandle(isDark),
        OptionSheetHeader(
            product: widget.product,
            isDark: isDark, isVi: isVi),
        const Divider(height: 1),
        Flexible(child: OptionSheetBody(
          product: widget.product,
          selections: _selections,
          quantity: _quantity,
          isDark: isDark, isVi: isVi,
          onSelect: (g, v) => setState(() =>
              _selections[g] = v),
          onQuantityChanged: (q) =>
              setState(() => _quantity = q),
        )),
        _confirmButton(isDark, isVi),
      ]),
    );
  }

  Widget _dragHandle(bool isDark) => Center(child: Container(
    margin: const EdgeInsets.only(top: 12, bottom: 8),
    width: 40, height: 4,
    decoration: BoxDecoration(
      color: IndieFolkTheme.secondary(isDark).withOpacity(0.4),
      borderRadius: BorderRadius.circular(2)),
  ));

  Widget _confirmButton(bool isDark, bool isVi) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: _allSelected ? _onConfirm : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: IndieFolkTheme.tertiary(isDark),
            disabledBackgroundColor:
                IndieFolkTheme.secondary(isDark).withOpacity(0.3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
          child: Text(
            _allSelected
                ? (isVi ? 'Xác nhận' : 'Confirm')
                : (isVi ? 'Vui lòng chọn' : 'Select options'),
            style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.w600,
                color: IndieFolkTheme.onPrimary(isDark))),
        ),
      ),
    ),
  );

  void _onConfirm() => Navigator.pop(context, {
    ..._selections,
    '_quantity': _quantity.toString(),
  });
}
