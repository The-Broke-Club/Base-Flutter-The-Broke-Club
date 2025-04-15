import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Ponto de entrada do aplicativo
void main() {
  runApp(const TheBrokeClubApp());
}

// Configuração do roteador com todas as rotas do aplicativo
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/item-details',
      builder: (context, state) => const ItemDetailsPage(),
    ),
    GoRoute(
      path: '/edit-item',
      builder: (context, state) => const EditItemPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const UserProfilePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/notification-prefs',
      builder: (context, state) => const NotificationPrefsPage(),
    ),
    GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
  ],
  // Tratamento de erro para rotas inválidas
  errorBuilder:
      (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(child: Text('Página não encontrada: ${state.uri}')),
      ),
);

// Widget principal do aplicativo
class TheBrokeClubApp extends StatelessWidget {
  const TheBrokeClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Broke Club',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Tema básico para consistência
      routerConfig: _router,
    );
  }
}

// Modelo reutilizável para páginas com botões de navegação
class TemplatePage extends StatelessWidget {
  final String title;
  final Map<String, String> routes;

  const TemplatePage({super.key, required this.title, required this.routes});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Exibe uma mensagem ao detectar toque duplo
      onDoubleTap:
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Toque duplo detectado!')),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true, // Centraliza o título
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children:
              routes.entries.map((entry) {
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

// Tela inicial de boas-vindas
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Bem-vindo ao The Broke Club',
      routes: {'/login': 'Ir para Login'},
    );
  }
}

// Página de login (simulada, sem autenticação real)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(title: 'Login', routes: {'/home': 'Entrar'});
  }
}

// Página principal com opções de navegação
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Início',
      routes: {
        '/item-details': 'Ver Detalhes do Item',
        '/profile': 'Perfil do Usuário',
        '/settings': 'Configurações',
      },
    );
  }
}

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

// Formulário para editar um item
class EditItemPage extends StatelessWidget {
  const EditItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey =
        GlobalKey<FormState>(); // Chave para validação do formulário
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Item')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome do Item'),
                validator:
                    (value) => value!.isEmpty ? 'O nome é obrigatório' : null,
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
                validator:
                    (value) => value!.isEmpty ? 'O nome é obrigatório' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator:
                    (value) => value!.isEmpty ? 'O e-mail é obrigatório' : null,
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

// Página de configurações
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
      title: 'Configurações',
      routes: {
        '/notification-prefs': 'Preferências de Notificação',
        '/about': 'Sobre o Aplicativo',
      },
    );
  }
}

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
                // Atualiza o estado (simulado, usar gerenciador de estado em um app real)
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
            Text('Desenvolvido por: Seu Nome'),
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
