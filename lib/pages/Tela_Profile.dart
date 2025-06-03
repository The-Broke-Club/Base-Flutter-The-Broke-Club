import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/auth_state.dart';
import '../models/user.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Valores para o blur effect (mesmo conceito da home)
  final double _sigmaX = 5;
  final double _sigmaY = 5;
  final double _opacity = 0.2;

  // Controllers para edição
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _displayNameController.text = widget.user.displayName ?? '';
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    _bioController.text = widget.user.bio ?? '';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = Provider.of<UserPreferences>(context);
    final headerStyle = _getTextStyle(context, userPreferences, true);
    final contentStyle = _getTextStyle(context, userPreferences, false);

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          // Background com gradiente
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
          
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                _buildModernAppBar(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 71, 233, 133),
                        ))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileHeader(headerStyle, contentStyle),
                              const SizedBox(height: 24),
                              _buildPersonalInfo(headerStyle, contentStyle),
                              const SizedBox(height: 24),
                              _buildPreferences(headerStyle, contentStyle),
                              const SizedBox(height: 24),
                              _buildAccountActions(headerStyle, contentStyle),
                              const SizedBox(height: 24),
                              _buildDangerZone(headerStyle, contentStyle),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 71, 233, 133),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color.fromARGB(255, 71, 233, 133)),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar Perfil',
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _cancelEdit,
              tooltip: 'Cancelar',
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check, color: Color.fromARGB(255, 71, 233, 133)),
              onPressed: _saveProfile,
              tooltip: 'Salvar',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileHeader(TextStyle headerStyle, TextStyle contentStyle) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(_opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 71, 233, 133),
                    child: widget.user.photoURL != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              widget.user.photoURL!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            (widget.user.displayName?.isNotEmpty == true) 
                                ? widget.user.displayName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 71, 233, 133),
                          shape: BoxShape.circle,
                        ),
                        child: GestureDetector(
                          onTap: _changeProfilePicture,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Nome
              if (_isEditing)
                _buildEditField(
                  controller: _displayNameController,
                  label: 'Nome de exibição',
                  icon: Icons.person,
                  contentStyle: contentStyle,
                )
              else
                Text(
                  widget.user.displayName ?? 'Nome não definido',
                  style: headerStyle.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: 8),
              
              // Email
              Text(
                widget.user.email,
                style: contentStyle.copyWith(
                  color: const Color.fromARGB(255, 71, 233, 133),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Status/Bio
              if (_isEditing)
                _buildEditField(
                  controller: _bioController,
                  label: 'Bio',
                  icon: Icons.info_outline,
                  contentStyle: contentStyle,
                  maxLines: 3,
                )
              else
                Text(
                  widget.user.bio ?? 'Membro do The Broke Club 💚',
                  style: contentStyle.copyWith(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(TextStyle headerStyle, TextStyle contentStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Pessoais',
          style: headerStyle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Email',
          content: _isEditing ? null : widget.user.email,
          icon: Icons.email,
          contentStyle: contentStyle,
          isEditing: _isEditing,
          controller: _emailController,
        ),
        
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Telefone',
          content: _isEditing ? null : (widget.user.phone ?? 'Não informado'),
          icon: Icons.phone,
          contentStyle: contentStyle,
          isEditing: _isEditing,
          controller: _phoneController,
        ),
        
        const SizedBox(height: 12),
        
        _buildInfoCard(
          title: 'Membro desde',
          content: _formatDate(widget.user.createdAt),
          icon: Icons.calendar_today,
          contentStyle: contentStyle,
          isEditing: false,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    String? content,
    required IconData icon,
    required TextStyle contentStyle,
    bool isEditing = false,
    TextEditingController? controller,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: contentStyle.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isEditing && controller != null)
                      TextField(
                        controller: controller,
                        style: contentStyle.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Digite $title',
                          hintStyle: contentStyle.copyWith(color: Colors.grey[600]),
                        ),
                      )
                    else
                      Text(
                        content ?? 'Não informado',
                        style: contentStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextStyle contentStyle,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: contentStyle.copyWith(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: contentStyle.copyWith(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 71, 233, 133)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 71, 233, 133)),
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.1),
      ),
    );
  }

  Widget _buildPreferences(TextStyle headerStyle, TextStyle contentStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferências',
          style: headerStyle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[700]!, width: 0.5),
              ),
              child: Column(
                children: [
                  // Tamanho da Fonte
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.text_fields,
                          color: Color.fromARGB(255, 71, 233, 133),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tamanho da Fonte',
                          style: contentStyle.copyWith(color: Colors.white),
                        ),
                      ),
                      DropdownButton<FontSize>(
                        value: context.watch<UserPreferences>().fontSize,
                        dropdownColor: Colors.grey[800],
                        style: contentStyle.copyWith(color: Colors.white),
                        items: FontSize.values
                            .map((size) => DropdownMenuItem(
                                  value: size,
                                  child: Text(
                                    _getFontSizeLabel(size),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<UserPreferences>().setFontSize(value);
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const Divider(color: Colors.grey),
                  
                  // Notificações
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 71, 233, 133).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Color.fromARGB(255, 71, 233, 133),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notificações',
                          style: contentStyle.copyWith(color: Colors.white),
                        ),
                      ),
                      Switch(
                        value: true,
                        onChanged: (value) {
                          // Implementar lógica de notificações
                        },
                        activeColor: const Color.fromARGB(255, 71, 233, 133),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActions(TextStyle headerStyle, TextStyle contentStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conta',
          style: headerStyle.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        
        _buildActionCard(
          title: 'Alterar Senha',
          subtitle: 'Atualize sua senha de acesso',
          icon: Icons.lock,
          onTap: _changePassword,
          contentStyle: contentStyle,
        ),
        
        const SizedBox(height: 8),
        
        _buildActionCard(
          title: 'Privacidade',
          subtitle: 'Configurações de privacidade',
          icon: Icons.privacy_tip,
          onTap: () => _showPrivacySettings(context),
          contentStyle: contentStyle,
        ),
        
        const SizedBox(height: 8),
        
        _buildActionCard(
          title: 'Exportar Dados',
          subtitle: 'Baixe todos os seus dados',
          icon: Icons.download,
          onTap: _exportData,
          contentStyle: contentStyle,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required TextStyle contentStyle,
  }) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 0.5),
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
              style: contentStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: contentStyle.copyWith(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(TextStyle headerStyle, TextStyle contentStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zona de Perigo',
          style: headerStyle.copyWith(color: Colors.red),
        ),
        const SizedBox(height: 12),
        
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Sair da Conta',
                      style: contentStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Fazer logout do aplicativo',
                      style: contentStyle.copyWith(
                        color: Colors.red[300],
                        fontSize: 12,
                      ),
                    ),
                    onTap: _logout,
                  ),
                  
                  const Divider(color: Colors.red),
                  
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Excluir Conta',
                      style: contentStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Apagar permanentemente sua conta',
                      style: contentStyle.copyWith(
                        color: Colors.red[300],
                        fontSize: 12,
                      ),
                    ),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Métodos de ação
  void _changeProfilePicture() {
    // Implementar seleção de imagem
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de alterar foto em desenvolvimento'),
        backgroundColor: Color.fromARGB(255, 71, 233, 133),
      ),
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _initializeControllers(); // Restaura valores originais
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    try {
      // Simular salvamento
      await Future.delayed(const Duration(seconds: 2));
      
      // Aqui você implementaria a lógica real de salvamento
      // Por exemplo: await userService.updateProfile(...)
      
      setState(() {
        _isEditing = false;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Color.fromARGB(255, 71, 233, 133),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Alterar Senha', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Funcionalidade em desenvolvimento. Em breve você poderá alterar sua senha.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Ok',
              style: TextStyle(color: Color.fromARGB(255, 71, 233, 133)),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    // Implementar configurações de privacidade
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configurações de privacidade em desenvolvimento'),
        backgroundColor: Color.fromARGB(255, 71, 233, 133),
      ),
    );
  }

  void _exportData() {
    // Implementar exportação de dados
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação de dados em desenvolvimento'),
        backgroundColor: Color.fromARGB(255, 71, 233, 133),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confirmar Saída', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authState = Provider.of<AuthState>(context, listen: false);
              await authState.logout(context);
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
        content: const Text(
          'ATENÇÃO: Esta ação é irreversível! Todos os seus dados serão perdidos permanentemente.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implementar lógica de exclusão de conta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de exclusão em desenvolvimento'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getFontSizeLabel(FontSize size) {
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