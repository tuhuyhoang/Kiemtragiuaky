import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

/// Repository quản lý authentication qua Firebase Auth + Firestore.
/// - Firebase Auth: lưu email + password (đã hash bởi Google).
/// - Firestore collection `users`: lưu profile (uid, name, email, createdAt).
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  /// Đăng ký tài khoản mới.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = AppUser(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
      );
      await _usersCol.doc(user.uid).set(user.toMap());
      // Cập nhật displayName trên Firebase Auth để tiện sau này
      await cred.user!.updateDisplayName(name.trim());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorVi(e));
    }
  }

  /// Đăng nhập.
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final doc = await _usersCol.doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      // Fallback nếu doc bị thiếu: tạo từ Firebase Auth user
      final fallback = AppUser(
        uid: uid,
        name: cred.user!.displayName ?? email.split('@').first,
        email: email.trim().toLowerCase(),
      );
      await _usersCol.doc(uid).set(fallback.toMap());
      return fallback;
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorVi(e));
    }
  }

  Future<void> logout() => _auth.signOut();

  /// Trả về user hiện tại (nếu còn session lưu trong Firebase Auth).
  Future<AppUser?> currentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    try {
      final doc = await _usersCol.doc(fbUser.uid).get();
      if (doc.exists) return AppUser.fromMap(doc.data()!);
    } catch (_) {}
    return AppUser(
      uid: fbUser.uid,
      name: fbUser.displayName ?? (fbUser.email ?? '').split('@').first,
      email: fbUser.email ?? '',
    );
  }

  /// Stream theo dõi auth state để Provider tự cập nhật.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String _authErrorVi(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email đã được đăng ký.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'user-not-found':
        return 'Email chưa được đăng ký.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Sai email hoặc mật khẩu.';
      case 'network-request-failed':
        return 'Không có kết nối mạng.';
      default:
        return e.message ?? 'Lỗi xác thực: ${e.code}';
    }
  }
}
