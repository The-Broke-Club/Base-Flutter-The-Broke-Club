import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Classe base para gerenciar erros e operações seguras
class BaseChangeNotifier with ChangeNotifier {
  String? _error;
  bool _isLoading = false;

  String? get error => _error;
  bool get isLoading => _isLoading;

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Executa operações com tratamento de erros e estado de loading
  Future<T?> safeOperation<T>(Future<T> Function() operation, {String? errorPrefix}) async {
    try {
      setLoading(true);
      clearError();
      return await operation();
    } catch (e) {
      final message = errorPrefix != null ? '$errorPrefix: ${e.toString()}' : e.toString();
      setError(message);
      return null;
    } finally {
      setLoading(false);
    }
  }
}

// Implementação do AuthProvider original com funcionalidades adicionais
class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _token;
  String? _error;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;

  // Construtor que verifica se há um token salvo
  AuthProvider() {
    _checkAuthStatus();
  }

  // Métodos para gerenciar estados de erro e carregamento
  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método para operações seguras com tratamento de erros
  Future<T?> safeOperation<T>(Future<T> Function() operation, {String? errorPrefix}) async {
    try {
      setLoading(true);
      clearError();
      return await operation();
    } catch (e) {
      final message = errorPrefix != null ? '$errorPrefix: ${e.toString()}' : e.toString();
      setError(message);
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Verifica se há uma sessão ativa
  Future<void> _checkAuthStatus() async {
    await safeOperation(() async {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      
      if (savedToken != null) {
        _token = savedToken;
        _userEmail = prefs.getString('user_email');
        _isAuthenticated = true;
        notifyListeners();
      }
      return true;
    }, errorPrefix: 'Erro ao verificar autenticação');
  }

  // Validar credenciais
  bool _validateCredentials(String email, String password) {
    if (email.isEmpty) {
      setError('O email é obrigatório');
      return false;
    }
    
    if (!email.contains('@')) {
      setError('Formato de email inválido');
      return false;
    }
    
    if (password.isEmpty) {
      setError('A senha é obrigatória');
      return false;
    }
    
    if (password.length < 6) {
      setError('A senha deve ter pelo menos 6 caracteres');
      return false;
    }
    
    return true;
  }

  // Método para fazer login com validação
  Future<bool> login(String email, String password) async {
    clearError();
    
    // Validação antes de iniciar operação assíncrona
    if (!_validateCredentials(email, password)) {
      return false;
    }
    
    return await safeOperation(() async {
      // Simulação de uma chamada API para autenticação
      await Future.delayed(const Duration(seconds: 1));
      
      _isAuthenticated = true;
      _userEmail = email;
      _token = 'simulated_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Salvar dados de autenticação
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_email', email);
      
      notifyListeners();
      return true;
    }, errorPrefix: 'Falha na autenticação') ?? false;
  }

  // Método para fazer login com Google
  Future<bool> loginWithGoogle() async {
    clearError();
    
    return await safeOperation(() async {
      // Simulação de login com Google
      await Future.delayed(const Duration(seconds: 1));
      
      _isAuthenticated = true;
      _userEmail = 'user@gmail.com'; // Simulado
      _token = 'google_token_${DateTime.now().millisecondsSinceEpoch}';
      
      // Salvar dados de autenticação
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_email', _userEmail!);
      
      notifyListeners();
      return true;
    }, errorPrefix: 'Falha ao autenticar com Google') ?? false;
  }

  // Método para fazer logout
  Future<bool> logout() async {
    return await safeOperation(() async {
      _isAuthenticated = false;
      _userEmail = null;
      _token = null;
      
      // Limpar dados de autenticação
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      
      notifyListeners();
      return true;
    }, errorPrefix: 'Erro ao fazer logout') ?? false;
  }
}