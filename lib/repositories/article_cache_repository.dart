import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article.dart';

/// Cache bài viết vào Firestore collection `articles`.
/// Khi mất mạng, có thể đọc lại từ cache (offline support).
class ArticleCacheRepository {
  ArticleCacheRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('articles');

  /// Lưu/cập nhật danh sách bài (batch write để hiệu quả).
  Future<void> cacheAll(List<Article> articles) async {
    if (articles.isEmpty) return;
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();
    for (final a in articles) {
      batch.set(_col.doc(a.id.toString()), {
        ...a.toMap(),
        'cachedAt': now,
      });
    }
    await batch.commit();
  }

  /// Đọc cache - dùng khi mất mạng.
  Future<List<Article>> loadCache() async {
    try {
      final snap = await _col.orderBy('id').limit(100).get();
      return snap.docs.map((d) => Article.fromMap(d.data())).toList();
    } catch (_) {
      return const [];
    }
  }
}
