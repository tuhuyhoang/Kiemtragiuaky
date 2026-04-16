import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../repositories/article_repository.dart';

enum NewsStatus { idle, loading, success, error }

/// ViewModel (Controller) cho danh sách tin tức.
/// Dùng ArticleRepository làm data source (Clean Architecture).
class NewsProvider extends ChangeNotifier {
  NewsProvider({ArticleRepository? repository})
      : _repository = repository ?? ArticleRepository();

  final ArticleRepository _repository;

  List<Article> _articles = [];
  NewsStatus _status = NewsStatus.idle;
  String? _errorMessage;
  String _query = '';
  Timer? _debounce;

  List<Article> get articles => _articles;
  NewsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get query => _query;

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
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _status = NewsStatus.error;
    }
    notifyListeners();
  }

  /// Cập nhật từ khóa tìm kiếm có debounce 300ms để tránh rebuild quá nhiều khi gõ.
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
