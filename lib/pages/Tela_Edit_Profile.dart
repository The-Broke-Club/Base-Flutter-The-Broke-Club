import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Métodos para Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Métodos para Tema Escuro
  Future<void> saveDarkTheme(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', enabled);
  }

  Future<bool> getDarkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkTheme') ?? false;
  }

  // Métodos para Notificações Push
  Future<void> savePushNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', enabled);
  }

  Future<bool> getPushNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('pushNotifications') ?? true;
  }

  // Métodos para Notificações por Email
  Future<void> saveEmailNotifications(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotifications', enabled);
  }

  Future<bool> getEmailNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('emailNotifications') ?? true;
  }

  // Métodos para Idioma
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'pt_BR';
  }

  // Métodos para Moeda
  Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency') ?? 'BRL';
  }
}