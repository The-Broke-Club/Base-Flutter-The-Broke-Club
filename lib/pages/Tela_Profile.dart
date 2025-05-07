import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'user.dart';
import 'user_preferences.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  const UserProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Obtém as preferências do usuário com observação para rebuild automático
    final userPreferences = context.watchUserPreferences;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-profile', extra: user),
            tooltip: 'Editar Perfil',
          ),
        ],
      ),
      body: userPreferences.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(context, userPreferences),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserPreferences preferences) {
    // Ajusta o tamanho da fonte com base nas preferências
    final TextStyle headerStyle = _getTextStyle(context, preferences, true);
    final TextStyle contentStyle = _getTextStyle(context, preferences, false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil (placeholder circular)
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                _getInitials(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Informações do usuário
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informações Pessoais', style: headerStyle),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow('Nome', user.displayName ?? 'Não definido', contentStyle),
                  _buildInfoRow('Email', user.email, contentStyle),
                  _buildInfoRow('Conta criada em', _formatDate(user.createdAt), contentStyle),
                  _buildInfoRow('Status', user.isActive ? 'Ativo' : 'Inativo', contentStyle,
                    iconData: user.isActive ? Icons.check_circle : Icons.cancel,
                    iconColor: user.isActive ? Colors.green : Colors.red),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Seção de preferências
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferências do Aplicativo', style: headerStyle),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  _buildInfoRow('Tema', _getThemeModeName(preferences.themeMode), contentStyle,
                      iconData: _getThemeIcon(preferences.themeMode)),
                      
                  _buildInfoRow('Idioma', '${preferences.locale.languageCode}-${preferences.locale.countryCode}', 
                      contentStyle, iconData: Icons.language),
                      
                  _buildInfoRow('Notificações', 
                      preferences.notificationsEnabled ? 'Ativadas' : 'Desativadas', 
                      contentStyle,
                      iconData: preferences.notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                      iconColor: preferences.notificationsEnabled ? Colors.green : Colors.grey),
                      
                  _buildInfoRow('Uso de dados', _getDataUsageName(preferences.dataUsage), 
                      contentStyle, iconData: Icons.data_usage),
                      
                  _buildInfoRow('Tamanho da fonte', _getFontSizeName(preferences.fontSize), 
                      contentStyle, iconData: Icons.format_size),
                      
                  if (preferences.lastSync != null)
                    _buildInfoRow('Última sincronização', _formatDate(preferences.lastSync!), 
                        contentStyle, iconData: Icons.sync),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Botões de ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Configurações'),
                onPressed: () => context.push('/settings'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar'),
                onPressed: () {
                  // Sincroniza as preferências do usuário
                  context.userPreferences.syncWithServer().then((success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success 
                          ? 'Sincronização concluída com sucesso!'
                          : 'Falha na sincronização. Tente novamente.'),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Constrói uma linha de informação com ícone opcional
  Widget _buildInfoRow(String label, String value, TextStyle style, 
      {IconData? iconData, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          if (iconData != null)
            Icon(iconData, color: iconColor, size: 20),
          if (iconData != null)
            const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text('$label:', style: style),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: style),
          ),
        ],
      ),
    );
  }

  // Formata a data para exibição
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Obtém as iniciais do nome do usuário para o avatar
  String _getInitials() {
    if (user.displayName == null || user.displayName!.isEmpty) {
      return user.email.substring(0, 1).toUpperCase();
    }
    
    final nameParts = user.displayName!.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
    }
    
    return nameParts.first.substring(0, 1).toUpperCase();
  }

  // Ajusta o estilo de texto conforme as preferências de tamanho de fonte
  TextStyle _getTextStyle(BuildContext context, UserPreferences preferences, bool isHeader) {
    final baseStyle = isHeader 
        ? Theme.of(context).textTheme.titleLarge 
        : Theme.of(context).textTheme.bodyMedium;
    
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
    
    return baseStyle!.copyWith(
      fontSize: baseStyle.fontSize! * fontSizeFactor,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
  }

  // Obtém o nome do tema em formato legível
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
    }
  }

  // Obtém o ícone apropriado para o tema
  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.phonelink_setup;
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
    }
  }

  // Retorna o nome legível para a preferência de uso de dados
  String _getDataUsageName(DataUsagePreference usage) {
    switch (usage) {
      case DataUsagePreference.minimal:
        return 'Mínimo';
      case DataUsagePreference.balanced:
        return 'Equilibrado';
      case DataUsagePreference.high:
        return 'Alto';
    }
  }

  // Retorna o nome legível para o tamanho da fonte
  String _getFontSizeName(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 'Pequeno';
      case FontSize.medium:
        return 'Médio';
      case FontSize.large:
        return 'Grande';
      case FontSize.extraLarge:
        return 'Extra Grande';
    }
  }
}