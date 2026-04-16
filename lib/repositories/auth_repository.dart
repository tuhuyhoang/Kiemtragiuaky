import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

/// Repository quản lý danh sách user đăng ký + session đang đăng nhập.
/// Dữ liệu lưu vào SharedPreferences, không có backend thật.
class AuthRepository {
  static const String _usersKey = 'users_v1';
  static const String _sessionKey = 'session_email_v1';

  /// Lấy danh sách tất cả user đã đăng ký.
  Future<List<AppUser>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(AppUser.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  /// Đăng ký user mới. Trả về user vừa tạo. Ném Exception nếu email đã tồn tại.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final users = await _loadAll();
    final normalizedEmail = email.trim().toLowerCase();

    if (users.any((u) => u.email.toLowerCase() == normalizedEmail)) {
      throw Exception('Email đã được đăng ký.');
    }

    final user = AppUser(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    users.add(user);
    await _saveAll(users);
    await _setSession(user.email);
    return user;
  }

  /// Đăng nhập. Trả về user hoặc ném Exception.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final users = await _loadAll();
    final normalizedEmail = email.trim().toLowerCase();

    AppUser? found;
    for (final u in users) {
      if (u.email.toLowerCase() == normalizedEmail) {
        found = u;
        break;
      }
    }

    if (found == null) {
      throw Exception('Email chưa được đăng ký.');
    }
    if (found.password != password) {
      throw Exception('Sai mật khẩu.');
    }

    await _setSession(found.email);
    return found;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Trả về user đang đăng nhập (đọc từ session), null nếu chưa.
  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null || email.isEmpty) return null;

    final users = await _loadAll();
    for (final u in users) {
      if (u.email == email) return u;
    }
    return null;
  }

  Future<void> _setSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }
}
