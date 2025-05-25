import 'package:flutter/material.dart';

// Página sobre o aplicativo
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre o The Broke Club')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Broke Club',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Versão: 1.0.0'),
            Text('Desenvolvido por: Ni,Si,FE,ED'),
            Text('© 2025 The Broke Club. Todos os direitos reservados.'),
            SizedBox(height: 20),
            Text(
              'Um aplicativo para compartilhar e gerenciar itens entre amigos.',
            ),
          ],
        ),
      ),
    );
  }
}