import 'package:cloud_firestore/cloud_firestore.dart';

/// Lưu lịch sử tìm kiếm theo từng user.
/// Cấu trúc: users/{uid}/search_history/{auto-id}
class SearchHistoryRepository {
  SearchHistoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('search_history');

  /// Thêm 1 từ khóa - đồng thời xóa duplicate cũ để chỉ giữ bản mới nhất.
  Future<void> add(String uid, String query) async {
    final q = query.trim();
    if (uid.isEmpty || q.isEmpty) return;

    // Xóa các entry trùng từ khóa cũ
    final dup = await _col(uid).where('query', isEqualTo: q).get();
    for (final doc in dup.docs) {
      await doc.reference.delete();
    }

    await _col(uid).add({
      'query': q,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Đọc N từ khóa gần nhất.
  Future<List<String>> recent(String uid, {int limit = 10}) async {
    if (uid.isEmpty) return [];
    final snap = await _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => d.data()['query'] as String).toList();
  }

  /// Stream realtime cho UI suggest.
  Stream<List<String>> watchRecent(String uid, {int limit = 10}) {
    if (uid.isEmpty) return Stream.value(const []);
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()['query'] as String).toList());
  }

  Future<void> clear(String uid) async {
    if (uid.isEmpty) return;
    final snap = await _col(uid).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
