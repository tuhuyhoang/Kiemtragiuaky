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

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Article && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
