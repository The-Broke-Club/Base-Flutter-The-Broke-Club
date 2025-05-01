import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  // Lista de usuários em memória (simulação de banco de dados)
  final List<User> _users = [
    User(
      id: '1',
      email: 'teste@example.com',
      displayName: 'Teste',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  User? _currentUser;
  final Uuid _uuid = const Uuid();
  final Map<String, String> _passwords = {
    'teste@example.com': '123456', // Senha inicial para o usuário de teste
  };

  AuthService() {
    _loadUserData(); // Carrega dados na inicialização
  }

  User? get currentUser => _currentUser;

  Future<User?> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula delay de rede
    try {
      if (!_users.any((user) => user.email == email)) {
        throw Exception('user-not-found');
      }
      if (_passwords[email] != password) {
        throw Exception('wrong-password');
      }
      final user = _users.firstWhere((user) => user.email == email);
      _currentUser = user;
      await _saveAuthState(user.id);
      notifyListeners();
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User?> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula delay de rede
    if (_users.any((user) => user.email == email)) {
      throw Exception('email-already-in-use');
    }
    final user = User(
      id: _uuid.v4(),
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _users.add(user);
    _passwords[email] = password; // Armazena a senha (apenas para simulação)
    _currentUser = user;
    await _saveAuthState(user.id);
    notifyListeners();
    return user;
  }

  Future<User?> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula delay de rede
    const googleEmail = 'googleuser@example.com';
    var user = _users.firstWhere(
      (user) => user.email == googleEmail,
      orElse: () {
        final newUser = User(
          id: _uuid.v4(),
          email: googleEmail,
          displayName: 'Google User',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _users.add(newUser);
        _passwords[googleEmail] = 'google123'; // Senha fictícia
        return newUser;
      },
    );
    _currentUser = user;
    await _saveAuthState(user.id);
    notifyListeners();
    return user;
  }

  Future<void> updateDisplayName(String displayName) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula delay de rede
    if (_currentUser != null) {
      final index = _users.indexWhere((user) => user.id == _currentUser!.id);
      if (index != -1) {
        _users[index] = _users[index].copyWith(displayName: displayName);
        _currentUser = _users[index];
        await _saveUserData();
        notifyListeners();
      }
    }
  }

  Future<bool> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula delay de rede
    if (!_users.any((user) => user.email == email)) {
      throw Exception('user-not-found');
    }
    // Simula envio de email de recuperação
    return true;
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_uid');
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('current_user_uid');
    if (uid == null) return null;
    try {
      return _users.firstWhere((user) => user.id == uid);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthState(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_uid', uid);
    await _saveUserData();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = _users.map((user) => user.toJson()).toList();
    await prefs.setString('users', jsonEncode(usersJson));
    final passwordsJson = jsonEncode(_passwords);
    await prefs.setString('passwords', passwordsJson);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    final passwordsJson = prefs.getString('passwords');
    try {
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users.clear();
        _users.addAll(usersList.map((json) => User.fromJson(json)).toList());
      }
      if (passwordsJson != null) {
        final Map<String, dynamic> passwordsMap = jsonDecode(passwordsJson);
        _passwords.clear();
        _passwords.addAll(passwordsMap.cast<String, String>());
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
      // Mantém os dados iniciais se houver erro
    }
  }
}