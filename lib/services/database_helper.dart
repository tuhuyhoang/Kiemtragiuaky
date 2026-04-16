import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Singleton quản lý database SQLite (sqflite).
///
/// 4 bảng:
///   users           - tài khoản (id, name, email, password_hash, created_at)
///   favorites       - bài yêu thích theo user
///   articles_cache  - cache bài viết để xem offline
///   search_history  - lịch sử tìm kiếm theo user
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'news_app.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE favorites (
            user_id INTEGER NOT NULL,
            article_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            image_url TEXT NOT NULL,
            published_at TEXT NOT NULL,
            added_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, article_id),
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE articles_cache (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            image_url TEXT NOT NULL,
            published_at TEXT NOT NULL,
            cached_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE search_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            query TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_search_user_time ON search_history(user_id, created_at DESC)',
        );
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
