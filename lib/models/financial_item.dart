import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Adicionar esta importação

/// Enum para representar diferentes tipos de transações financeiras
enum TransactionType {
  income,      // Receita
  expense,     // Despesa
  transfer,    // Transferência entre contas
  investment,  // Investimento
  withdrawal,  // Saque
  deposit      // Depósito
}

/// Enum para representar a categorização das transações financeiras
enum TransactionCategory {
  food,          // Alimentação
  housing,       // Moradia
  transportation, // Transporte
  utilities,     // Serviços públicos (água, luz, etc.)
  healthcare,    // Saúde
  entertainment, // Entretenimento
  education,     // Educação
  shopping,      // Compras
  salary,        // Salário
  investment,    // Investimento
  loans,         // Empréstimos
  other          // Outros
}

/// Enum para representar o status de pagamento de uma transação
enum PaymentStatus {
  pending,      // Pendente
  completed,    // Concluído
  cancelled,    // Cancelado
  scheduled,    // Agendado
  processing,   // Em processamento
  failed        // Falhou
}

/// Enum para representar o método de pagamento utilizado
enum PaymentMethod {
  cash,         // Dinheiro
  creditCard,   // Cartão de crédito
  debitCard,    // Cartão de débito
  bankTransfer, // Transferência bancária
  pix,          // PIX
  onlinePayment, // Pagamento online
  other         // Outros
}

/// Classe para representar um item financeiro (transação)
class FinancialItem {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String? accountId;  // Identificador da conta associada
  final String? notes;      // Notas adicionais sobre a transação
  final String? attachmentUrl; // URL para um anexo (comprovante, nota fiscal, etc.)
  final bool isRecurring;   // Indica se é uma transação recorrente
  final int? recurrenceInterval; // Intervalo de recorrência em dias (se aplicável)
  final String? recurrenceGroupId; // Identificador para agrupar transações recorrentes
  final DateTime createdAt;  // Data de criação do registro
  final DateTime updatedAt;  // Data da última atualização

  FinancialItem({
    String? id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.status = PaymentStatus.completed,
    this.paymentMethod = PaymentMethod.other,
    this.accountId,
    this.notes,
    this.attachmentUrl,
    this.isRecurring = false,
    this.recurrenceInterval,
    this.recurrenceGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Retorna se a transação é uma despesa (valor negativo)
  bool get isExpense => type == TransactionType.expense || 
                        type == TransactionType.withdrawal;

  /// Retorna se a transação é uma receita (valor positivo)
  bool get isIncome => type == TransactionType.income || 
                       type == TransactionType.deposit;

  /// Retorna se a transação está ativa (não cancelada ou falha)
  bool get isActive => status != PaymentStatus.cancelled && 
                       status != PaymentStatus.failed;

  /// Retorna se a transação está pendente ou agendada
  bool get isPending => status == PaymentStatus.pending || 
                        status == PaymentStatus.scheduled;

  /// Formata o valor da transação como moeda local
  String getFormattedAmount([String locale = 'pt_BR']) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: locale,
      symbol: _getCurrencySymbol(locale),
    );
    return formatter.format(amount);
  }

  /// Retorna o símbolo da moeda com base na localização
  String _getCurrencySymbol(String locale) {
    switch (locale.split('_')[0]) {
      case 'pt':
        return 'R\$';
      case 'en':
        return '\$';
      case 'es':
        return '€';
      default:
        return 'R\$';
    }
  }

  /// Retorna a data formatada no padrão da localização
  String getFormattedDate([String locale = 'pt_BR']) {
    final DateFormat formatter = DateFormat.yMd(locale);
    return formatter.format(date);
  }

  /// Retorna a cor associada ao tipo de transação
  Color getTypeColor() {
    switch (type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.transfer:
        return Colors.blue;
      case TransactionType.investment:
        return Colors.purple;
      case TransactionType.withdrawal:
        return Colors.orange;
      case TransactionType.deposit:
        return Colors.teal;
      }
  }

  /// Retorna o ícone associado à categoria
  IconData getCategoryIcon() {
    switch (category) {
      case TransactionCategory.food:
        return Icons.restaurant;
      case TransactionCategory.housing:
        return Icons.home;
      case TransactionCategory.transportation:
        return Icons.directions_car;
      case TransactionCategory.utilities:
        return Icons.power;
      case TransactionCategory.healthcare:
        return Icons.medical_services;
      case TransactionCategory.entertainment:
        return Icons.movie;
      case TransactionCategory.education:
        return Icons.school;
      case TransactionCategory.shopping:
        return Icons.shopping_cart;
      case TransactionCategory.salary:
        return Icons.work;
      case TransactionCategory.investment:
        return Icons.trending_up;
      case TransactionCategory.loans:
        return Icons.money;
      case TransactionCategory.other:
        return Icons.more_horiz;
      }
  }

  /// Retorna o nome da categoria em português
  String getCategoryName() {
    switch (category) {
      case TransactionCategory.food:
        return 'Alimentação';
      case TransactionCategory.housing:
        return 'Moradia';
      case TransactionCategory.transportation:
        return 'Transporte';
      case TransactionCategory.utilities:
        return 'Serviços Públicos';
      case TransactionCategory.healthcare:
        return 'Saúde';
      case TransactionCategory.entertainment:
        return 'Entretenimento';
      case TransactionCategory.education:
        return 'Educação';
      case TransactionCategory.shopping:
        return 'Compras';
      case TransactionCategory.salary:
        return 'Salário';
      case TransactionCategory.investment:
        return 'Investimento';
      case TransactionCategory.loans:
        return 'Empréstimos';
      case TransactionCategory.other:
        return 'Outros';
      }
  }

  /// Retorna o nome do tipo de transação em português
  String getTypeName() {
    switch (type) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
      case TransactionType.transfer:
        return 'Transferência';
      case TransactionType.investment:
        return 'Investimento';
      case TransactionType.withdrawal:
        return 'Saque';
      case TransactionType.deposit:
        return 'Depósito';
      }
  }

  /// Retorna o nome do status em português
  String getStatusName() {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.completed:
        return 'Concluído';
      case PaymentStatus.cancelled:
        return 'Cancelado';
      case PaymentStatus.scheduled:
        return 'Agendado';
      case PaymentStatus.processing:
        return 'Em processamento';
      case PaymentStatus.failed:
        return 'Falhou';
      }
  }

  /// Retorna o nome do método de pagamento em português
  String getPaymentMethodName() {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Dinheiro';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.debitCard:
        return 'Cartão de Débito';
      case PaymentMethod.bankTransfer:
        return 'Transferência Bancária';
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.onlinePayment:
        return 'Pagamento Online';
      case PaymentMethod.other:
        return 'Outro';
      }
  }

  /// Fábrica para criar um FinancialItem a partir de um JSON
  factory FinancialItem.fromJson(Map<String, dynamic> json) {
    return FinancialItem(
      id: json['id'],
      userId: json['userId'],
      description: json['description'],
      amount: json['amount']?.toDouble() ?? 0.0,
      date: DateTime.parse(json['date']),
      type: TransactionType.values[json['type'] ?? 0],
      category: TransactionCategory.values[json['category'] ?? 0],
      status: PaymentStatus.values[json['status'] ?? 0],
      paymentMethod: PaymentMethod.values[json['paymentMethod'] ?? 0],
      accountId: json['accountId'],
      notes: json['notes'],
      attachmentUrl: json['attachmentUrl'],
      isRecurring: json['isRecurring'] ?? false,
      recurrenceInterval: json['recurrenceInterval'],
      recurrenceGroupId: json['recurrenceGroupId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Converte o FinancialItem para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.index,
      'category': category.index,
      'status': status.index,
      'paymentMethod': paymentMethod.index,
      'accountId': accountId,
      'notes': notes,
      'attachmentUrl': attachmentUrl,
      'isRecurring': isRecurring,
      'recurrenceInterval': recurrenceInterval,
      'recurrenceGroupId': recurrenceGroupId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cria uma cópia do item financeiro com campos atualizados
  FinancialItem copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    String? accountId,
    String? notes,
    String? attachmentUrl,
    bool? isRecurring,
    int? recurrenceInterval,
    String? recurrenceGroupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinancialItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountId: accountId ?? this.accountId,
      notes: notes ?? this.notes,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'FinancialItem(id: $id, description: $description, amount: $amount, date: ${date.toIso8601String()}, '
           'type: ${type.toString()}, category: ${category.toString()})';
  }
}

/// Classe para gerenciar uma coleção de itens financeiros
class FinancialItemCollection {
  final List<FinancialItem> _items = [];
  final String userId;

  FinancialItemCollection({required this.userId});

  /// Obtém todos os itens
  List<FinancialItem> get items => List.unmodifiable(_items);

  /// Adiciona um item à coleção
  void addItem(FinancialItem item) {
    if (item.userId != userId) {
      throw Exception('O item não pertence a este usuário');
    }
    _items.add(item);
  }

  /// Remove um item da coleção
  bool removeItem(String itemId) {
    final initialLength = _items.length;
    _items.removeWhere((item) => item.id == itemId);
    return _items.length < initialLength;
  }

  /// Atualiza um item existente
  bool updateItem(FinancialItem updatedItem) {
    if (updatedItem.userId != userId) {
      throw Exception('O item não pertence a este usuário');
    }
    
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index >= 0) {
      _items[index] = updatedItem;
      return true;
    }
    return false;
  }

  /// Encontra um item pelo ID
  FinancialItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtra itens por tipo de transação
  List<FinancialItem> filterByType(TransactionType type) {
    return _items.where((item) => item.type == type).toList();
  }

  /// Filtra itens por categoria
  List<FinancialItem> filterByCategory(TransactionCategory category) {
    return _items.where((item) => item.category == category).toList();
  }

  /// Filtra itens por status
  List<FinancialItem> filterByStatus(PaymentStatus status) {
    return _items.where((item) => item.status == status).toList();
  }

  /// Filtra itens por período
  List<FinancialItem> filterByPeriod(DateTime start, DateTime end) {
    return _items.where((item) => 
      item.date.isAfter(start.subtract(const Duration(days: 1))) && 
      item.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Filtra itens por valor (intervalo)
  List<FinancialItem> filterByAmountRange(double min, double max) {
    return _items.where((item) => 
      item.amount >= min && item.amount <= max
    ).toList();
  }

  /// Obtém apenas despesas
  List<FinancialItem> get expenses => 
    _items.where((item) => item.isExpense).toList();

  /// Obtém apenas receitas
  List<FinancialItem> get incomes => 
    _items.where((item) => item.isIncome).toList();

  /// Obtém o total de despesas
  double get totalExpenses => 
    expenses.fold(0, (sum, item) => sum + item.amount);

  /// Obtém o total de receitas
  double get totalIncomes => 
    incomes.fold(0, (sum, item) => sum + item.amount);

  /// Obtém o saldo (receitas - despesas)
  double get balance => totalIncomes - totalExpenses;

  /// Obtém itens agrupados por categoria
  Map<TransactionCategory, List<FinancialItem>> get itemsByCategory {
    final result = <TransactionCategory, List<FinancialItem>>{};
    for (final category in TransactionCategory.values) {
      result[category] = filterByCategory(category);
    }
    return result;
  }

  /// Obtém o total por categoria
  Map<TransactionCategory, double> get totalByCategory {
    final result = <TransactionCategory, double>{};
    for (final category in TransactionCategory.values) {
      final categoryItems = filterByCategory(category);
      result[category] = categoryItems.fold(0, (sum, item) => sum + item.amount);
    }
    return result;
  }

  /// Obtém itens agrupados por mês
  Map<String, List<FinancialItem>> get itemsByMonth {
    final result = <String, List<FinancialItem>>{};
    for (final item in _items) {
      final monthKey = '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}';
      if (!result.containsKey(monthKey)) {
        result[monthKey] = [];
      }
      result[monthKey]!.add(item);
    }
    return result;
  }

  /// Obtém o total por mês
  Map<String, double> get totalByMonth {
    final result = <String, double>{};
    final byMonth = itemsByMonth;
    
    for (final entry in byMonth.entries) {
      result[entry.key] = entry.value.fold(0, (sum, item) => sum + item.amount);
    }
    return result;
  }

  /// Retorna uma representação em JSON da coleção
  String toJson() {
    final jsonList = _items.map((item) => item.toJson()).toList();
    return json.encode(jsonList);
  }

  /// Cria uma coleção a partir de uma string JSON
  factory FinancialItemCollection.fromJson(String jsonString, String userId) {
    final collection = FinancialItemCollection(userId: userId);
    final jsonList = json.decode(jsonString) as List;
    
    for (final itemJson in jsonList) {
      collection.addItem(FinancialItem.fromJson(itemJson));
    }
    
    return collection;
  }
}

/// Classe para gerenciar o estado dos itens financeiros
class FinancialItemState with ChangeNotifier {
  final String userId;
  final List<FinancialItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  FinancialItemState({required this.userId});

  /// Getters
  List<FinancialItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Métodos para manipular os itens
  Future<bool> addItem(FinancialItem item) async {
    try {
      if (item.userId != userId) {
        throw Exception('O item não pertence a este usuário');
      }
      
      _isLoading = true;
      notifyListeners();
      
      // Aqui, em uma aplicação real, você enviaria o item para uma API
      // e só depois adicionaria à lista local
      await Future.delayed(const Duration(milliseconds: 500)); // Simulação de API
      
      _items.add(item);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar item: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(FinancialItem updatedItem) async {
    try {
      if (updatedItem.userId != userId) {
        throw Exception('O item não pertence a este usuário');
      }
      
      _isLoading = true;
      notifyListeners();
      
      // Simulação de API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index >= 0) {
        _items[index] = updatedItem;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Item não encontrado');
      }
    } catch (e) {
      _errorMessage = 'Erro ao atualizar item: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeItem(String itemId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Simulação de API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final initialLength = _items.length;
      _items.removeWhere((item) => item.id == itemId);
      final removed = _items.length < initialLength;
      
      if (!removed) {
        throw Exception('Item não encontrado');
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erro ao remover item: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadItems() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      // Simulação de API - em uma aplicação real, você buscaria os dados de uma API
      await Future.delayed(const Duration(seconds: 1));
      
      // Para simular dados, criamos alguns itens de exemplo
      _items.clear();
      _items.addAll(_generateSampleItems());
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao carregar itens: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gera itens de exemplo para demonstração
  List<FinancialItem> _generateSampleItems() {
    final now = DateTime.now();
    return [
      FinancialItem(
        userId: userId,
        description: 'Salário',
        amount: 5000.0,
        date: DateTime(now.year, now.month, 5),
        type: TransactionType.income,
        category: TransactionCategory.salary,
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      FinancialItem(
        userId: userId,
        description: 'Aluguel',
        amount: 1200.0,
        date: DateTime(now.year, now.month, 10),
        type: TransactionType.expense,
        category: TransactionCategory.housing,
        paymentMethod: PaymentMethod.bankTransfer,
      ),
      FinancialItem(
        userId: userId,
        description: 'Supermercado',
        amount: 450.0,
        date: DateTime(now.year, now.month, 15),
        type: TransactionType.expense,
        category: TransactionCategory.food,
        paymentMethod: PaymentMethod.creditCard,
      ),
      FinancialItem(
        userId: userId,
        description: 'Conta de Energia',
        amount: 180.0,
        date: DateTime(now.year, now.month, 20),
        type: TransactionType.expense,
        category: TransactionCategory.utilities,
        paymentMethod: PaymentMethod.pix,
      ),
      FinancialItem(
        userId: userId,
        description: 'Academia',
        amount: 90.0,
        date: DateTime(now.year, now.month, 25),
        type: TransactionType.expense,
        category: TransactionCategory.healthcare,
        paymentMethod: PaymentMethod.debitCard,
      ),
    ];
  }

  /// Limpa mensagens de erro
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Estatísticas e cálculos
  double get totalIncome {
    return _items
        .where((item) => item.isIncome && item.isActive)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _items
        .where((item) => item.isExpense && item.isActive)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpense;

  /// Agrupamento por categoria
  Map<TransactionCategory, double> get expensesByCategory {
    final result = <TransactionCategory, double>{};
    
    for (final item in _items.where((item) => item.isExpense && item.isActive)) {
      result[item.category] = (result[item.category] ?? 0) + item.amount;
    }
    
    return result;
  }

  /// Agrupamento por mês
  Map<String, double> get balanceByMonth {
    final result = <String, double>{};
    
    for (final item in _items.where((item) => item.isActive)) {
      final monthKey = '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}';
      final amount = item.isIncome ? item.amount : -item.amount;
      result[monthKey] = (result[monthKey] ?? 0) + amount;
    }
    
    return result;
  }
}

/// Widget Provider para disponibilizar itens financeiros em toda a aplicação
class FinancialItemProvider extends StatelessWidget {
  final Widget child;
  final String userId;

  const FinancialItemProvider({
    super.key,
    required this.child,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final state = FinancialItemState(userId: userId);
        // Carrega os itens iniciais
        state.loadItems();
        return state;
      },
      child: child,
    );
  }
}