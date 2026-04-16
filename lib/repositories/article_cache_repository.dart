import 'package:sqflite/sqflite.dart';

import '../models/article.dart';
import '../services/database_helper.dart';

/// Cache bài viết vào bảng `articles_cache` để xem offline.
class ArticleCacheRepository {
  ArticleCacheRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  /// Lưu/cập nhật danh sách bài (transaction batch).
  Future<void> cacheAll(List<Article> articles) async {
    if (articles.isEmpty) return;
    final db = await _db.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final batch = db.batch();
    for (final a in articles) {
      batch.insert(
        'articles_cache',
        {
          'id': a.id,
          'title': a.title,
          'body': a.body,
          'image_url': a.imageUrl,
          'published_at': a.publishedAt.toIso8601String(),
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Đọc cache - dùng khi mất mạng.
  Future<List<Article>> loadCache() async {
    final db = await _db.database;
    final rows = await db.query('articles_cache', orderBy: 'id', limit: 100);
    return rows
        .map((r) => Article(
              id: r['id'] as int,
              title: r['title'] as String,
              body: r['body'] as String,
              imageUrl: r['image_url'] as String,
              publishedAt: DateTime.parse(r['published_at'] as String),
            ))
        .toList();
  }
}
