import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

/// Repository lưu/đọc danh sách bài viết yêu thích vào SharedPreferences.
/// Provider không cần biết dữ liệu được lưu ở đâu — chỉ cần gọi load/save.
class FavoritesRepository {
  static const String _storageKey = 'favorites_v1';

  Future<List<Article>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_articleFromStorage)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<Article> articles) async {
    final prefs = await SharedPreferences.getInstance();
    final data = articles.map(_articleToStorage).toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Map<String, dynamic> _articleToStorage(Article a) => {
        'id': a.id,
        'title': a.title,
        'body': a.body,
        'imageUrl': a.imageUrl,
        'publishedAt': a.publishedAt.toIso8601String(),
      };

  Article _articleFromStorage(Map<String, dynamic> json) => Article(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ??
            'https://picsum.photos/seed/${json['id']}/600/400',
        publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
