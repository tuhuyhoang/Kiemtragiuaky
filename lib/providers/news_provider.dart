import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../repositories/article_cache_repository.dart';
import '../repositories/article_repository.dart';

enum NewsStatus { idle, loading, success, error }

/// ViewModel cho danh sách tin tức.
/// - Tải từ ArticleRepository (API).
/// - Cache vào Firestore qua ArticleCacheRepository.
/// - Khi mất mạng: thử đọc từ cache.
class NewsProvider extends ChangeNotifier {
  NewsProvider({
    ArticleRepository? repository,
    ArticleCacheRepository? cache,
  })  : _repository = repository ?? ArticleRepository(),
        _cache = cache ?? ArticleCacheRepository();

  final ArticleRepository _repository;
  final ArticleCacheRepository _cache;

  List<Article> _articles = [];
  NewsStatus _status = NewsStatus.idle;
  String? _errorMessage;
  String _query = '';
  Timer? _debounce;
  bool _fromCache = false;

  List<Article> get articles => _articles;
  NewsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  bool get isFromCache => _fromCache;

  /// Lọc theo từ khóa - tìm trong cả tiêu đề và nội dung.
  List<Article> get filteredArticles {
    if (_query.trim().isEmpty) return _articles;
    final q = _query.toLowerCase();
    return _articles.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadArticles() async {
    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _articles = await _repository.getArticles();
      _status = NewsStatus.success;
      _fromCache = false;
      // Cache lên Firestore (background, không await để không chặn UI)
      _cache.cacheAll(_articles).catchError((_) {});
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      // Thử đọc cache khi mất mạng
      final cached = await _cache.loadCache();
      if (cached.isNotEmpty) {
        _articles = cached;
        _fromCache = true;
        _status = NewsStatus.success;
        _errorMessage = '$_errorMessage (đang xem dữ liệu offline)';
      } else {
        _status = NewsStatus.error;
      }
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
