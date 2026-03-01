import '../../../../core/constants/api_constants.dart';

/// Product model representing an item in the store.
class ProductModel {
  final String id;
  final String shopId;
  final String name;
  final String nameVi;
  final double price;
  final String imageUrl;
  final bool isNetworkImage;
  final List<String> imageDetail;
  final String category;
  final String description;
  final String descriptionVi;
  final double rating;
  final int reviewCount;
  final bool isNew;
  final String shopName;
  final String shopProvince;

  /// Seller's avatar URL.
  final String shopAvatar;

  /// Base shipping fee for this product.
  final double baseShippingFee;

  /// Creates a ProductModel instance.
  const ProductModel({
    required this.id, this.shopId = '',
    required this.name, this.nameVi = '',
    required this.price, required this.imageUrl,
    this.isNetworkImage = false,
    this.imageDetail = const [], this.category = 'All',
    this.description = '', this.descriptionVi = '',
    this.rating = 0.0, this.reviewCount = 0,
    this.isNew = false,
    this.shopName = '', this.shopProvince = '',
    this.shopAvatar = '',
    this.baseShippingFee = 0,
  });

  /// Creates a ProductModel from public API JSON response.
  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>?) ?? [];
    final first = images.isNotEmpty
        ? '${ApiConstants.baseUrl}/${images.first}' : '';
    return ProductModel(
      id: json['id'] ?? '',
      shopId: json['shop_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: first, isNetworkImage: first.isNotEmpty,
      imageDetail: images
          .map((i) => '${ApiConstants.baseUrl}/$i').toList(),
      category: json['category'] ?? 'All',
      description: json['description'] ?? '',
      isNew: json['condition'] == 'new',
      shopName: json['shop_name'] ?? '',
      shopProvince: json['shop_province'] ?? '',
      shopAvatar: json['shop_avatar'] ?? '',
      baseShippingFee:
          (json['base_shipping_fee'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Returns localized product name.
  String localizedName(String lang) {
    if (lang == 'vi' && nameVi.isNotEmpty) return nameVi;
    return name;
  }

  /// Returns localized description.
  String localizedDescription(String lang) {
    if (lang == 'vi' && descriptionVi.isNotEmpty) return descriptionVi;
    return description;
  }
}
