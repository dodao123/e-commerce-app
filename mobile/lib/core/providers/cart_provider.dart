import 'package:flutter/material.dart';
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/models/cart_item_model.dart';

/// Manages shopping cart state across the app.
/// Provides item list, total count, total price, and selection.
class CartProvider extends ChangeNotifier {
  final CartRemoteDatasource _datasource = CartRemoteDatasource();

  List<CartItemModel> _items = [];
  int _totalCount = 0;
  bool _isLoading = false;
  final Set<String> _selectedIds = {};

  /// All cart items.
  List<CartItemModel> get items => _items;

  /// Total quantity for badge display.
  int get totalCount => _totalCount;

  /// Whether cart is currently loading.
  bool get isLoading => _isLoading;

  /// Total price of ALL items in cart.
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Total price of SELECTED items only (for checkout).
  double get selectedTotalPrice => _items
      .where((i) => _selectedIds.contains(i.id))
      .fold(0, (sum, item) => sum + item.lineTotal);

  /// Whether a specific item is selected.
  bool isSelected(String itemId) =>
      _selectedIds.contains(itemId);

  /// Whether all items are currently selected.
  bool get isAllSelected =>
      _items.isNotEmpty &&
      _selectedIds.length == _items.length;

  /// Toggles selection of a single item.
  void toggleItem(String itemId) {
    if (_selectedIds.contains(itemId)) {
      _selectedIds.remove(itemId);
    } else {
      _selectedIds.add(itemId);
    }
    notifyListeners();
  }

  /// Toggles select-all / deselect-all.
  void toggleAll() {
    if (isAllSelected) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_items.map((i) => i.id));
    }
    notifyListeners();
  }

  /// Fetches cart badge count (lightweight, for app bar).
  Future<void> fetchCount() async {
    _totalCount = await _datasource.fetchCount();
    notifyListeners();
  }

  /// Fetches all cart items with product/shop details.
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    _items = await _datasource.fetchCart();
    _totalCount = _items.fold(
        0, (sum, item) => sum + item.quantity);
    // Auto-select all items on fetch
    _selectedIds
      ..clear()
      ..addAll(_items.map((i) => i.id));
    _isLoading = false;
    notifyListeners();
  }

  /// Adds a product to the cart and refreshes count.
  Future<bool> addToCart(String productId, int qty) async {
    final success = await _datasource.addItem(productId, qty);
    if (success) await fetchCount();
    return success;
  }

  /// Updates item quantity and refreshes the cart.
  Future<void> updateQuantity(String itemId, int qty) async {
    await _datasource.updateQuantity(itemId, qty);
    await fetchCart();
  }

  /// Removes an item from the cart.
  Future<void> removeItem(String itemId) async {
    _selectedIds.remove(itemId);
    await _datasource.removeItem(itemId);
    await fetchCart();
  }
}
