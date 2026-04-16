import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/news_provider.dart';
import 'providers/search_history_provider.dart';
import 'repositories/article_cache_repository.dart';
import 'repositories/article_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/search_history_repository.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject dependencies theo Clean Architecture:
    //   Repository (Data: SQLite + HTTP)
    //     -> Provider (ViewModel)
    //       -> View
    final articleRepo = ArticleRepository();
    final articleCache = ArticleCacheRepository();
    final favoritesRepo = FavoritesRepository();
    final authRepo = AuthRepository();
    final historyRepo = SearchHistoryRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(
            repository: articleRepo,
            cache: articleCache,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(repository: favoritesRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchHistoryProvider(repository: historyRepo),
        ),
      ],
      child: MaterialApp(
        title: 'News App - Từ Huy Hoàng',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Quyết định màn hình theo trạng thái đăng nhập + bind user vào các provider.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Bind user_id vào FavoritesProvider + SearchHistoryProvider.
    final userId = auth.user?.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      context.read<FavoritesProvider>().bindUser(userId);
      context.read<SearchHistoryProvider>().bindUser(userId);
    });

    switch (auth.status) {
      case AuthStatus.initializing:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return const MainShell();
    }
  }
}
