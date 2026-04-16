import '../models/article.dart';
import '../services/database_helper.dart';

/// Repository quản lý favorites trong SQLite.
/// Bảng `favorites` (composite PK: user_id + article_id).
class FavoritesRepository {
  FavoritesRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  /// Tải toàn bộ favorites của user (sắp xếp theo thời gian thêm gần nhất).
  Future<List<Article>> load(int userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'added_at DESC',
    );
    return rows.map(_toArticle).toList();
  }

  Future<void> add(int userId, Article article) async {
    final db = await _db.database;
    await db.insert('favorites', {
      'user_id': userId,
      'article_id': article.id,
      'title': article.title,
      'body': article.body,
      'image_url': article.imageUrl,
      'published_at': article.publishedAt.toIso8601String(),
      'added_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> remove(int userId, int articleId) async {
    final db = await _db.database;
    await db.delete(
      'favorites',
      where: 'user_id = ? AND article_id = ?',
      whereArgs: [userId, articleId],
    );
  }

  Article _toArticle(Map<String, dynamic> row) => Article(
        id: row['article_id'] as int,
        title: row['title'] as String,
        body: row['body'] as String,
        imageUrl: row['image_url'] as String,
        publishedAt: DateTime.parse(row['published_at'] as String),
      );
}
