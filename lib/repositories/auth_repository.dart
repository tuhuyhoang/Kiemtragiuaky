import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/database_helper.dart';

/// Repository quản lý authentication qua SQLite.
/// - Bảng `users` lưu account.
/// - Mật khẩu được hash SHA-256 (không lưu plaintext).
/// - Session (user đang đăng nhập) lưu trong SharedPreferences (key: current_user_id).
class AuthRepository {
  AuthRepository({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  static const String _sessionKey = 'current_user_id';

  String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  /// Đăng ký user mới. Ném Exception nếu email đã tồn tại.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = await _db.database;
    final normalizedEmail = email.trim().toLowerCase();

    final exists = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (exists.isNotEmpty) {
      throw Exception('Email đã được đăng ký.');
    }

    final id = await db.insert('users', {
      'name': name.trim(),
      'email': normalizedEmail,
      'password_hash': _hash(password),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    final user = AppUser(id: id, name: name.trim(), email: normalizedEmail);
    await _setSession(id);
    return user;
  }

  /// Đăng nhập. Ném Exception nếu sai.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final db = await _db.database;
    final normalizedEmail = email.trim().toLowerCase();

    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Email chưa được đăng ký.');
    }

    final row = rows.first;
    if (row['password_hash'] != _hash(password)) {
      throw Exception('Sai mật khẩu.');
    }

    final user = AppUser.fromMap(row);
    await _setSession(user.id);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Trả về user đang đăng nhập (đọc từ session).
  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionKey);
    if (id == null) return null;

    final db = await _db.database;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> _setSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userId);
  }
}
