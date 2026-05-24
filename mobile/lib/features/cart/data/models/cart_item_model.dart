import '../../../../core/constants/api_constants.dart';
import '../../../home/data/models/product_option_group.dart';

class CartItemModel {
  /// Unique cart item ID.
  final String id;

  /// Product ID referenced by this cart item.
  final String productId;

  /// Product display name.
  final String productName;

  /// First product image URL (relative, needs baseUrl prefix).
  final String productImage;

  /// Unit price of the product.
  final double price;

  /// Quantity in cart.
  int quantity;

  /// Shop ID that sells this product.
  final String shopId;

  /// Shop display name.
  final String shopName;

  /// Seller's avatar URL.
  final String shopAvatar;

  /// Product variant option groups from the product.
  final List<ProductOptionGroup> productOptions;

  /// Creates a CartItemModel instance.
  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.shopId,
    required this.shopName,
    this.shopAvatar = '',
    this.productOptions = const [],
  });

  /// Creates from API JSON response.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      productImage: json['product_image'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] ?? 1,
      shopId: json['shop_id'] ?? '',
      shopName: json['shop_name'] ?? '',
      shopAvatar: ApiConstants.resolveImageUrl(json['shop_avatar'] ?? ''),
      productOptions: _parseOptions(json['product_options']),
    );
  }

  /// Parses product options from JSON.
  static List<ProductOptionGroup> _parseOptions(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProductOptionGroup.fromJson)
        .toList();
  }

  /// Whether this cart item's product has options.
  bool get hasOptions => productOptions.isNotEmpty;

  /// Total price for this line item.
  double get lineTotal => price * quantity;
}
