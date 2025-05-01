import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Formulário para editar um item
class EditItemPage extends StatelessWidget {
  final String? itemId;
  
  const EditItemPage({super.key, this.itemId});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>(); // Chave para validação do formulário
    final bool isEditing = itemId != null;
    
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Item #$itemId' : 'Novo Item')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                validator: (value) =>
                    value!.isEmpty ? 'O nome é obrigatório' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item salvo!')),
                    );
                    context.pop(); // Volta para a tela anterior
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}