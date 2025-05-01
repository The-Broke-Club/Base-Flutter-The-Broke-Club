import 'package:flutter/material.dart';
import 'Template_Page.dart';

// Página de detalhes do item
class ItemDetailsPage extends StatelessWidget {
  final String? itemId;
  
  const ItemDetailsPage({super.key, this.itemId});

  @override
  Widget build(BuildContext context) {
    // Verificar se o ID foi fornecido
    if (itemId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: const Center(child: Text('Nenhum item especificado')),
      );
    }
    
    return TemplatePage(
      title: 'Detalhes do Item #$itemId',
      routes: {'/edit-item?id=$itemId': 'Editar Item'},
    );
  }
}