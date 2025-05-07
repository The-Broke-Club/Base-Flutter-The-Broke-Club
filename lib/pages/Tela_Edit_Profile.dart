import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'user.dart';
import 'user_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  bool _isActive = true;
  bool _isSaving = false;
  String? _errorMessage;

  // Controladores para os campos de preferências
  late ThemeMode _selectedThemeMode;
  late DataUsagePreference _selectedDataUsage;
  late FontSize _selectedFontSize;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os valores atuais do usuário
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    _isActive = widget.user.isActive;

    // Inicializa os valores de preferências
    final prefs = context.userPreferences;
    _selectedThemeMode = prefs.themeMode;
    _selectedDataUsage = prefs.dataUsage;
    _selectedFontSize = prefs.fontSize;
    _notificationsEnabled = prefs.notificationsEnabled;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = context.watchUserPreferences;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          // Botão de salvar na AppBar
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
            tooltip: 'Salvar Alterações',
          ),
        ],
      ),
      body: userPreferences.isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator())
          : _buildEditForm(context, userPreferences),
    );
  }

  Widget _buildEditForm(BuildContext context, UserPreferences preferences) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto de perfil (placeholder circular com opção de alterar)
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
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
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seção de informações pessoais
            _buildSectionTitle(context, 'Informações Pessoais'),
            const SizedBox(height: 16),

            // Campo de nome de usuário
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um nome de usuário';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo de e-mail
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um e-mail';
                }
                if (!_isValidEmail(value)) {
                  return 'Por favor, insira um e-mail válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status da conta (ativo/inativo)
            SwitchListTile(
              title: const Text('Conta Ativa'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: Icon(
                _isActive ? Icons.check_circle : Icons.cancel,
                color: _isActive ? Colors.green : Colors.red,
              ),
            ),
            const Divider(),

            // Seção de preferências do aplicativo
            _buildSectionTitle(context, 'Preferências do Aplicativo'),
            const SizedBox(height: 16),

            // Tema do aplicativo
            _buildDropdownField<ThemeMode>(
              label: 'Tema',
              value: _selectedThemeMode,
              icon: _getThemeIcon(_selectedThemeMode),
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: const Text('Sistema'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: const Text('Claro'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: const Text('Escuro'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedThemeMode = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Uso de dados
            _buildDropdownField<DataUsagePreference>(
              label: 'Uso de Dados',
              value: _selectedDataUsage,
              icon: const Icon(Icons.data_usage),
              items: [
                DropdownMenuItem(
                  value: DataUsagePreference.minimal,
                  child: const Text('Mínimo'),
                ),
                DropdownMenuItem(
                  value: DataUsagePreference.balanced,
                  child: const Text('Equilibrado'),
                ),
                DropdownMenuItem(
                  value: DataUsagePreference.high,
                  child: const Text('Alto'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDataUsage = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Tamanho da fonte
            _buildDropdownField<FontSize>(
              label: 'Tamanho da Fonte',
              value: _selectedFontSize,
              icon: const Icon(Icons.format_size),
              items: [
                DropdownMenuItem(
                  value: FontSize.small,
                  child: const Text('Pequeno'),
                ),
                DropdownMenuItem(
                  value: FontSize.medium,
                  child: const Text('Médio'),
                ),
                DropdownMenuItem(
                  value: FontSize.large,
                  child: const Text('Grande'),
                ),
                DropdownMenuItem(
                  value: FontSize.extraLarge,
                  child: const Text('Extra Grande'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFontSize = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Configuração de notificações
            SwitchListTile(
              title: const Text('Notificações'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              secondary: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Mensagem de erro (se houver)
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            const SizedBox(height: 16),

            // Botões de ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar'),
                  onPressed: () => context.pop(),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  onPressed: _isSaving ? null : _saveProfile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Título de seção com estilo consistente
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Divider(),
      ],
    );
  }

  // Widget personalizado para campos dropdown
  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    Widget? icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: icon,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Salva as alterações do perfil e das preferências
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      // Simula uma chamada de API para atualizar o perfil do usuário
      await Future.delayed(const Duration(milliseconds: 800));

      // Em uma aplicação real, aqui seria feita uma chamada para atualizar o usuário
      final updatedUser = widget.user.copyWith(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      // Atualiza as preferências do usuário
      final prefs = context.userPreferences;
      await prefs.setThemeMode(_selectedThemeMode);
      await prefs.setDataUsage(_selectedDataUsage);
      await prefs.setFontSize(_selectedFontSize);
      await prefs.setNotificationsEnabled(_notificationsEnabled);

      // Navega de volta para a tela de perfil e passa o usuário atualizado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        context.pop(updatedUser);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha ao atualizar o perfil: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Validador simples de e-mail
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Obtém as iniciais do nome do usuário para o avatar
  String _getInitials() {
    final displayName = _displayNameController.text;
    if (displayName.isEmpty) {
      return _emailController.text.substring(0, 1).toUpperCase();
    }
    
    final nameParts = displayName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first.substring(0, 1)}${nameParts.last.substring(0, 1)}'.toUpperCase();
    }
    
    return nameParts.first.substring(0, 1).toUpperCase();
  }

  // Obtém o ícone apropriado para o tema
  Icon _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return const Icon(Icons.phonelink_setup);
      case ThemeMode.light:
        return const Icon(Icons.wb_sunny);
      case ThemeMode.dark:
        return const Icon(Icons.nightlight_round);
    }
  }
}