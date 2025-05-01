import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página principal com opções de navegação
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Início',
      routes: {
        '/item-details': 'Ver Detalhes do Item',
        '/profile': 'Perfil do Usuário',
        '/settings': 'Configurações',
      },
    );
  }
}