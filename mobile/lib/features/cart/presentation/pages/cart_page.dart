import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/cart_app_bar.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_item_list.dart';

/// Shopping cart page showing items grouped by shop.
/// Supports dark/light theme and vi/en language.
class CartPage extends StatefulWidget {
  /// Creates the CartPage.
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final isVi = context.watch<AppProvider>()
        .locale.languageCode == 'vi';
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? DarkColors.background : AppColors.background,
      appBar: CartAppBar(
          itemCount: cart.totalCount, isVi: isVi, isDark: isDark),
      body: cart.isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primary))
          : cart.items.isEmpty
              ? _buildEmpty(isVi)
              : CartItemList(items: cart.items, isDark: isDark),
      bottomNavigationBar: cart.items.isNotEmpty
          ? CartBottomBar(
              isDark: isDark, isVi: isVi)
          : null,
    );
  }

  Widget _buildEmpty(bool isVi) {
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.shopping_cart_outlined,
            size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(isVi ? 'Giỏ hàng trống' : 'Cart is empty',
            style: const TextStyle(
                fontSize: 16, color: Colors.grey)),
      ],
    ));
  }
}
