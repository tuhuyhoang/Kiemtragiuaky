import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/search_history_repository.dart';

/// Provider quản lý lịch sử tìm kiếm của user.
class SearchHistoryProvider extends ChangeNotifier {
  SearchHistoryProvider({SearchHistoryRepository? repository})
      : _repository = repository ?? SearchHistoryRepository();

  final SearchHistoryRepository _repository;

  String? _uid;
  StreamSubscription<List<String>>? _sub;
  List<String> _recent = [];

  List<String> get recent => _recent;

  void bindUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _sub?.cancel();
    _recent = [];

    if (uid == null || uid.isEmpty) {
      notifyListeners();
      return;
    }

    _sub = _repository.watchRecent(uid).listen((list) {
      _recent = list;
      notifyListeners();
    });
  }

  Future<void> add(String query) async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.add(uid, query);
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;
    await _repository.clear(uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
