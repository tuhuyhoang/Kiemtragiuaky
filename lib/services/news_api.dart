import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/article.dart';

/// Service gọi API tin tức.
/// Thử nhiều endpoint dự phòng, fallback về mock data nếu mọi API đều fail.
class NewsApi {
  /// Danh sách endpoint thử lần lượt. Dùng nhiều API để né 403/CORS/region block.
  static const List<_Endpoint> _endpoints = [
    _Endpoint(
      url: 'https://dummyjson.com/posts?limit=50',
      isWrapped: true, // response wrap trong { "posts": [...] }
    ),
    _Endpoint(
      url: 'https://jsonplaceholder.typicode.com/posts',
      isWrapped: false,
    ),
  ];

  static const Map<String, String> _headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) NewsApp/1.0',
    'Accept': 'application/json',
  };

  final http.Client _client;

  NewsApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Article>> fetchArticles() async {
    Object? lastError;

    for (final ep in _endpoints) {
      try {
        final response = await _client
            .get(Uri.parse(ep.url), headers: _headers)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode != 200) {
          lastError = Exception('Máy chủ ${ep.url} trả về mã ${response.statusCode}');
          continue;
        }

        final decoded = jsonDecode(response.body);
        final list = ep.isWrapped
            ? (decoded['posts'] as List<dynamic>)
            : (decoded as List<dynamic>);

        return list
            .cast<Map<String, dynamic>>()
            .map(Article.fromJson)
            .toList(growable: false);
      } on SocketException catch (e) {
        lastError = Exception('Không có kết nối mạng: ${e.message}');
        continue;
      } on HttpException {
        lastError = Exception('Lỗi kết nối máy chủ.');
        continue;
      } on FormatException {
        lastError = Exception('Dữ liệu trả về không hợp lệ.');
        continue;
      } catch (e) {
        lastError = Exception(e.toString());
        continue;
      }
    }

    // Tất cả API fail - trả về mock data để demo app vẫn chạy
    // ignore: avoid_print
    print('⚠️ Mọi API đều fail ($lastError). Trả về mock data.');
    return _mockArticles();
  }

  /// Mock data 30 bài để app vẫn chạy được khi mất mạng/API fail.
  List<Article> _mockArticles() {
    return List.generate(30, (i) {
      final id = i + 1;
      return Article(
        id: id,
        title: _mockTitles[i % _mockTitles.length],
        body: _mockBodies[i % _mockBodies.length],
        imageUrl: 'https://picsum.photos/seed/$id/600/400',
        publishedAt: DateTime.now().subtract(Duration(hours: id * 2)),
      );
    });
  }

  static const List<String> _mockTitles = [
    'Chuyển đổi số trong giáo dục đại học Việt Nam',
    'AI và tương lai của ngành phát triển phần mềm',
    'Flutter 3.x: những tính năng mới nổi bật',
    'Bảo mật ứng dụng mobile - các lỗ hổng phổ biến',
    'Top 10 framework mobile được dùng nhiều năm 2026',
    'Lập trình viên trẻ và cơ hội tại các startup',
    'Kotlin Multiplatform hay Flutter - chọn nào?',
    'Hành trình từ sinh viên đến senior developer',
    'Database NoSQL vs SQL - so sánh thực tế',
    'Clean Architecture trong Flutter - từ A đến Z',
  ];

  static const List<String> _mockBodies = [
    'Trong những năm gần đây, chuyển đổi số đã trở thành xu hướng tất yếu trong giáo dục đại học. Các trường đầu tư mạnh vào hạ tầng công nghệ, học liệu số, và đào tạo trực tuyến để nâng cao chất lượng giảng dạy.',
    'Trí tuệ nhân tạo đang thay đổi cách lập trình viên làm việc. Từ code completion đến tự động hóa testing, AI giúp tăng năng suất nhưng cũng đặt ra thách thức về kỹ năng cần thiết cho thế hệ developer mới.',
    'Flutter 3 mang đến nhiều cải tiến: Material 3, hỗ trợ macOS và Linux ổn định, cải thiện hiệu năng, và đặc biệt là Dart 3 với null safety hoàn chỉnh. Đây là bước tiến lớn cho cộng đồng Flutter.',
    'Bảo mật mobile luôn là vấn đề được quan tâm. Lỗ hổng SQL injection, lưu trữ không an toàn, và rò rỉ dữ liệu qua log debug là những vấn đề thường gặp mà developer cần chú ý xử lý ngay từ đầu.',
    'React Native, Flutter, Kotlin Multiplatform và SwiftUI đang dẫn đầu năm 2026. Mỗi framework có thế mạnh riêng - lựa chọn phụ thuộc vào team, dự án và độ trưởng thành của cộng đồng.',
  ];
}

class _Endpoint {
  const _Endpoint({required this.url, required this.isWrapped});
  final String url;
  final bool isWrapped;
}
