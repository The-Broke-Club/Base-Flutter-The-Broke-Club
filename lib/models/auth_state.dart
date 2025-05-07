import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthState extends ChangeNotifier {
  User? _user;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  AuthState(BuildContext context) {
    _initializeAuthState(context);
  }

  Future<void> _initializeAuthState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _user = await authService.getCurrentUser();
    _isAuthenticated = _user != null;
    notifyListeners();
  }

  Future<bool> loginWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signIn(email, password);
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Falha ao fazer login';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _errorMessage = null;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Falha ao fazer login com Google';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(BuildContext context, String email) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.resetPassword(email);
      _errorMessage = null;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> updateUserInfo(BuildContext context, {String? displayName}) async {
    if (_user == null) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    if (displayName != null) {
      await authService.updateDisplayName(displayName);
      _user = _user!.copyWith(displayName: displayName);
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }
}