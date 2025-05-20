import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';

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
  bool _accountStatus = true; // Substituído isActive por accountStatus
  bool _isSaving = false;
  String? _errorMessage;

  // Variáveis para preferências de usuário
  bool _darkThemeEnabled = false;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  String _language = 'pt_BR';
  String _currency = 'BRL';

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _emailController = TextEditingController(text: widget.user.email);
    
    // Inicializando accountStatus com um valor padrão ou do modelo
    // Vamos assumir que o modelo User tem uma propriedade accountStatus ou algo similar
    _accountStatus = widget.user.accountStatus;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obter preferências do usuário usando o Provider
    final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
    final userPrefs = prefsProvider.preferences;
    
    if (userPrefs != null) {
      setState(() {
        _darkThemeEnabled = userPrefs.darkThemeEnabled;
        _pushNotificationsEnabled = userPrefs.pushNotificationsEnabled;
        _emailNotificationsEnabled = userPrefs.emailNotificationsEnabled;
        _language = userPrefs.language;
        _currency = userPrefs.currency;
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usando o Provider correto
    final prefsProvider = Provider.of<PreferencesProvider>(context);
    final bool isLoading = prefsProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
            tooltip: 'Salvar Alterações',
          ),
        ],
      ),
      body: isLoading || _isSaving
          ? const Center(child: CircularProgressIndicator())
          : _buildEditForm(context, prefsProvider),
    );
  }

  Widget _buildEditForm(BuildContext context, PreferencesProvider prefsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    child: GestureDetector(
                      onTap: () {
                        // Ação futura: abrir seletor de imagem
                      },
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'Informações Pessoais'),
            const SizedBox(height: 16),

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

            // Widget para gerenciar estado da conta (accountStatus)
            SwitchListTile(
              title: const Text('Conta Ativa'),
              value: _accountStatus,
              onChanged: (value) {
                setState(() {
                  _accountStatus = value;
                });
              },
              secondary: Icon(
                _accountStatus ? Icons.check_circle : Icons.cancel,
                color: _accountStatus ? Colors.green : Colors.red,
              ),
            ),
            const Divider(),

            _buildSectionTitle(context, 'Preferências do Aplicativo'),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Tema Escuro'),
              value: _darkThemeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkThemeEnabled = value;
                });
              },
              secondary: Icon(
                _darkThemeEnabled ? Icons.dark_mode : Icons.light_mode,
                color: _darkThemeEnabled ? Colors.indigo : Colors.amber,
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Notificações Push'),
              value: _pushNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _pushNotificationsEnabled = value;
                });
              },
              secondary: Icon(
                _pushNotificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _pushNotificationsEnabled ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Notificações por Email'),
              value: _emailNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _emailNotificationsEnabled = value;
                });
              },
              secondary: Icon(
                _emailNotificationsEnabled ? Icons.email : Icons.email_outlined,
                color: _emailNotificationsEnabled ? Colors.blue : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            _buildDropdownField<String>(
              label: 'Idioma',
              value: _language,
              icon: const Icon(Icons.language),
              items: [
                DropdownMenuItem(value: 'pt_BR', child: const Text('Português (Brasil)')),
                DropdownMenuItem(value: 'en_US', child: const Text('Inglês (EUA)')),
                DropdownMenuItem(value: 'es_ES', child: const Text('Espanhol')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            _buildDropdownField<String>(
              label: 'Moeda',
              value: _currency,
              icon: const Icon(Icons.monetization_on),
              items: [
                DropdownMenuItem(value: 'BRL', child: const Text('Real (R\$)')),
                DropdownMenuItem(value: 'USD', child: const Text('Dólar (US\$)')),
                DropdownMenuItem(value: 'EUR', child: const Text('Euro (€)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Usando apenas accountStatus no modelo do usuário
      final updatedUser = widget.user.copyWith(
        displayName: _displayNameController.text.trim(),
        email: _emailController.text.trim(),
        accountStatus: _accountStatus, // Usando accountStatus diretamente no modelo
        updatedAt: DateTime.now(),
      );

      // Criando um objeto com as preferências atualizadas
      final updatedPreferences = {
        'darkThemeEnabled': _darkThemeEnabled,
        'pushNotificationsEnabled': _pushNotificationsEnabled,
        'emailNotificationsEnabled': _emailNotificationsEnabled,
        'language': _language,
        'currency': _currency,
      };

      // Atualizando as preferências do usuário
      final prefsProvider = Provider.of<PreferencesProvider>(context, listen: false);
      await prefsProvider.updatePreferences(updatedPreferences);

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  String _getInitials() {
    final displayName = _displayNameController.text;
    if (displayName.isEmpty) {
      return _emailController.text.isNotEmpty 
          ? _emailController.text.substring(0, 1).toUpperCase()
          : 'U';
    }

    final nameParts = displayName.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first.isNotEmpty ? nameParts.first[0] : ''}${nameParts.last.isNotEmpty ? nameParts.last[0] : ''}'.toUpperCase();
    }
    return nameParts.first.isNotEmpty ? nameParts.first[0].toUpperCase() : 'U';
  }
}