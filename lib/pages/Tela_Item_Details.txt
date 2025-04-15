import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página de detalhes do item
class ItemDetailsPage extends StatelessWidget {
  const ItemDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Detalhes do Item',
      routes: {'/edit-item': 'Editar Item'},
    );
  }
}