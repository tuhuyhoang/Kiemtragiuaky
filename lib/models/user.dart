/// Model người dùng app, lưu cả thông tin Firebase Auth và profile từ Firestore.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
  });

  final String uid;
  final String name;
  final String email;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: (map['uid'] as String?) ?? '',
        name: (map['name'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
      );
}
