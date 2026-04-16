import '../models/article.dart';
import '../services/news_api.dart';

/// Repository trung gian giữa data source (NewsApi) và Controller (Provider).
/// Đây là lớp của Clean Architecture:
///   Data Source (NewsApi)  ->  Repository  ->  Provider (ViewModel)  ->  View
///
/// Lợi ích:
/// - Controller không phụ thuộc trực tiếp vào HTTP/service.
/// - Có thể mock repository khi test, hoặc đổi nguồn dữ liệu (API -> local DB)
///   mà không sửa Provider.
class ArticleRepository {
  ArticleRepository({NewsApi? api}) : _api = api ?? NewsApi();

  final NewsApi _api;

  Future<List<Article>> getArticles() {
    return _api.fetchArticles();
  }
}
