import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// App bar for the cart page with back button, title, and edit icon.
class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Total item count displayed in the title.
  final int itemCount;

  /// Whether current locale is Vietnamese.
  final bool isVi;

  /// Whether dark theme is active.
  final bool isDark;

  /// Creates the CartAppBar.
  const CartAppBar({
    super.key,
    required this.itemCount,
    required this.isVi,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final title = isVi
        ? 'Giỏ hàng ($itemCount)'
        : 'Cart ($itemCount)';

    return AppBar(
      backgroundColor:
          isDark ? DarkColors.background : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(title, style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.edit_outlined,
              color: isDark
                  ? DarkColors.textSecondary : Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }
}
