import 'package:flutter/material.dart';
import '../../../../core/theme/indie_folk_theme.dart';
import '../../../home/data/models/product_option_group.dart';

/// Single option group tile with name input and value chips.
class OptionGroupTile extends StatefulWidget {
  final ProductOptionGroup group;
  final bool isDark;
  final bool isVi;
  final void Function(String) onNameChanged;
  final void Function(List<String>) onValuesChanged;
  final VoidCallback onRemove;

  const OptionGroupTile({
    super.key,
    required this.group,
    required this.isDark,
    required this.isVi,
    required this.onNameChanged,
    required this.onValuesChanged,
    required this.onRemove,
  });

  @override
  State<OptionGroupTile> createState() => _OptionGroupTileState();
}

class _OptionGroupTileState extends State<OptionGroupTile> {
  late final TextEditingController _nameCtrl;
  final _valueCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: IndieFolkTheme.secondary(isDark).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _nameRow(isDark),
          const SizedBox(height: 8),
          _valueChips(isDark),
          const SizedBox(height: 8),
          _addValueRow(isDark),
        ],
      ),
    );
  }

  Widget _nameRow(bool isDark) => Row(children: [
        Expanded(
          child: TextField(
            controller: _nameCtrl,
            onChanged: widget.onNameChanged,
            style: TextStyle(
              fontSize: 14,
              color: IndieFolkTheme.primary(isDark),
            ),
            decoration: InputDecoration(
              hintText: widget.isVi
                  ? 'Tên nhóm (VD: Màu sắc)'
                  : 'Group name (e.g. Color)',
              hintStyle: TextStyle(
                color: IndieFolkTheme.secondary(isDark),
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onRemove,
          child: Icon(Icons.delete_outline,
              color: Colors.red.shade400, size: 20),
        ),
      ]);

  Widget _valueChips(bool isDark) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: widget.group.values.asMap().entries.map((e) {
          return Chip(
            label: Text(e.value,
                style: TextStyle(
                  fontSize: 13,
                  color: IndieFolkTheme.primary(isDark))),
            deleteIcon: Icon(Icons.close, size: 16,
                color: IndieFolkTheme.secondary(isDark)),
            onDeleted: () => _removeValue(e.key),
            backgroundColor: IndieFolkTheme.neutral(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(
                color: IndieFolkTheme.secondary(isDark)
                    .withOpacity(0.3)),
            ),
          );
        }).toList(),
      );

  Widget _addValueRow(bool isDark) => Row(children: [
        Expanded(
          child: TextField(
            controller: _valueCtrl,
            style: TextStyle(
              fontSize: 13,
              color: IndieFolkTheme.primary(isDark)),
            decoration: InputDecoration(
              hintText: widget.isVi
                  ? 'Nhập giá trị...'
                  : 'Enter value...',
              hintStyle: TextStyle(
                color: IndieFolkTheme.secondary(isDark),
                fontSize: 13),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: IndieFolkTheme.secondary(isDark)
                      .withOpacity(0.3)),
              ),
            ),
            onSubmitted: (_) => _addValue(),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _addValue,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: IndieFolkTheme.tertiary(isDark),
              borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.add, size: 18,
                color: IndieFolkTheme.onPrimary(isDark)),
          ),
        ),
      ]);

  void _addValue() {
    final text = _valueCtrl.text.trim();
    if (text.isEmpty) return;
    widget.onValuesChanged([...widget.group.values, text]);
    _valueCtrl.clear();
  }

  void _removeValue(int index) {
    final updated = List<String>.from(widget.group.values)
      ..removeAt(index);
    widget.onValuesChanged(updated);
  }
}
