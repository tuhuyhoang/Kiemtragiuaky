import 'package:flutter_test/flutter_test.dart';

import 'package:tu_huy_hoang/models/article.dart';

void main() {
  group('Article model', () {
    test('fromJson parses JSONPlaceholder format', () {
      final article = Article.fromJson({
        'id': 1,
        'title': '  Tiêu đề ',
        'body': 'Nội dung',
      });
      expect(article.id, 1);
      expect(article.title, 'Tiêu đề');
      expect(article.body, 'Nội dung');
      expect(article.imageUrl, contains('picsum.photos'));
    });

    test('toMap and fromMap roundtrip (Firestore)', () {
      final original = Article(
        id: 42,
        title: 'Test',
        body: 'Body content',
        imageUrl: 'https://example.com/x.jpg',
        publishedAt: DateTime(2026, 4, 16, 10, 30),
      );
      final restored = Article.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.body, original.body);
      expect(restored.imageUrl, original.imageUrl);
      expect(restored.publishedAt, original.publishedAt);
    });

    test('description truncates long body', () {
      final article = Article(
        id: 1,
        title: 't',
        body: 'a' * 200,
        imageUrl: '',
        publishedAt: DateTime.now(),
      );
      expect(article.description.length, lessThanOrEqualTo(123));
      expect(article.description.endsWith('...'), isTrue);
    });
  });
}
