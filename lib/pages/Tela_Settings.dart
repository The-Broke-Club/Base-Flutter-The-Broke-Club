
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          // Background com gradiente (mesmo estilo da HomePage)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                  Colors.black,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header personalizado
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Configurações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de opções
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildSettingsOption(
                        context,
                        'Preferências de Notificação',
                        Icons.notifications,
                        () => context.push('/notification-prefs'),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsOption(
                        context,
                        'Sobre o Aplicativo',
                        Icons.info,
                        () => context.push('/about'),
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsOption(
                        context,
                        'Tema',
                        Icons.palette,
                        () {
                          // Implementar mudança de tema
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsOption(
                        context,
                        'Tamanho da Fonte',
                        Icons.text_fields,
                        () {
                          // Implementar mudança de fonte
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 71, 233, 133),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}