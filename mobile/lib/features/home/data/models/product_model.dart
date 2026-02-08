/// Product model representing an item in the store.
class ProductModel {
  /// Unique product identifier.
  final String id;

  /// Display name of the product (English).
  final String name;

  /// Display name of the product (Vietnamese).
  final String nameVi;

  /// Price in USD.
  final double price;

  /// URL or asset path for the product image.
  final String imageUrl;

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
    this.imageDetail = const [],
    this.category = 'All',
    this.description = '',
    this.descriptionVi = '',
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isNew = false,
  });

  /// Returns localized product name based on language code.
  String localizedName(String languageCode) {
    if (languageCode == 'vi' && nameVi.isNotEmpty) return nameVi;
    return name;
  }

  /// Returns localized description based on language code.
  String localizedDescription(String languageCode) {
    if (languageCode == 'vi' && descriptionVi.isNotEmpty) return descriptionVi;
    return description;
  }
}
