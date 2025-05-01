import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

/// Classe para gerenciar e armazenar as preferências do usuário
class UserPreferences with ChangeNotifier {
  static const String _prefsKey = 'user_preferences';
  static const String _themeKey = 'theme_preference';
  static const String _localeKey = 'locale_preference';
  static const String _notificationsKey = 'notifications_preference';
  static const String _dataUsageKey = 'data_usage_preference';
  static const String _fontSizeKey = 'font_size_preference';
  static const String _lastSyncKey = 'last_sync';
  static const String _userIdKey = 'associated_user_id';

  // Estado das preferências
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('pt', 'BR');
  bool _notificationsEnabled = true;
  DataUsagePreference _dataUsage = DataUsagePreference.balanced;
  FontSize _fontSize = FontSize.medium;
  DateTime? _lastSync;
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get notificationsEnabled => _notificationsEnabled;
  DataUsagePreference get dataUsage => _dataUsage;
  FontSize get fontSize => _fontSize;
  DateTime? get lastSync => _lastSync;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Inicializa as preferências do usuário
  UserPreferences() {
    _loadPreferences();
  }

  // Inicializa para um usuário específico
  Future<void> initializeForUser(String userId) async {
    if (_userId == userId) return; // Já está inicializado para este usuário
    
    _userId = userId;
    await _loadPreferences();
    notifyListeners();
  }

  // Limpa as preferências quando o usuário faz logout
  Future<void> clearUserPreferences() async {
    _userId = null;
    // Volta para as configurações padrão
    _resetToDefaults();
    await _savePreferences();
    notifyListeners();
  }

  // Define as preferências para os valores padrão
  void _resetToDefaults() {
    _themeMode = ThemeMode.system;
    _locale = const Locale('pt', 'BR');
    _notificationsEnabled = true;
    _dataUsage = DataUsagePreference.balanced;
    _fontSize = FontSize.medium;
    _lastSync = null;
  }

  // Carrega as preferências do armazenamento local
  Future<void> _loadPreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Se temos um userId, tentamos carregar preferências específicas do usuário
      if (_userId != null) {
        final userPrefsJson = prefs.getString('${_prefsKey}_$_userId');
        if (userPrefsJson != null) {
          final userPrefs = json.decode(userPrefsJson) as Map<String, dynamic>;
          _loadFromMap(userPrefs);
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      
      // Carrega preferências gerais (não específicas de usuário)
      // Tema
      final themeName = prefs.getString(_themeKey);
      if (themeName != null) {
        _themeMode = _parseThemeMode(themeName);
      }
      
      // Idioma
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        final parts = localeCode.split('_');
        if (parts.length == 2) {
          _locale = Locale(parts[0], parts[1]);
        }
      }
      
      // Notificações
      final notifications = prefs.getBool(_notificationsKey);
      if (notifications != null) {
        _notificationsEnabled = notifications;
      }
      
      // Uso de dados
      final dataUsageIndex = prefs.getInt(_dataUsageKey);
      if (dataUsageIndex != null && dataUsageIndex < DataUsagePreference.values.length) {
        _dataUsage = DataUsagePreference.values[dataUsageIndex];
      }
      
      // Tamanho da fonte
      final fontSizeIndex = prefs.getInt(_fontSizeKey);
      if (fontSizeIndex != null && fontSizeIndex < FontSize.values.length) {
        _fontSize = FontSize.values[fontSizeIndex];
      }
      
      // Última sincronização
      final lastSyncString = prefs.getString(_lastSyncKey);
      if (lastSyncString != null) {
        _lastSync = DateTime.tryParse(lastSyncString);
      }
      
      // ID do usuário associado às preferências
      _userId = prefs.getString(_userIdKey);
      
    } catch (e) {
      _errorMessage = 'Falha ao carregar preferências: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Carrega preferências de um mapa JSON
  void _loadFromMap(Map<String, dynamic> prefsMap) {
    _themeMode = _parseThemeMode(prefsMap[_themeKey] ?? 'system');
    
    final localeCode = prefsMap[_localeKey];
    if (localeCode != null) {
      final parts = localeCode.split('_');
      if (parts.length == 2) {
        _locale = Locale(parts[0], parts[1]);
      }
    }
    
    _notificationsEnabled = prefsMap[_notificationsKey] ?? true;
    
    final dataUsageIndex = prefsMap[_dataUsageKey];
    if (dataUsageIndex != null && dataUsageIndex < DataUsagePreference.values.length) {
      _dataUsage = DataUsagePreference.values[dataUsageIndex];
    }
    
    final fontSizeIndex = prefsMap[_fontSizeKey];
    if (fontSizeIndex != null && fontSizeIndex < FontSize.values.length) {
      _fontSize = FontSize.values[fontSizeIndex];
    }
    
    final lastSyncString = prefsMap[_lastSyncKey];
    if (lastSyncString != null) {
      _lastSync = DateTime.tryParse(lastSyncString);
    }
  }

  // Parse string para ThemeMode
  ThemeMode _parseThemeMode(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Converte ThemeMode para string
  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  // Salva as preferências no armazenamento
  Future<bool> _savePreferences() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Prepara o mapa de dados
      final prefsMap = <String, dynamic>{
        _themeKey: _themeModeName(_themeMode),
        _localeKey: '${_locale.languageCode}_${_locale.countryCode}',
        _notificationsKey: _notificationsEnabled,
        _dataUsageKey: _dataUsage.index,
        _fontSizeKey: _fontSize.index,
        _lastSyncKey: _lastSync?.toIso8601String(),
      };
      
      // Se temos um userId, salvamos preferências específicas para este usuário
      if (_userId != null) {
        final prefsJson = json.encode(prefsMap);
        await prefs.setString('${_prefsKey}_$_userId', prefsJson);
        await prefs.setString(_userIdKey, _userId!);
      } else {
        // Salvamos cada preferência individualmente para acesso não-autenticado
        await prefs.setString(_themeKey, _themeModeName(_themeMode));
        await prefs.setString(_localeKey, '${_locale.languageCode}_${_locale.countryCode}');
        await prefs.setBool(_notificationsKey, _notificationsEnabled);
        await prefs.setInt(_dataUsageKey, _dataUsage.index);
        await prefs.setInt(_fontSizeKey, _fontSize.index);
        
        if (_lastSync != null) {
          await prefs.setString(_lastSyncKey, _lastSync!.toIso8601String());
        } else {
          await prefs.remove(_lastSyncKey);
        }
        
        // Remove ID do usuário se não autenticado
        await prefs.remove(_userIdKey);
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao salvar preferências: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos para alterar as preferências
  Future<bool> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateLastSync();
      final result = await _savePreferences();
      notifyListeners();
      return result;
    }
    return true;
  }

  Future<bool> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;
      _updateLastSync();
      final result = await _savePreferences();
      notifyListeners();
      return result;
    }
    return true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled != enabled) {
      _notificationsEnabled = enabled;
      _updateLastSync();
      final result = await _savePreferences();
      notifyListeners();
      return result;
    }
    return true;
  }

  Future<bool> setDataUsage(DataUsagePreference usage) async {
    if (_dataUsage != usage) {
      _dataUsage = usage;
      _updateLastSync();
      final result = await _savePreferences();
      notifyListeners();
      return result;
    }
    return true;
  }

  Future<bool> setFontSize(FontSize size) async {
    if (_fontSize != size) {
      _fontSize = size;
      _updateLastSync();
      final result = await _savePreferences();
      notifyListeners();
      return result;
    }
    return true;
  }

  // Atualiza o timestamp da última sincronização
  void _updateLastSync() {
    _lastSync = DateTime.now();
  }

  // Sincroniza preferências com o servidor (simulado)
  Future<bool> syncWithServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulação de uma chamada de API
      await Future.delayed(const Duration(seconds: 1));
      
      // Em uma implementação real, aqui enviaríamos as preferências ao servidor
      // e/ou buscaríamos atualizações do servidor
      
      _updateLastSync();
      await _savePreferences();
      return true;
    } catch (e) {
      _errorMessage = 'Falha ao sincronizar com o servidor: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpa mensagens de erro
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}

/// Enum para representar os diferentes níveis de uso de dados
enum DataUsagePreference {
  minimal,    // Baixo uso de dados (modo economia)
  balanced,   // Uso equilibrado (padrão)
  high        // Alto uso de dados (melhor qualidade)
}

/// Enum para representar os diferentes tamanhos de fonte
enum FontSize {
  small,      // Fonte pequena
  medium,     // Fonte média (padrão)
  large,      // Fonte grande
  extraLarge  // Fonte extra grande (acessibilidade)
}

/// Widget Provider para disponibilizar preferências em toda a aplicação
class UserPreferencesProvider extends StatelessWidget {
  final Widget child;
  final String? userId;

  const UserPreferencesProvider({
    super.key,
    required this.child,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final prefs = UserPreferences();
        if (userId != null) {
          // Inicializa para um usuário específico se fornecido
          prefs.initializeForUser(userId!);
        }
        return prefs;
      },
      child: child,
    );
  }
}

/// Extensão para facilitar o acesso às preferências em qualquer lugar do app
extension UserPreferencesExtension on BuildContext {
  UserPreferences get userPreferences => Provider.of<UserPreferences>(this, listen: false);
  
  // Acesso com escuta para rebuilds automáticos quando as preferências mudarem
  UserPreferences get watchUserPreferences => Provider.of<UserPreferences>(this);
}