import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Tela inicial de boas-vindas
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Bem-vindo ao The Broke Club',
      routes: {'/login': 'Ir para Login'},
    );
  }
}