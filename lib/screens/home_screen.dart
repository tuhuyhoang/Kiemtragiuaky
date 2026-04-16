import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/news_provider.dart';
import '../providers/search_history_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/search_field.dart';
import 'detail_screen.dart';

/// Tab Tin tức (Home).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadArticles();
    });
  }

  void _showErrorIfNeeded(NewsProvider news) {
    final message = news.errorMessage;
    if (news.status == NewsStatus.error &&
        message != null &&
        message != _lastShownError) {
      _lastShownError = message;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => context.read<NewsProvider>().loadArticles(),
            ),
          ),
        );
      });
    }
    if (news.status != NewsStatus.error) {
      _lastShownError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = context.watch<NewsProvider>();
    final user = context.select<AuthProvider, String?>((p) => p.user?.name);
    _showErrorIfNeeded(news);
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xin chào, ${user ?? "Bạn"}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tin tức hôm nay',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SearchField(
              hintText: 'Tìm bài theo tiêu đề/nội dung...',
              onChanged: (q) {
                news.setQuery(q);
                if (q.trim().length >= 3) {
                  context.read<SearchHistoryProvider>().add(q);
                }
              },
            ),
          ),
        ],
        body: _buildBody(news),
      ),
    );
  }

  Widget _buildBody(NewsProvider news) {
    if (news.status == NewsStatus.loading && news.articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Đang tải tin tức...'),
          ],
        ),
      );
    }

    if (news.status == NewsStatus.error && news.articles.isEmpty) {
      return ErrorView(
        message: news.errorMessage ?? 'Đã có lỗi xảy ra.',
        onRetry: news.loadArticles,
      );
    }

    final items = news.filteredArticles;
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: news.loadArticles,
        child: ListView(
          children: const [
            SizedBox(height: 80),
            EmptyState(
              icon: Icons.search_off,
              message: 'Không tìm thấy bài viết phù hợp.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: news.loadArticles,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final article = items[index];
          return ArticleCard(
            article: article,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailScreen(article: article),
              ),
            ),
          );
        },
      ),
    );
  }
}
