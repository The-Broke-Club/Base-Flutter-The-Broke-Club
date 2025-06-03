import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/validators.dart';
import '../models/auth_state.dart';
import '../services/auth_service.dart';
import '../blocs/login/login_bloc.dart';
import '../blocs/login/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isSignUp = false;
  bool _showMainForm = false;
  
  // Valores para o blur effect
  final double _sigmaX = 5;
  final double _sigmaY = 5;
  final double _opacity = 0.2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final authState = Provider.of<AuthState>(context, listen: false);
      
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final user = await authService.signIn(email, password);
      
      if (user != null) {
        await authState.loginWithEmailAndPassword(context, email, password);
        
        if (authState.isAuthenticated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else {
        throw Exception('Credenciais inválidas');
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        final errorString = e.toString();
        
        if (errorString.contains('user-not-found')) {
          errorMessage = 'Usuário não encontrado';
        } else if (errorString.contains('wrong-password')) {
          errorMessage = 'Senha incorreta';
        } else {
          errorMessage = 'Erro no login: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final authState = Provider.of<AuthState>(context, listen: false);

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();

      final user = await authService.signUp(email, password);
      if (user != null) {
        if (name.isNotEmpty) {
          await authService.updateDisplayName(name);
          await authState.updateUserInfo(context, displayName: name);
        }
        await authState.loginWithEmailAndPassword(context, email, password);

        if (authState.isAuthenticated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else {
        throw Exception('Falha ao registrar usuário');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final authState = Provider.of<AuthState>(context, listen: false);
      
      final user = await authService.signInWithGoogle();
      
      if (user != null) {
        await authState.loginWithGoogle(context);
        
        if (authState.isAuthenticated && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login com Google realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home');
        }
      } else {
        throw Exception('Login com Google cancelado ou falhou');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no login com Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || Validators.validateEmail(email) != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, insira um email válido'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.resetPassword(email);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de recuperação enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        final errorString = e.toString();
        
        if (errorString.contains('user-not-found')) {
          errorMessage = 'Usuário não encontrado';
        } else {
          errorMessage = 'Erro na recuperação de senha: $e';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    });
  }

  void _proceedToLogin() {
    setState(() {
      _showMainForm = true;
    });
  }

  void _proceedToSignUp() {
    setState(() {
      _showMainForm = true;
      _isSignUp = true;
    });
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    FocusNode? focusNode,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: Color.fromARGB(255, 10, 8, 8)),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 15, 10, 10)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 71, 233, 133)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          fillColor: Colors.grey.shade200,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onTap,
    Color backgroundColor = const Color.fromARGB(255, 71, 233, 133),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 15, 11, 11),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String imagePath,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 40);
              },
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login realizado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Image - CORRIGIDO
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/porco_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Overlay escuro semi-transparente
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey[800]?.withOpacity(0.7),
                  ),
                  // Conteúdo principal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                        onPressed: () {
                          if (_showMainForm) {
                            setState(() {
                              _showMainForm = false;
                              _isSignUp = false;
                            });
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      
                      // Conteúdo principal baseado no estado
                      if (!_showMainForm) ...[
                        // Tela de Boas-vindas
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            "Olá!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(_opacity),
                                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                                ),
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 20),
                                        // Campo de email
                                        _buildCustomTextField(
                                          controller: _emailController,
                                          hintText: 'Email',
                                          validator: Validators.validateEmail,
                                          keyboardType: TextInputType.emailAddress,
                                          focusNode: _emailFocusNode,
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        // Botão continuar
                                        _buildCustomButton(
                                          text: "Continuar",
                                          onTap: () {
                                            if (_formKey.currentState!.validate()) {
                                              _proceedToLogin();
                                            }
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        // Divisor
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                thickness: 0.5,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                                              child: Text(
                                                'Ou',
                                                style: TextStyle(color: Colors.white, fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                thickness: 0.5,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        // Botões de redes sociais
                                        _buildSocialButton(
                                          imagePath: 'assets/images/facebook.png',
                                          title: "Continuar com Facebook",
                                        ),
                                        const SizedBox(height: 10),
                                        _buildSocialButton(
                                          imagePath: 'assets/images/google.png',
                                          title: "Continuar com Google",
                                          onTap: _handleGoogleSignIn,
                                        ),
                                        const SizedBox(height: 10),
                                        _buildSocialButton(
                                          imagePath: 'assets/images/apple.png',
                                          title: "Continuar com Apple",
                                        ),
                                        const SizedBox(height: 10),
                                        
                                        // Links de cadastro e recuperação de senha
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Não tem uma conta?',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  GestureDetector(
                                                    onTap: _proceedToSignUp,
                                                    child: const Text(
                                                      'Cadastre-se',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(255, 71, 233, 133),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              GestureDetector(
                                                onTap: _handlePasswordReset,
                                                child: const Text(
                                                  'Esqueceu a senha?',
                                                  style: TextStyle(
                                                    color: Color.fromARGB(255, 71, 233, 133),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_isSignUp) ...[
                        // Tela de Cadastro
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            "Cadastrar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(_opacity),
                                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                                ),
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 20),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                                          child: Text(
                                            "Parece que você não tem uma conta. Vamos criar uma nova conta para",
                                            style: TextStyle(color: Colors.white, fontSize: 20),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                          child: Text(
                                            _emailController.text.isNotEmpty 
                                                ? _emailController.text 
                                                : "seu email",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        
                                        // Campo de nome
                                        _buildCustomTextField(
                                          controller: _nameController,
                                          hintText: 'Nome',
                                          validator: Validators.validateName,
                                        ),
                                        
                                        // Campo de email
                                        _buildCustomTextField(
                                          controller: _emailController,
                                          hintText: 'Email',
                                          validator: Validators.validateEmail,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        
                                        // Campo de senha
                                        _buildCustomTextField(
                                          controller: _passwordController,
                                          hintText: 'Senha',
                                          obscureText: true,
                                          validator: Validators.validatePassword,
                                        ),
                                        const SizedBox(height: 30),
                                        
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 25.0),
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Ao selecionar Concordar e Continuar abaixo, eu concordo com nossos ',
                                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                                    ),
                                                    TextSpan(
                                                      text: 'Termos de Serviço e Política de Privacidade',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(255, 71, 233, 133),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            _buildCustomButton(
                                              text: "Concordar e Continuar",
                                              onTap: _handleSignUp,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Tela de Login
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.0),
                          child: Text(
                            "Entrar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(_opacity),
                                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                                ),
                                width: MediaQuery.of(context).size.width * 0.9,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 20),
                                        // Seção de informações do usuário
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                          child: Row(
                                            children: [
                                              const CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                  'https://anmg-production.anmg.xyz/yaza-co-za_sfja9J2vLAtVaGdUPdH5y7gA',
                                                ),
                                                child: Icon(Icons.person, color: Colors.white),
                                              ),
                                              SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Maria Silva",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      _emailController.text.isNotEmpty 
                                                          ? _emailController.text 
                                                          : "maria.silva@gmail.com",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        
                                        // Campo de senha
                                        _buildCustomTextField(
                                          controller: _passwordController,
                                          hintText: 'Senha',
                                          obscureText: true,
                                          validator: Validators.validatePassword,
                                        ),
                                        const SizedBox(height: 30),
                                        
                                        // Botão continuar
                                        _buildCustomButton(
                                          text: "Continuar",
                                          onTap: _handleLogin,
                                        ),
                                        const SizedBox(height: 30),
                                        
                                        // Link esqueceu a senha
                                        GestureDetector(
                                          onTap: _handlePasswordReset,
                                          child: const Text(
                                            'Esqueceu a senha?',
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 71, 233, 133),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}