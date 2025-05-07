import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/Tela_About.dart';
import 'pages/Tela_Edit_Item.dart';
import 'pages/Tela_Edit_Profile.dart';
import 'pages/Tela_Home.dart';
import 'pages/Tela_Item_Details.dart';
import 'pages/Tela_Login.dart';
import 'pages/Tela_Notification_Prefs.dart';
import 'pages/Tela_Profile.dart';
import 'pages/Tela_Settings.dart';
import 'pages/Tela_Splash.dart';

// Ponto de entrada do aplicativo
void main() {
  runApp(const TheBrokeClubApp());
}

// Configuração do roteador com todas as rotas
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/item-details',
      builder: (context, state) => const ItemDetailsPage(),
    ),
    GoRoute(
      path: '/edit-item',
      builder: (context, state) => const EditItemPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfilePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/notification-prefs',
      builder: (context, state) => const NotificationPrefsPage(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
  ],
  // Tratamento de erro para rotas inválidas
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Erro')),
    body: Center(child: Text('Página não encontrada: ${state.uri}')),
  ),
);

// Widget principal do aplicativo
class TheBrokeClubApp extends StatelessWidget {
  const TheBrokeClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Broke Club',
      theme: ThemeData(primarySwatch: Colors.blue), // Tema básico
      routerConfig: _router,
    );
  }
}