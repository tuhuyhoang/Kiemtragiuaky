/// Model người dùng - lưu trong bảng `users` SQLite.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final int id;
  final String name;
  final String email;

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int,
        name: (map['name'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
      );
}
