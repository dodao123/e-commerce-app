import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Horizontal scrollable filter tabs for product categories.
class ProductFilterTabs extends StatelessWidget {
  /// List of filter tab labels.
  final List<String> tabs;

  /// Index of the currently selected tab.
  final int selectedIndex;

  /// Callback when a tab is tapped.
  final ValueChanged<int> onTabSelected;

  /// Creates ProductFilterTabs with given tabs and selection state.
  const ProductFilterTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return _buildTab(tabs[index], isSelected, () => onTabSelected(index));
        },
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? null
              : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
