import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shown when the search returns 0 results.
class SearchEmptyView extends StatelessWidget {
  /// Localized language selector flag.
  final bool isVi;

  /// Creates a SearchEmptyView.
  const SearchEmptyView({super.key, required this.isVi});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              size: 80,
              color: isDark ? Colors.white24 : Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(isVi ? 'Không tìm thấy sản phẩm' : 'No products found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text(
              isVi
                  ? 'Hãy thử tìm kiếm bằng từ khóa khác'
                  : 'Try checking spelling or use a different keyword',
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? DarkColors.textSecondary : Colors.grey.shade600)),
        ],
      ),
    );
  }
}

/// Shown on network or unexpected server failure.
class SearchErrorView extends StatelessWidget {
  /// Localized language selector flag.
  final bool isVi;

  /// Callback to execute when retrying search.
  final VoidCallback onRetry;

  /// Creates a SearchErrorView.
  const SearchErrorView({super.key, required this.isVi, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(isVi ? 'Lỗi kết nối máy chủ' : 'Server Connection Error',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
                isVi
                    ? 'Không thể tải kết quả. Vui lòng thử lại.'
                    : 'Could not fetch search results. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(isVi ? 'Thử lại' : 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the user enters the search page but has not typed.
class SearchIdleView extends StatelessWidget {
  /// Localized language selector flag.
  final bool isVi;

  /// Callback when a popular search suggestion is tapped.
  final ValueChanged<String> onSuggestionTap;

  /// Creates a SearchIdleView.
  const SearchIdleView({
    super.key,
    required this.isVi,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popular = isVi
        ? ['Bánh mì', 'Cà phê', 'Trà sữa', 'Điện thoại', 'Áo khoác']
        : ['Pizza', 'Coffee', 'Burger', 'iPhone', 'T-Shirt'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isVi ? 'Tìm kiếm phổ biến' : 'Popular Searches',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: popular
                .map(
                  (term) => GestureDetector(
                    onTap: () => onSuggestionTap(term),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: isDark ? DarkColors.surface : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(term, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
