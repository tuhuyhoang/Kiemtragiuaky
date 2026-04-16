import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../repositories/favorites_repository.dart';

/// Provider quản lý favorites - dữ liệu lưu trên Firestore (per-user).
/// Dùng stream realtime nên thay đổi từ thiết bị khác cũng tự cập nhật.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FavoritesRepository? repository})
      : _repository = repository ?? FavoritesRepository();

  final FavoritesRepository _repository;

  String? _uid;
  StreamSubscription<List<Article>>? _sub;

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

  /// Bind theo user uid - gọi khi user login. uid = null khi logout.
  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _sub?.cancel();
    _favorites.clear();

    if (uid == null || uid.isEmpty) {
      notifyListeners();
      return;
    }

    _sub = _repository.watch(uid).listen((list) {
      _favorites
        ..clear()
        ..addEntries(list.map((a) => MapEntry(a.id, a)));
      notifyListeners();
    });
  }

  Future<void> toggle(Article article) async {
    final uid = _uid;
    if (uid == null) return;
    if (_favorites.containsKey(article.id)) {
      await _repository.remove(uid, article.id);
    } else {
      await _repository.add(uid, article);
    }
    // Stream sẽ tự update _favorites
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
    _sub?.cancel();
    super.dispose();
  }
}
