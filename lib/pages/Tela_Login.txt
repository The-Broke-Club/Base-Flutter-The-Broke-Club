import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página de login (simulada, sem autenticação real)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Login',
      routes: {'/home': 'Entrar'},
    );
  }
}