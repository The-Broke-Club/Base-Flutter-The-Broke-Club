import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/invoice.dart';

class InvoiceService {
  static Database? _database;
  static const String _tableName = 'invoices';

  // Singleton pattern
  static final InvoiceService _instance = InvoiceService._internal();
  factory InvoiceService() => _instance;
  InvoiceService._internal();

  // Getter para o banco de dados
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Inicializar o banco de dados
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'invoices.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Criar a tabela
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        dueDate TEXT NOT NULL,
        status TEXT NOT NULL,
        category TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  // Buscar todas as faturas
  Future<List<Invoice>> getInvoices() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return _mapToInvoice(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar faturas: $e');
    }
  }

  // Buscar fatura por ID
  Future<Invoice?> getInvoiceById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return _mapToInvoice(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar fatura: $e');
    }
  }

  // Adicionar nova fatura
  Future<void> addInvoice(Invoice invoice) async {
    try {
      final db = await database;
      await db.insert(
        _tableName,
        _invoiceToMap(invoice),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Erro ao adicionar fatura: $e');
    }
  }

  // Atualizar fatura existente
  Future<void> updateInvoice(Invoice invoice) async {
    try {
      final db = await database;
      await db.update(
        _tableName,
        _invoiceToMap(invoice),
        where: 'id = ?',
        whereArgs: [invoice.id],
      );
    } catch (e) {
      throw Exception('Erro ao atualizar fatura: $e');
    }
  }

  // Deletar fatura
  Future<void> deleteInvoice(String id) async {
    try {
      final db = await database;
      await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Erro ao deletar fatura: $e');
    }
  }

  // Buscar faturas por nome ou descrição
  Future<List<Invoice>> searchInvoices(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return _mapToInvoice(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar faturas: $e');
    }
  }

  // Buscar faturas por status
  Future<List<Invoice>> getInvoicesByStatus(String status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return _mapToInvoice(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar faturas por status: $e');
    }
  }

  // Buscar faturas por categoria
  Future<List<Invoice>> getInvoicesByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return _mapToInvoice(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar faturas por categoria: $e');
    }
  }

  // Buscar faturas vencidas
  Future<List<Invoice>> getOverdueInvoices() async {
    try {
      final db = await database;
      final now = DateTime.now().toIso8601String();
      
      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'dueDate < ? AND status != ?',
        whereArgs: [now, 'paid'],
        orderBy: 'dueDate ASC',
      );

      return List.generate(maps.length, (i) {
        return _mapToInvoice(maps[i]);
      });
    } catch (e) {
      throw Exception('Erro ao buscar faturas vencidas: $e');
    }
  }

  // Calcular total das faturas
  Future<double> getTotalAmount() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM $_tableName',
      );
      
      return result.first['total']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Erro ao calcular total: $e');
    }
  }

  // Calcular total por status
  Future<double> getTotalByStatus(String status) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM $_tableName WHERE status = ?',
        [status],
      );
      
      return result.first['total']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Erro ao calcular total por status: $e');
    }
  }

  // Limpar todas as faturas (para testes)
  Future<void> clearAllInvoices() async {
    try {
      final db = await database;
      await db.delete(_tableName);
    } catch (e) {
      throw Exception('Erro ao limpar faturas: $e');
    }
  }

  // Fechar o banco de dados
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Métodos auxiliares para conversão

  // Converter Map para Invoice
  Invoice _mapToInvoice(Map<String, dynamic> map) {
  return Invoice(
    id: map['id'] ?? '',
    title: map['title'] ?? '', // <- obrigatório
    amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
    dueDate: map['dueDate'] != null
        ? DateTime.parse(map['dueDate'])
        : DateTime.now(),
    isPaid: map['isPaid'] ?? false, // <- obrigatório
    description: map['description'] ?? '',
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : DateTime.now(),
  );
}

    // Converter Invoice para Map
    Map<String, dynamic> _invoiceToMap(Invoice invoice) {
    return {
      'id': invoice.id,
      'title': invoice.title,
      'description': invoice.description ?? '',
      'amount': invoice.amount,
      'dueDate': invoice.dueDate.toIso8601String(),
      'isPaid': invoice.isPaid,
      'createdAt': invoice.createdAt.toIso8601String(),
      'updatedAt': invoice.updatedAt.toIso8601String(),
      };
    }
}