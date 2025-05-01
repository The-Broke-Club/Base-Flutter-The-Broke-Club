import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Modelo reutilizável para páginas com botões de navegação
class TemplatePage extends StatelessWidget {
  final String title;
  final Map<String, String> routes;

  const TemplatePage({super.key, required this.title, required this.routes});

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
        body: ListView(
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
      ),
    );
  }
}