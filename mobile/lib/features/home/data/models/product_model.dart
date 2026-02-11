import '../../../../core/constants/api_constants.dart';

/// Product model representing an item in the store.
class ProductModel {
  /// Unique product identifier.
  final String id;

  /// Display name of the product (English).
  final String name;

  /// Display name of the product (Vietnamese).
  final String nameVi;

  /// Price in VND.
  final double price;

  /// URL or asset path for the product image.
  final String imageUrl;

  /// Whether imageUrl is a network URL (true) or asset (false).
  final bool isNetworkImage;

  /// List of detail image URLs for product gallery.
  final List<String> imageDetail;

  /// Product category for filtering.
  final String category;

  /// Product description text (English).
  final String description;

  /// Product description text (Vietnamese).
  final String descriptionVi;

  /// Average star rating (0-5).
  final double rating;

  /// Number of customer reviews.
  final int reviewCount;

  /// Whether this product is marked as new.
  final bool isNew;

  /// Creates a ProductModel instance.
  const ProductModel({
    required this.id,
    required this.name,
    this.nameVi = '',
    required this.price,
    required this.imageUrl,
    this.isNetworkImage = false,
    this.imageDetail = const [],
    this.category = 'All',
    this.description = '',
    this.descriptionVi = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
  });

  /// Creates a ProductModel from API JSON response.
  factory ProductModel.fromApiJson(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>?) ?? [];
    final firstImage = images.isNotEmpty
        ? '${ApiConstants.baseUrl}/${images.first}'
        : '';

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: firstImage,
      isNetworkImage: firstImage.isNotEmpty,
      imageDetail: images
          .map((i) => '${ApiConstants.baseUrl}/$i')
          .toList(),
      category: json['category'] ?? 'All',
      description: json['description'] ?? '',
      isNew: json['condition'] == 'new',
    );
  }

  /// Returns localized product name based on language code.
  String localizedName(String languageCode) {
    if (languageCode == 'vi' && nameVi.isNotEmpty) return nameVi;
    return name;
  }

  /// Returns localized description based on language code.
  String localizedDescription(String languageCode) {
    if (languageCode == 'vi' && descriptionVi.isNotEmpty) {
      return descriptionVi;
    }
    return description;
  }
}
