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

  /// Formats price as exact VND with dot separators.
  /// Example: 1532700 → "1.532.700"
  static String formatFull(double price) {
    final str = price.toInt().toString();
    final buffer = StringBuffer();
    final remainder = str.length % 3;
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (i - remainder) % 3 == 0
          && remainder != 0 || i > 0
          && remainder == 0 && i % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
