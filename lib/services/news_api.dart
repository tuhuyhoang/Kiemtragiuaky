import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/article.dart';

class NewsApi {
  static const String _endpoint = 'https://jsonplaceholder.typicode.com/posts';

  final http.Client _client;

  NewsApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Article>> fetchArticles() async {
    try {
      final response = await _client
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Máy chủ trả về mã ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .cast<Map<String, dynamic>>()
          .map(Article.fromJson)
          .toList(growable: false);
    } on SocketException {
      throw Exception('Không có kết nối mạng. Vui lòng kiểm tra Internet.');
    } on HttpException {
      throw Exception('Lỗi kết nối máy chủ.');
    } on FormatException {
      throw Exception('Dữ liệu trả về không hợp lệ.');
    }
  }
}
