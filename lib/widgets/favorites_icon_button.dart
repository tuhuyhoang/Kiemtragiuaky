import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';

/// IconButton hiển thị icon trái tim + badge số lượng bài yêu thích.
/// Nhấn sẽ gọi [onPressed] (thường là mở FavoritesScreen).
class FavoritesIconButton extends StatelessWidget {
  const FavoritesIconButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final count = context.select<FavoritesProvider, int>((p) => p.count);

    return IconButton(
      tooltip: 'Yêu thích',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.favorite),
      ),
    );
  }
}
