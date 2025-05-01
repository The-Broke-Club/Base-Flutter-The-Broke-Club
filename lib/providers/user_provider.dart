import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfile {
  String userId;
  String username;
  String email;
  String? photoUrl;
  String? bio;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.photoUrl,
    this.bio,
  });

  // Converter de JSON para UserProfile
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      bio: json['bio'],
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
    };
  }
}

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Construtor que tenta carregar o perfil salvo
  UserProvider() {
    loadUserProfile();
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

  // Carregar perfil do usuário
  Future<void> loadUserProfile() async {
    await safeOperation(() async {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_profile');
      
      if (userJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(userJson));
      }
      return true;
    }, errorPrefix: 'Erro ao carregar perfil');
  }

  // Validar dados do perfil
  bool _validateProfileData({
    String? username,
    String? email,
  }) {
    if (username != null && username.isEmpty) {
      setError('O nome de usuário não pode estar vazio');
      return false;
    }
    
    if (email != null) {
      if (email.isEmpty) {
        setError('O email não pode estar vazio');
        return false;
      }
      
      // Validação básica de email
      if (!email.contains('@') || !email.contains('.')) {
        setError('Formato de email inválido');
        return false;
      }
    }
    
    return true;
  }

  // Atualizar perfil do usuário com validação
  Future<bool> updateProfile({
    String? username,
    String? email,
    String? photoUrl,
    String? bio,
  }) async {
    clearError();
    
    // Validação antes de iniciar operação assíncrona
    if (!_validateProfileData(username: username, email: email)) {
      return false;
    }
    
    return await safeOperation(() async {
      if (_userProfile == null) {
        // Criar um novo perfil se não existir
        final prefs = await SharedPreferences.getInstance();
        final userEmail = prefs.getString('user_email') ?? '';
        
        _userProfile = UserProfile(
          userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
          username: username ?? 'Usuário',
          email: email ?? userEmail,
          photoUrl: photoUrl,
          bio: bio,
        );
      } else {
        // Atualizar perfil existente
        _userProfile = UserProfile(
          userId: _userProfile!.userId,
          username: username ?? _userProfile!.username,
          email: email ?? _userProfile!.email,
          photoUrl: photoUrl ?? _userProfile!.photoUrl,
          bio: bio ?? _userProfile!.bio,
        );
      }

      // Salvar perfil atualizado
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(_userProfile!.toJson()));
      return true;
    }, errorPrefix: 'Erro ao atualizar perfil') ?? false;
  }

  // Atualizar apenas o nome de usuário
  Future<bool> updateUsername(String username) async {
    return await updateProfile(username: username);
  }

  // Atualizar apenas o email
  Future<bool> updateEmail(String email) async {
    return await updateProfile(email: email);
  }

  // Atualizar apenas a foto de perfil
  Future<bool> updatePhoto(String photoUrl) async {
    return await updateProfile(photoUrl: photoUrl);
  }

  // Atualizar apenas a biografia
  Future<bool> updateBio(String bio) async {
    return await updateProfile(bio: bio);
  }

  // Limpar dados do perfil (ao fazer logout)
  Future<bool> clearProfile() async {
    return await safeOperation(() async {
      _userProfile = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      return true;
    }, errorPrefix: 'Erro ao limpar perfil') ?? false;
  }
  
  // Verificar se o perfil existe
  bool hasProfile() {
    return _userProfile != null;
  }
  
  // Obter nome de usuário ou valor padrão
  String getUsername() {
    return _userProfile?.username ?? 'Visitante';
  }
  
  // Obter iniciais do usuário para avatar
  String getUserInitials() {
    if (_userProfile == null || _userProfile!.username.isEmpty) {
      return '?';
    }
    
    final nameParts = _userProfile!.username.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '?';
    }
  }
}