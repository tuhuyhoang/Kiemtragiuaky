import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../repositories/favorites_repository.dart';

/// Provider quản lý favorites - dữ liệu lưu trên SQLite (per-user).
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FavoritesRepository? repository})
      : _repository = repository ?? FavoritesRepository();

  final FavoritesRepository _repository;

  int? _userId;
  final Map<int, Article> _favorites = {};
  String _query = '';
  Timer? _debounce;

  int get count => _favorites.length;
  String get query => _query;
  List<Article> get favorites => _favorites.values.toList();

  /// Tìm trong tiêu đề + nội dung (case-insensitive).
  List<Article> get filteredFavorites {
    if (_query.trim().isEmpty) return favorites;
    final q = _query.toLowerCase();
    return favorites.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
    }).toList();
  }

  bool isFavorite(Article article) => _favorites.containsKey(article.id);

  /// Bind theo user - gọi khi user login. userId = null khi logout.
  Future<void> bindUser(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _favorites.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    final list = await _repository.load(userId);
    _favorites
      ..clear()
      ..addEntries(list.map((a) => MapEntry(a.id, a)));
    notifyListeners();
  }

  Future<void> toggle(Article article) async {
    final uid = _userId;
    if (uid == null) return;
    if (_favorites.containsKey(article.id)) {
      _favorites.remove(article.id);
      await _repository.remove(uid, article.id);
    } else {
      _favorites[article.id] = article;
      await _repository.add(uid, article);
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

  void clearQuery() {
    _debounce?.cancel();
    _query = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
