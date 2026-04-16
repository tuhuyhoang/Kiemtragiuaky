import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article.dart';

/// Repository lưu favorites trên Firestore.
/// Cấu trúc: users/{uid}/favorites/{articleId}
/// Mỗi user có collection favorites riêng - không chung với người khác.
class FavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  /// Tải toàn bộ favorites của user (sắp xếp theo thời gian thêm gần nhất).
  Future<List<Article>> load(String uid) async {
    if (uid.isEmpty) return [];
    final snap = await _col(uid).orderBy('addedAt', descending: true).get();
    return snap.docs.map((d) => Article.fromMap(d.data())).toList();
  }

  /// Stream realtime - UI tự động cập nhật khi thêm/xóa favorite.
  Stream<List<Article>> watch(String uid) {
    if (uid.isEmpty) return Stream.value(const []);
    return _col(uid)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Article.fromMap(d.data())).toList());
  }

  Future<void> add(String uid, Article article) async {
    if (uid.isEmpty) return;
    await _col(uid).doc(article.id.toString()).set({
      ...article.toMap(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> remove(String uid, int articleId) async {
    if (uid.isEmpty) return;
    await _col(uid).doc(articleId.toString()).delete();
  }
}
