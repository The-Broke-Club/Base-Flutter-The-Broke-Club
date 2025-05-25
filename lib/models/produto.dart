// models/produto.dart
import 'package:uuid/uuid.dart';

class Produto {
  final String id;
  final String nome;
  final String? descricao;
  final double preco;
  final int estoque;
  final String? fornecedorId;
  final String? categoria;
  final DateTime createdAt;
  final DateTime updatedAt;

  Produto({
    required this.id,
    required this.nome,
    this.descricao,
    required this.preco,
    required this.estoque,
    this.fornecedorId,
    this.categoria,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      preco: json['preco'] is int ? json['preco'].toDouble() : json['preco'],
      estoque: json['estoque'],
      fornecedorId: json['fornecedorId'],
      categoria: json['categoria'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'estoque': estoque,
      'fornecedorId': fornecedorId,
      'categoria': categoria,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Produto.create({
    required String nome,
    String? descricao,
    required double preco,
    required int estoque,
    String? fornecedorId,
    String? categoria,
  }) {
    final now = DateTime.now();
    return Produto(
      id: const Uuid().v4(),
      nome: nome,
      descricao: descricao,
      preco: preco,
      estoque: estoque,
      fornecedorId: fornecedorId,
      categoria: categoria,
      createdAt: now,
      updatedAt: now,
    );
  }

  Produto copyWith({
    String? id,
    String? nome,
    String? descricao,
    double? preco,
    int? estoque,
    String? fornecedorId,
    String? categoria,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      estoque: estoque ?? this.estoque,
      fornecedorId: fornecedorId ?? this.fornecedorId,
      categoria: categoria ?? this.categoria,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}