import 'package:flutter/material.dart';
import '../data/datasources/search_datasource.dart';
import '../../home/data/models/product_model.dart';

/// Represents the visual states of the search workflow.
enum SearchStatus {
  /// The user hasn't typed anything yet.
  idle,

  /// Loading results from the network.
  loading,

  /// Found products matching the search criteria.
  success,

  /// The query returned zero matches.
  empty,

  /// Network or server error occurred.
  error
}

/// Manages state and logic for hybrid product searching.
class SearchProvider extends ChangeNotifier {
  final SearchDatasource _datasource = SearchDatasource();
  SearchStatus _status = SearchStatus.idle;
  List<ProductModel> _results = [];
  String _lastQuery = '';
  int _exactCount = 0;

  /// The current state of the search operation.
  SearchStatus get status => _status;

  /// Merged list: keyword matches at top, semantic below.
  List<ProductModel> get results => _results;

  /// The query string used for the active search request.
  String get lastQuery => _lastQuery;

  /// How many products at the top matched by exact keyword.
  int get exactCount => _exactCount;

  /// Whether there are semantic (AI) results beyond keyword matches.
  bool get hasSemanticResults => _results.length > _exactCount;

  /// Executes hybrid search: keyword first, semantic fill.
  Future<void> executeSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _status = SearchStatus.idle;
      _results = [];
      _exactCount = 0;
      notifyListeners();
      return;
    }

    _lastQuery = cleanQuery;
    _status = SearchStatus.loading;
    notifyListeners();

    try {
      final response = await _datasource.search(
        query: cleanQuery,
        limit: 35,
      );
      _results = response.products;
      _exactCount = response.exactCount;
      _status = _results.isEmpty
          ? SearchStatus.empty
          : SearchStatus.success;
    } catch (e) {
      debugPrint('[SearchProvider] Error: $e');
      _status = SearchStatus.error;
    }
    notifyListeners();
  }

  /// Retries search using the cached lastQuery.
  Future<void> retrySearch() async {
    await executeSearch(_lastQuery);
  }
}
