import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página de configurações
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Configurações',
      routes: {
        '/notification-prefs': 'Preferências de Notificação',
        '/about': 'Sobre o Aplicativo',
      },
    );
  }
}