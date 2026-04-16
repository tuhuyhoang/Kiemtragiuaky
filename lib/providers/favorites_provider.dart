import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../repositories/favorites_repository.dart';

/// Provider quản lý danh sách bài yêu thích.
/// Dữ liệu được persist vào SharedPreferences qua FavoritesRepository,
/// nên vẫn còn khi người dùng tắt app và mở lại.
///
/// Tìm kiếm trong cả tiêu đề lẫn nội dung, có debounce 300ms.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FavoritesRepository? repository})
      : _repository = repository ?? FavoritesRepository() {
    _loadFromStorage();
  }

  final FavoritesRepository _repository;

  final Map<int, Article> _favorites = {};
  String _query = '';
  bool _ready = false;
  Timer? _debounce;

  bool get isReady => _ready;
  int get count => _favorites.length;
  String get query => _query;
  bool get hasQuery => _query.trim().isNotEmpty;
  List<Article> get favorites => _favorites.values.toList();

  /// Trả về danh sách favorites đã lọc theo từ khóa.
  /// Tìm trong: tiêu đề + nội dung (case-insensitive).
  List<Article> get filteredFavorites {
    if (_query.trim().isEmpty) return favorites;
    final q = _query.toLowerCase();
    return favorites.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.body.toLowerCase().contains(q);
    }).toList();
  }

  bool isFavorite(Article article) => _favorites.containsKey(article.id);

  Future<void> toggle(Article article) async {
    if (_favorites.containsKey(article.id)) {
      _favorites.remove(article.id);
    } else {
      _favorites[article.id] = article;
    }
    notifyListeners();
    await _repository.save(_favorites.values.toList(growable: false));
  }

  /// Cập nhật từ khóa tìm với debounce 300ms để tránh rebuild khi đang gõ.
  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      notifyListeners();
    });
  }

  /// Xóa từ khóa ngay lập tức (không debounce).
  void clearQuery() {
    _debounce?.cancel();
    _query = '';
    notifyListeners();
  }

  Future<void> _loadFromStorage() async {
    final list = await _repository.load();
    _favorites
      ..clear()
      ..addEntries(list.map((a) => MapEntry(a.id, a)));
    _ready = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
