class Article {
  final int id;
  final String title;
  final String body;
  final String imageUrl;
  final DateTime publishedAt;

  const Article({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.publishedAt,
  });

  String get description {
    final clean = body.replaceAll('\n', ' ');
    return clean.length > 120 ? '${clean.substring(0, 120)}...' : clean;
  }

  /// Parse từ JSON API (JSONPlaceholder).
  factory Article.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    return Article(
      id: id,
      title: (json['title'] as String? ?? '').trim(),
      body: (json['body'] as String? ?? '').trim(),
      imageUrl: 'https://picsum.photos/seed/$id/600/400',
      publishedAt: DateTime.now().subtract(Duration(hours: id * 2)),
    );
  }

  /// Parse từ Firestore document.
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: (map['id'] as num).toInt(),
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      imageUrl: (map['imageUrl'] as String?) ??
          'https://picsum.photos/seed/${map['id']}/600/400',
      publishedAt: DateTime.tryParse(map['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Serialize cho Firestore.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Article && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
