import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../widgets/article_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import 'detail_screen.dart';

/// Tab Yêu thích.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final items = fav.filteredFavorites;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (fav.favorites.isNotEmpty) ...[
            SearchField(
              hintText: 'Tìm theo tiêu đề hoặc nội dung...',
              onChanged: fav.setQuery,
            ),
            _ResultBar(
              total: fav.favorites.length,
              shown: items.length,
              query: fav.query,
              onClear: fav.clearQuery,
            ),
          ],
          Expanded(child: _buildBody(fav, items)),
        ],
      ),
    );
  }

  Widget _buildBody(FavoritesProvider fav, List items) {
    if (fav.favorites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message:
            'Chưa có bài viết yêu thích.\nNhấn vào biểu tượng trái tim ở một bài để thêm.',
        iconColor: Colors.redAccent,
      );
    }

    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        message:
            'Không tìm thấy bài nào khớp với "${fav.query}".\nThử từ khóa khác.',
      );
    }

    return ListView.builder(
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
    );
  }
}

/// Thanh thông tin kết quả: hiển thị số bài đang xem và filter chip.
class _ResultBar extends StatelessWidget {
  const _ResultBar({
    required this.total,
    required this.shown,
    required this.query,
    required this.onClear,
  });

  final int total;
  final int shown;
  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Icon(Icons.list_alt, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            hasQuery
                ? 'Tìm thấy $shown / $total bài'
                : 'Tổng cộng $total bài yêu thích',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (hasQuery)
            InputChip(
              label: Text(
                '"$query"',
                style: const TextStyle(fontSize: 12),
              ),
              avatar: const Icon(Icons.search, size: 14),
              onDeleted: onClear,
              deleteIconColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
        ],
      ),
    );
  }
}
