import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página de perfil do usuário
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Perfil do Usuário',
      routes: {'/edit-profile': 'Editar Perfil'},
    );
  }
}