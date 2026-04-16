import '../services/database_helper.dart';

/// Lưu lịch sử tìm kiếm theo từng user trong bảng `search_history`.
class SearchHistoryRepository {
  SearchHistoryRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  /// Thêm 1 từ khóa - đồng thời xóa duplicate cũ để chỉ giữ bản mới nhất.
  Future<void> add(int userId, String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    final db = await _db.database;
    // Xóa duplicate (cùng user_id + query)
    await db.delete(
      'search_history',
      where: 'user_id = ? AND query = ?',
      whereArgs: [userId, q],
    );
    await db.insert('search_history', {
      'user_id': userId,
      'query': q,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Đọc N từ khóa gần nhất.
  Future<List<String>> recent(int userId, {int limit = 10}) async {
    final db = await _db.database;
    final rows = await db.query(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map((r) => r['query'] as String).toList();
  }

  Future<void> clear(int userId) async {
    final db = await _db.database;
    await db.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
