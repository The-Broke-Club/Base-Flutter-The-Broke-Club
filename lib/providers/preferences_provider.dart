import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserPreferences {
  bool darkThemeEnabled;
  bool pushNotificationsEnabled;
  bool emailNotificationsEnabled;
  String language;
  String currency;
  
  UserPreferences({
    this.darkThemeEnabled = false,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.language = 'pt_BR',
    this.currency = 'BRL',
  });

  // Converter de JSON para UserPreferences
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkThemeEnabled: json['darkThemeEnabled'] ?? false,
      pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
      emailNotificationsEnabled: json['emailNotificationsEnabled'] ?? true,
      language: json['language'] ?? 'pt_BR',
      currency: json['currency'] ?? 'BRL',
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'darkThemeEnabled': darkThemeEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'language': language,
      'currency': currency,
    };
  }
}

class PreferencesProvider with ChangeNotifier {
  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Construtor que carrega as preferências salvas
  PreferencesProvider() {
    loadPreferences();
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
  Future<T?> safeOperation<T>(Future<T> Function() operation, 
      {String? errorPrefix, bool updateLoading = true}) async {
    try {
      if (updateLoading) {
        setLoading(true);
      }
      clearError();
      return await operation();
    } catch (e) {
      final message = errorPrefix != null ? '$errorPrefix: ${e.toString()}' : e.toString();
      setError(message);
      return null;
    } finally {
      if (updateLoading) {
        setLoading(false);
      }
    }
  }

  // Carregar preferências com tratamento de erros
  Future<void> loadPreferences() async {
    await safeOperation(() async {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = prefs.getString('user_preferences');
      
      if (prefsJson != null) {
        _preferences = UserPreferences.fromJson(json.decode(prefsJson));
      } else {
        // Criar preferências padrão se não existirem
        _preferences = UserPreferences();
        await _savePreferences();
      }
      return true;
    }, errorPrefix: 'Erro ao carregar preferências');
  }

  // Salvar preferências com validação
  Future<bool> _savePreferences() async {
    if (_preferences == null) return false;
    
    return await safeOperation(() async {
      final prefs = await SharedPreferences.getInstance();
      final prefsJson = json.encode(_preferences!.toJson());
      await prefs.setString('user_preferences', prefsJson);
      return true;
    }, errorPrefix: 'Erro ao salvar preferências', updateLoading: false) ?? false;
  }

  // Método genérico para atualização de preferências
  Future<bool> updatePreference(Future<void> Function() updateFunction) async {
    return await safeOperation(() async {
      if (_preferences == null) await loadPreferences();
      await updateFunction();
      final saved = await _savePreferences();
      notifyListeners();
      return saved;
    }, errorPrefix: 'Erro ao atualizar preferência') ?? false;
  }

  // Atualizar tema escuro
  Future<bool> setDarkTheme(bool value) async {
    return await updatePreference(() async {
      if (_preferences == null) return;
      
      _preferences = UserPreferences(
        darkThemeEnabled: value,
        pushNotificationsEnabled: _preferences!.pushNotificationsEnabled,
        emailNotificationsEnabled: _preferences!.emailNotificationsEnabled,
        language: _preferences!.language,
        currency: _preferences!.currency,
      );
    });
  }

  // Atualizar preferências de notificação push
  Future<bool> setPushNotifications(bool value) async {
    return await updatePreference(() async {
      if (_preferences == null) return;
      
      _preferences = UserPreferences(
        darkThemeEnabled: _preferences!.darkThemeEnabled,
        pushNotificationsEnabled: value,
        emailNotificationsEnabled: _preferences!.emailNotificationsEnabled,
        language: _preferences!.language,
        currency: _preferences!.currency,
      );
    });
  }

  // Atualizar preferências de notificação por email
  Future<bool> setEmailNotifications(bool value) async {
    return await updatePreference(() async {
      if (_preferences == null) return;
      
      _preferences = UserPreferences(
        darkThemeEnabled: _preferences!.darkThemeEnabled,
        pushNotificationsEnabled: _preferences!.pushNotificationsEnabled,
        emailNotificationsEnabled: value,
        language: _preferences!.language,
        currency: _preferences!.currency,
      );
    });
  }

  // Atualizar idioma com validação
  Future<bool> setLanguage(String languageCode) async {
    // Validação do código de idioma
    final validLanguages = ['pt_BR', 'en_US', 'es_ES'];
    if (!validLanguages.contains(languageCode)) {
      setError('Código de idioma inválido');
      return false;
    }
    
    return await updatePreference(() async {
      if (_preferences == null) return;
      
      _preferences = UserPreferences(
        darkThemeEnabled: _preferences!.darkThemeEnabled,
        pushNotificationsEnabled: _preferences!.pushNotificationsEnabled,
        emailNotificationsEnabled: _preferences!.emailNotificationsEnabled,
        language: languageCode,
        currency: _preferences!.currency,
      );
    });
  }

  // Atualizar moeda com validação
  Future<bool> setCurrency(String currencyCode) async {
    // Validação do código de moeda
    final validCurrencies = ['BRL', 'USD', 'EUR'];
    if (!validCurrencies.contains(currencyCode)) {
      setError('Código de moeda inválido');
      return false;
    }
    
    return await updatePreference(() async {
      if (_preferences == null) return;
      
      _preferences = UserPreferences(
        darkThemeEnabled: _preferences!.darkThemeEnabled,
        pushNotificationsEnabled: _preferences!.pushNotificationsEnabled,
        emailNotificationsEnabled: _preferences!.emailNotificationsEnabled,
        language: _preferences!.language,
        currency: currencyCode,
      );
    });
  }

  // Atualizar todas as preferências de uma vez
  Future<bool> updateAllPreferences(UserPreferences newPreferences) async {
    return await safeOperation(() async {
      _preferences = newPreferences;
      final saved = await _savePreferences();
      notifyListeners();
      return saved;
    }, errorPrefix: 'Erro ao atualizar todas as preferências') ?? false;
  }

  // Resetar para as configurações padrão
  Future<bool> resetToDefaults() async {
    return await safeOperation(() async {
      _preferences = UserPreferences();
      final saved = await _savePreferences();
      notifyListeners();
      return saved;
    }, errorPrefix: 'Erro ao redefinir preferências') ?? false;
  }

  // Limpar dados de preferências (ao fazer logout)
  Future<bool> clearPreferences() async {
    return await safeOperation(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_preferences');
      _preferences = null;
      notifyListeners();
      return true;
    }, errorPrefix: 'Erro ao limpar preferências') ?? false;
  }
}