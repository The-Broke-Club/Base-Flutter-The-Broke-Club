import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Página de preferências de notificação
class NotificationPrefsPage extends StatelessWidget {
  const NotificationPrefsPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool pushNotifications = true; // Estado simulado
    return Scaffold(
      appBar: AppBar(title: const Text('Preferências de Notificação')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Notificações Push'),
              value: pushNotifications,
              onChanged: (value) {
                // Atualiza o estado (simulado)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notificações push: $value')),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}