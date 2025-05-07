import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'pages/Tela_Login.dart';
import 'pages/Tela_Home.dart';
import 'models/auth_state.dart';
import 'services/auth_service.dart';

// Configuração do roteador com rotas essenciais
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
  redirect: (context, state) {
    final authState = Provider.of<AuthState>(context, listen: false);
    final isLoggedIn = authState.isAuthenticated;
    final isOnLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/';

    if (!isLoggedIn && !isOnLoginPage) {
      return '/login';
    }

    if (isLoggedIn && isOnLoginPage) {
      return '/home';
    }

    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Erro')),
    body: Center(child: Text('Página não encontrada: ${state.uri}')),
  ),
);

// Widget principal do aplicativo
void main() {
  runApp(const TheBrokeClubApp());
}

class TheBrokeClubApp extends StatelessWidget {
  const TheBrokeClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => AuthState(context)),
      ],
      child: MaterialApp.router(
        title: 'The Broke Club',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}