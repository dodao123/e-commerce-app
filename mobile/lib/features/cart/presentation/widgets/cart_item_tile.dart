import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../data/models/cart_item_model.dart';

/// Single cart item row with image, name, price, and qty controls.
class CartItemTile extends StatelessWidget {
  /// The cart item to display.
  final CartItemModel item;

  /// Whether dark theme is active.
  final bool isDark;

  /// Creates the CartItemTile.
  const CartItemTile({
    super.key, required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final selected = cart.isSelected(item.id);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        // Selection checkbox
        GestureDetector(
          onTap: () => cart.toggleItem(item.id),
          child: Icon(
            selected
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 22,
            color: selected
                ? AppColors.primary : Colors.grey.shade400)),
        const SizedBox(width: 10),
        // Product image
        _buildImage(),
        const SizedBox(width: 12),
        // Name + Price
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.productName, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(PriceFormatter.format(item.price),
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white : Colors.black)),
          ],
        )),
        const SizedBox(width: 8),
        // Quantity controls
        _buildQuantityControls(context.read<CartProvider>()),
      ]),
    );
  }

  Widget _buildImage() {
    final imgUrl = item.productImage.isNotEmpty
        ? '${ApiConstants.baseUrl}/${item.productImage}'
        : '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(width: 70, height: 70,
        child: imgUrl.isNotEmpty
            ? Image.network(imgUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _imagePlaceholder())
            : _imagePlaceholder()),
    );
  }

  Widget _imagePlaceholder() {
    return Container(color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined,
            color: Colors.grey));
  }

  Widget _buildQuantityControls(CartProvider cart) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _qtyButton(Icons.remove,
            () => item.quantity > 1
                ? cart.updateQuantity(item.id, item.quantity - 1)
                : cart.removeItem(item.id)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${item.quantity}',
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        _qtyButton(Icons.add,
            () => cart.updateQuantity(
                item.id, item.quantity + 1)),
      ]),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16,
            color: AppColors.primary)));
  }
}
