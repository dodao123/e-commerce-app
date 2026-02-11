/// Formats price in VND with abbreviations.
/// 10000 → 10K, 100000 → 100K, 1000000 → 1tr.
class PriceFormatter {
  PriceFormatter._();

  /// Formats a numeric price to abbreviated VND string.
  static String format(double price) {
    if (price >= 1000000) {
      final millions = price / 1000000;
      if (millions == millions.truncateToDouble()) {
        return '${millions.toInt()}tr';
      }
      return '${millions.toStringAsFixed(1)}tr';
    }
    if (price >= 1000) {
      final thousands = price / 1000;
      if (thousands == thousands.truncateToDouble()) {
        return '${thousands.toInt()}K';
      }
      return '${thousands.toStringAsFixed(1)}K';
    }
    return price.toInt().toString();
  }
}
