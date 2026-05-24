import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/search_provider.dart';
import '../widgets/search_product_grid.dart';
import '../widgets/search_shimmer_grid.dart';
import '../widgets/search_status_views.dart';

/// The main search results view screen.
class SearchResultsPage extends StatefulWidget {
  /// Creates the SearchResultsPage screen.
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVi = context.watch<AppProvider>().locale.languageCode == 'vi';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? DarkColors.background : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(
            color: isDark ? DarkColors.textPrimary : Colors.black87),
        title: _buildSearchBox(isDark, isVi),
        actions: [const SizedBox(width: 16)],
      ),
      body: _buildBody(provider, isVi),
    );
  }

  Widget _buildBody(SearchProvider provider, bool isVi) {
    switch (provider.status) {
      case SearchStatus.idle:
        return SearchIdleView(
            isVi: isVi,
            onSuggestionTap: (term) {
              _searchCtrl.text = term;
              provider.executeSearch(term);
            });
      case SearchStatus.loading:
        return const SearchShimmerGrid();
      case SearchStatus.success:
        return _buildMergedResults(provider, isVi);
      case SearchStatus.empty:
        return SearchEmptyView(isVi: isVi);
      case SearchStatus.error:
        return SearchErrorView(isVi: isVi, onRetry: provider.retrySearch);
    }
  }

  Widget _buildMergedResults(SearchProvider provider, bool isVi) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exact = provider.exactCount;
    final all = provider.results;

    return CustomScrollView(slivers: [
      // Section header: keyword matches
      if (exact > 0)
        _sectionHeader(isDark, Icons.text_fields,
            '$exact ${isVi ? "kết quả chính xác" : "exact matches"}'),
      if (exact > 0)
        SliverToBoxAdapter(
            child: SearchProductGrid(
                products: all.sublist(0, exact), shrinkWrap: true)),
      // Divider + AI section
      if (provider.hasSemanticResults)
        _sectionHeader(isDark, Icons.auto_awesome,
            isVi ? 'Gợi ý tương tự từ AI' : 'AI suggestions'),
      if (provider.hasSemanticResults)
        SliverToBoxAdapter(
            child: SearchProductGrid(
                products: all.sublist(exact), shrinkWrap: true)),
      // If only semantic (no keyword matches)
      if (exact == 0)
        _sectionHeader(isDark, Icons.auto_awesome,
            '${all.length} ${isVi ? "gợi ý từ AI" : "AI suggestions"}'),
      if (exact == 0 && !provider.hasSemanticResults)
        SliverToBoxAdapter(
            child: SearchProductGrid(
                products: all, shrinkWrap: true)),
    ]);
  }

  SliverToBoxAdapter _sectionHeader(
      bool isDark, IconData icon, String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Row(children: [
          Icon(icon, size: 16,
              color: isDark ? Colors.white54 : Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.grey.shade600)),
        ]),
      ),
    );
  }

  Widget _buildSearchBox(bool isDark, bool isVi) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _focusNode,
        onSubmitted: (v) => context.read<SearchProvider>().executeSearch(v),
        textInputAction: TextInputAction.search,
        style: TextStyle(
            color: isDark ? DarkColors.textPrimary : Colors.black87,
            fontSize: 14),
        decoration: InputDecoration(
          hintText:
              isVi ? 'Tìm kiếm món ăn, sản phẩm...' : 'Search foods, products...',
          hintStyle: TextStyle(
              color: isDark ? DarkColors.textSecondary : Colors.grey.shade500,
              fontSize: 14),
          prefixIcon: Icon(Icons.search,
              color: isDark ? DarkColors.textSecondary : Colors.grey.shade600,
              size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    context.read<SearchProvider>().executeSearch('');
                  })
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (val) => setState(() {}),
      ),
    );
  }
}
