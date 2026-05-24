/// Represents a product option group with selectable values.
/// Example: name="Color", values=["Red", "Blue", "Black"].
class ProductOptionGroup {
  /// The option group label (e.g. "Color", "Size").
  final String name;

  /// The list of selectable values for this option.
  final List<String> values;

  /// Creates a ProductOptionGroup instance.
  const ProductOptionGroup({
    required this.name,
    required this.values,
  });

  /// Creates from JSON map.
  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    return ProductOptionGroup(
      name: json['name'] ?? '',
      values: (json['values'] as List<dynamic>?)
              ?.map((v) => v.toString())
              .toList() ??
          [],
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'values': values,
      };
}
