import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final userPreferences = context.watchUserPreferences;
    final headerStyle = _getTextStyle(context, userPreferences, true);
    final contentStyle = _getTextStyle(context, userPreferences, false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-profile', extra: user),
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informações do Usuário', style: headerStyle),
            const SizedBox(height: 16),
            _buildProfileCard(contentStyle),
            const SizedBox(height: 16),
            Text('Configurações', style: headerStyle),
            const SizedBox(height: 8),
            _buildSettings(contentStyle, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(TextStyle contentStyle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${user.displayName ?? 'Não definido'}', style: contentStyle),
            const SizedBox(height: 8),
            Text('Email: ${user.email}', style: contentStyle),
            const SizedBox(height: 8),
            Text('Conta criada em: ${_formatDate(user.createdAt)}', style: contentStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(TextStyle contentStyle, BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('Tamanho da Fonte', style: contentStyle),
          trailing: DropdownButton<FontSize>(
            value: context.watchUserPreferences.fontSize,
            items: FontSize.values
                .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text(size.toString().split('.').last),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.readUserPreferences.setFontSize(value);
              }
            },
          ),
        ),
        ListTile(
          title: Text('Sair', style: contentStyle.copyWith(color: Colors.red)),
          trailing: const Icon(Icons.logout, color: Colors.red),
          onTap: () async {
            final authState = Provider.of<AuthState>(context, listen: false);
            await authState.logout(context);
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  TextStyle _getTextStyle(BuildContext context, UserPreferences preferences, bool isHeader) {
    final baseStyle = isHeader
        ? Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 20)
        : Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 16);

    double fontSizeFactor;
    switch (preferences.fontSize) {
      case FontSize.small:
        fontSizeFactor = isHeader ? 1.0 : 0.9;
        break;
      case FontSize.medium:
        fontSizeFactor = isHeader ? 1.2 : 1.0;
        break;
      case FontSize.large:
        fontSizeFactor = isHeader ? 1.4 : 1.2;
        break;
      case FontSize.extraLarge:
        fontSizeFactor = isHeader ? 1.6 : 1.4;
        break;
    }

    return baseStyle.copyWith(
      fontSize: baseStyle.fontSize! * fontSizeFactor,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
  }
}