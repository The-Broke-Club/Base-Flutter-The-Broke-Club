import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Modelo reutilizável para páginas com botões de navegação
class TemplatePage extends StatelessWidget {
  final String title;
  final Map<String, String> routes;
  final Widget? body; // Parâmetro body adicionado
  final FloatingActionButton? floatingActionButton; // Tornar opcional

  const TemplatePage({
    super.key, 
    required this.title, 
    required this.routes,
    this.body, 
    this.floatingActionButton, // Parâmetro opcional
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Exibe uma mensagem ao detectar toque duplo
      onDoubleTap: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toque duplo detectado!')),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true, // Centraliza o título
        ),
        body: body ?? _buildDefaultBody(), // Usa body se fornecido, caso contrário usa o corpo padrão
        floatingActionButton: floatingActionButton, // Adiciona o floatingActionButton se fornecido
      ),
    );
  }

  // Método para construir o corpo padrão com os botões de navegação
  Widget _buildDefaultBody() {
    return Builder(
      builder: (context) => ListView(
        padding: const EdgeInsets.all(20),
        children: routes.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              onPressed: () => context.push(entry.key),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16), // Botões maiores
              ),
              child: Text(entry.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}