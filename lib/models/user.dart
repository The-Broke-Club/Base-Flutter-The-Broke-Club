import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FontSize { small, medium, large, extraLarge }

class UserPreferences with ChangeNotifier {
  FontSize _fontSize = FontSize.medium;
  bool _darkThemeEnabled = false;
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  String _language = 'pt_BR';
  String _currency = 'BRL';

  FontSize get fontSize => _fontSize;
  bool get darkThemeEnabled => _darkThemeEnabled;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled;
  String get language => _language;
  String get currency => _currency;

  void setFontSize(FontSize size) {
    _fontSize = size;
    notifyListeners();
  }

  void setDarkThemeEnabled(bool value) {
    _darkThemeEnabled = value;
    notifyListeners();
  }

  void setPushNotificationsEnabled(bool value) {
    _pushNotificationsEnabled = value;
    notifyListeners();
  }

  void setEmailNotificationsEnabled(bool value) {
    _emailNotificationsEnabled = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setCurrency(String value) {
    _currency = value;
    notifyListeners();
  }

  // Método para atualizar todas as preferências de uma vez
  void updateAll({
    bool? darkThemeEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    String? language,
    String? currency,
    FontSize? fontSize,
  }) {
    if (darkThemeEnabled != null) _darkThemeEnabled = darkThemeEnabled;
    if (pushNotificationsEnabled != null) _pushNotificationsEnabled = pushNotificationsEnabled;
    if (emailNotificationsEnabled != null) _emailNotificationsEnabled = emailNotificationsEnabled;
    if (language != null) _language = language;
    if (currency != null) _currency = currency;
    if (fontSize != null) _fontSize = fontSize;
    notifyListeners();
  }
}

extension UserPreferencesExtension on BuildContext {
  UserPreferences get watchUserPreferences => watch<UserPreferences>();
  UserPreferences get readUserPreferences => read<UserPreferences>();
}

class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool accountStatus; // Adicionado campo accountStatus

  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.accountStatus = true, // Por padrão, conta ativa
  }) {
    if (!_isValidEmail(email)) {
      throw ArgumentError('Email inválido: $email');
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? accountStatus, // Adicionado ao copyWith
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountStatus: accountStatus ?? this.accountStatus, // Usado no copyWith
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'accountStatus': accountStatus, // Adicionado ao toJson
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      accountStatus: json['accountStatus'] ?? true, // Adicionado ao fromJson
    );
  }

  static User createSample() {
    return User(
      id: 'sample-id',
      email: 'sample@example.com',
      displayName: 'Sample User',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      accountStatus: true, // Adicionado ao exemplo
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          accountStatus == other.accountStatus; // Adicionado ao operador ==

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      accountStatus.hashCode; // Adicionado ao hashCode
}