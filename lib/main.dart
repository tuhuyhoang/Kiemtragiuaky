import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/news_provider.dart';
import 'repositories/article_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/favorites_repository.dart';
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
    //   Repository (Data)  ->  Provider (ViewModel)  ->  View
    final articleRepo = ArticleRepository();
    final favoritesRepo = FavoritesRepository();
    final authRepo = AuthRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => NewsProvider(repository: articleRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(repository: favoritesRepo),
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

/// Widget quyết định hiển thị màn hình nào dựa trên trạng thái đăng nhập.
/// - initializing: spinner toàn màn hình
/// - unauthenticated: LoginScreen
/// - authenticated: HomeScreen (3 màn hình News)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((p) => p.status);

    switch (status) {
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
