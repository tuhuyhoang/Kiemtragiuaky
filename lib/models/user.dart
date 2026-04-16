/// Model đơn giản cho người dùng đăng ký trên app.
/// Mật khẩu lưu plaintext trong SharedPreferences - đây là demo bài tập,
/// không phải production. Trong thực tế cần hash bằng bcrypt/argon2.
class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: (json['name'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        password: (json['password'] as String?) ?? '',
      );
}
