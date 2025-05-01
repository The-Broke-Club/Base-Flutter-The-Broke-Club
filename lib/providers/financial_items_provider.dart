import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Classe que representa um item financeiro
class FinancialItem {
  String id;
  String name;
  String description;
  double value;
  DateTime date;
  String category;
  bool isExpense;
  String? imageUrl;
  String ownerId;

  FinancialItem({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.date,
    required this.category,
    required this.isExpense,
    required this.ownerId,
    this.imageUrl,
  });

  factory FinancialItem.fromJson(Map<String, dynamic> json) {
    return FinancialItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      value: (json['value'] is int) 
          ? (json['value'] as int).toDouble() 
          : json['value']?.toDouble() ?? 0.0,
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : DateTime.now(),
      category: json['category'] ?? 'Outros',
      isExpense: json['isExpense'] ?? true,
      ownerId: json['ownerId'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'value': value,
      'date': date.toIso8601String(),
      'category': category,
      'isExpense': isExpense,
      'ownerId': ownerId,
      'imageUrl': imageUrl,
    };
  }

  // Método para criar uma cópia com alterações
  FinancialItem copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    DateTime? date,
    String? category,
    bool? isExpense,
    String? imageUrl,
    String? ownerId,
  }) {
    return FinancialItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}

/// Classe base para operações seguras e tratamento de erros
abstract class SafeOperationHandler with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Executa uma operação de forma segura com tratamento de erros e loading
  Future<T?> safeOperation<T>(
    Future<T> Function() operation, {
    String errorPrefix = 'Erro na operação',
    bool notifyOnStart = true,
    bool notifyOnComplete = true,
  }) async {
    if (notifyOnStart) {
      setLoading(true);
      clearError();
    }

    try {
      final result = await operation();
      return result;
    } catch (e) {
      final errorMsg = '$errorPrefix: ${e.toString()}';
      setError(errorMsg);
      print('SafeOperation error: $errorMsg'); // Log para debugging
      return null;
    } finally {
      if (notifyOnComplete) {
        setLoading(false);
      }
    }
  }
}

/// Gerenciador de persistência para os itens financeiros
class FinancialStorage {
  static const String _storageKey = 'financial_items';

  /// Salva itens na persistência local
  static Future<bool> saveItems(List<FinancialItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = json.encode(
        items.map((item) => item.toJson()).toList()
      );
      return await prefs.setString(_storageKey, itemsJson);
    } catch (e) {
      throw Exception('Falha ao salvar dados: ${e.toString()}');
    }
  }

  /// Carrega itens da persistência local
  static Future<List<FinancialItem>> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getString(_storageKey);
      
      if (itemsJson != null) {
        final itemsList = json.decode(itemsJson) as List;
        return itemsList
            .map((item) => FinancialItem.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Falha ao carregar dados: ${e.toString()}');
    }
  }

  /// Remove todos os itens da persistência
  static Future<bool> clearItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('Falha ao limpar dados: ${e.toString()}');
    }
  }
}

/// Provedor de itens financeiros com funcionalidades avançadas e gerenciamento de estado
class FinancialItemsProvider extends SafeOperationHandler {
  List<FinancialItem> _items = [];

  /// Todos os itens cadastrados
  List<FinancialItem> get items => List.unmodifiable(_items);
  
  /// Apenas as despesas
  List<FinancialItem> get expenses => 
      _items.where((item) => item.isExpense).toList();
  
  /// Apenas as receitas
  List<FinancialItem> get incomes => 
      _items.where((item) => !item.isExpense).toList();

  /// Total de despesas
  double get totalExpenses => 
      expenses.fold(0, (sum, item) => sum + item.value);
  
  /// Total de receitas
  double get totalIncomes => 
      incomes.fold(0, (sum, item) => sum + item.value);
  
  /// Saldo (receitas - despesas)
  double get balance => totalIncomes - totalExpenses;

  /// Categorias únicas presentes nos itens
  Set<String> get categories => 
      _items.map((item) => item.category).toSet();

  /// Inicializa o provider carregando os dados persistidos
  FinancialItemsProvider() {
    loadItems();
  }

  /// Carrega os itens salvos
  Future<void> loadItems() async {
    await safeOperation(() async {
      _items = await FinancialStorage.loadItems();
      return true;
    }, errorPrefix: 'Erro ao carregar itens');
  }

  /// Salva os itens atuais
  Future<bool> _saveItems() async {
    final result = await safeOperation(() async {
      return await FinancialStorage.saveItems(_items);
    }, errorPrefix: 'Erro ao salvar itens');
    
    return result ?? false;
  }

  /// Valida um item financeiro
  ValidationResult validateItem(FinancialItem item) {
    if (item.id.isEmpty) {
      return ValidationResult(false, 'ID do item não pode ser vazio');
    }
    
    if (item.name.isEmpty) {
      return ValidationResult(false, 'Nome do item é obrigatório');
    }
    
    if (item.value <= 0) {
      return ValidationResult(false, 'Valor deve ser maior que zero');
    }
    
    if (item.category.isEmpty) {
      return ValidationResult(false, 'Categoria é obrigatória');
    }
    
    if (item.ownerId.isEmpty) {
      return ValidationResult(false, 'ID do proprietário é obrigatório');
    }
    
    return ValidationResult(true, null);
  }

  /// Adiciona um novo item financeiro
  Future<bool> addItem(FinancialItem item) async {
    clearError();
    
    // Validação preliminar
    final validation = validateItem(item);
    if (!validation.isValid) {
      setError(validation.errorMessage);
      return false;
    }
    
    final result = await safeOperation(() async {
      _items.add(item);
      final success = await _saveItems();
      notifyListeners();
      return success;
    }, errorPrefix: 'Erro ao adicionar item');
    
    return result ?? false;
  }

  /// Busca um item pelo ID
  FinancialItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Atualiza um item existente
  Future<bool> updateItem(FinancialItem updatedItem) async {
    clearError();
    
    // Validação preliminar
    final validation = validateItem(updatedItem);
    if (!validation.isValid) {
      setError(validation.errorMessage);
      return false;
    }
    
    final result = await safeOperation(() async {
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      
      if (index >= 0) {
        _items[index] = updatedItem;
        final success = await _saveItems();
        notifyListeners();
        return success;
      } else {
        setError('Item não encontrado para atualização');
        return false;
      }
    }, errorPrefix: 'Erro ao atualizar item');
    
    return result ?? false;
  }

  /// Remove um item pelo ID
  Future<bool> removeItem(String id) async {
    final result = await safeOperation(() async {
      final initialLength = _items.length;
      _items.removeWhere((item) => item.id == id);
      
      if (_items.length < initialLength) {
        final success = await _saveItems();
        notifyListeners();
        return success;
      } else {
        setError('Item não encontrado para remoção');
        return false;
      }
    }, errorPrefix: 'Erro ao remover item');
    
    return result ?? false;
  }

  /// Filtra itens por categoria
  List<FinancialItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  /// Filtra itens por período
  List<FinancialItem> getItemsByPeriod(DateTime start, DateTime end) {
    // Validação de datas
    if (end.isBefore(start)) {
      setError('A data final deve ser posterior à data inicial');
      return [];
    }
    
    // Ajuste para incluir todo o dia final
    final adjustedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    return _items.where((item) => 
      !item.date.isBefore(start) && 
      !item.date.isAfter(adjustedEnd)
    ).toList();
  }

  /// Adiciona vários itens de uma vez
  Future<bool> addItems(List<FinancialItem> newItems) async {
    clearError();
    
    // Validação preliminar de todos os itens
    for (final item in newItems) {
      final validation = validateItem(item);
      if (!validation.isValid) {
        setError('${validation.errorMessage} no item "${item.name}"');
        return false;
      }
    }
    
    final result = await safeOperation(() async {
      _items.addAll(newItems);
      final success = await _saveItems();
      notifyListeners();
      return success;
    }, errorPrefix: 'Erro ao adicionar múltiplos itens');
    
    return result ?? false;
  }

  /// Remove itens com base em filtros
  Future<bool> removeItemsByFilter({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? ownerId,
    bool? isExpense,
  }) async {
    final result = await safeOperation<bool>(() async {
      final initialLength = _items.length;
      
      // Ajuste para incluir todo o dia final
      final adjustedEnd = endDate != null 
          ? DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59)
          : null;
      
      _items = _items.where((item) {
        // Verificar se o item atende a todos os critérios de filtro
        if (category != null && item.category != category) return false;
        
        if (startDate != null && item.date.isBefore(startDate)) return false;
        
        if (adjustedEnd != null && item.date.isAfter(adjustedEnd)) return false;
        
        if (ownerId != null && item.ownerId != ownerId) return false;
        
        if (isExpense != null && item.isExpense != isExpense) return false;
        
        return true;
      }).toList();
      
      if (_items.length < initialLength) {
        final success = await _saveItems();
        notifyListeners();
        return success;
      } else {
        return false; // Nenhum item foi removido
      }
    }, errorPrefix: 'Erro ao filtrar e remover itens');
    
    // Retorna false em caso de erro (quando result é nulo)
    return result ?? false;
  }

  /// Remove todos os itens
  Future<bool> clearItems() async {
    final result = await safeOperation(() async {
      _items = [];
      final success = await FinancialStorage.clearItems();
      notifyListeners();
      return success;
    }, errorPrefix: 'Erro ao limpar todos os itens');
    
    return result ?? false;
  }

  /// Obtém estatísticas por categoria
  Map<String, CategoryStats> getCategoryStatistics() {
    final stats = <String, CategoryStats>{};
    
    for (final category in categories) {
      final categoryItems = getItemsByCategory(category);
      final expenses = categoryItems.where((item) => item.isExpense).toList();
      final incomes = categoryItems.where((item) => !item.isExpense).toList();
      
      stats[category] = CategoryStats(
        totalExpenses: expenses.fold(0.0, (sum, item) => sum + item.value),
        totalIncomes: incomes.fold(0.0, (sum, item) => sum + item.value),
        itemCount: categoryItems.length,
      );
    }
    
    return stats;
  }

  /// Obtém estatísticas mensais para um determinado ano
  List<MonthlyStats> getMonthlyStatistics(int year) {
    final monthlyStats = List<MonthlyStats>.generate(
      12,
      (month) => MonthlyStats(
        year: year,
        month: month + 1,
        totalExpenses: 0,
        totalIncomes: 0,
        items: [],
      ),
    );
    
    for (final item in _items) {
      if (item.date.year == year) {
        final monthIndex = item.date.month - 1;
        monthlyStats[monthIndex].items.add(item);
        
        if (item.isExpense) {
          monthlyStats[monthIndex].totalExpenses += item.value;
        } else {
          monthlyStats[monthIndex].totalIncomes += item.value;
        }
      }
    }
    
    return monthlyStats;
  }
}

/// Classe para resultado de validação
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  ValidationResult(this.isValid, this.errorMessage);
}

/// Classe para estatísticas de categoria
class CategoryStats {
  final double totalExpenses;
  final double totalIncomes;
  final int itemCount;
  
  double get balance => totalIncomes - totalExpenses;
  
  CategoryStats({
    required this.totalExpenses,
    required this.totalIncomes,
    required this.itemCount,
  });
}

/// Classe para estatísticas mensais
class MonthlyStats {
  final int year;
  final int month;
  double totalExpenses;
  double totalIncomes;
  final List<FinancialItem> items;
  
  double get balance => totalIncomes - totalExpenses;
  
  MonthlyStats({
    required this.year,
    required this.month,
    required this.totalExpenses,
    required this.totalIncomes,
    required this.items,
  });
}