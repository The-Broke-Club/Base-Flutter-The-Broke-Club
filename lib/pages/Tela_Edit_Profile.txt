import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Formulário para editar o perfil do usuário
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome de Usuário'),
                validator: (value) =>
                    value!.isEmpty ? 'O nome é obrigatório' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (value) =>
                    value!.isEmpty ? 'O e-mail é obrigatório' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado!')),
                    );
                    context.pop();
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