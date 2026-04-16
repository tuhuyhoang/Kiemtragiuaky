import 'package:flutter/foundation.dart';

import '../repositories/search_history_repository.dart';

/// Provider quản lý lịch sử tìm kiếm của user trong SQLite.
class SearchHistoryProvider extends ChangeNotifier {
  SearchHistoryProvider({SearchHistoryRepository? repository})
      : _repository = repository ?? SearchHistoryRepository();

  final SearchHistoryRepository _repository;

  int? _userId;
  List<String> _recent = [];

  List<String> get recent => _recent;

  Future<void> bindUser(int? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    _recent = [];
    if (userId == null) {
      notifyListeners();
      return;
    }
    _recent = await _repository.recent(userId);
    notifyListeners();
  }

  Future<void> add(String query) async {
    final uid = _userId;
    if (uid == null) return;
    await _repository.add(uid, query);
    _recent = await _repository.recent(uid);
    notifyListeners();
  }

  Future<void> clear() async {
    final uid = _userId;
    if (uid == null) return;
    await _repository.clear(uid);
    _recent = [];
    notifyListeners();
  }
}
