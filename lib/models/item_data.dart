import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemData {
  final String name;
  final double amount;
  final String date;
  final IconData icon;

  ItemData({
    required this.name,
    required this.amount,
    required this.date,
    required this.icon,
  });

  static List<ItemData> generateSampleItems() {
    final formatter = DateFormat('dd/MM/yyyy');
    return [
      ItemData(
        name: 'Supermercado',
        amount: 150.00,
        date: formatter.format(DateTime.now().subtract(const Duration(days: 1))),
        icon: Icons.shopping_cart,
      ),
      ItemData(
        name: 'Conta de Luz',
        amount: 200.00,
        date: formatter.format(DateTime.now().subtract(const Duration(days: 2))),
        icon: Icons.lightbulb,
      ),
      ItemData(
        name: 'Internet',
        amount: 100.00,
        date: formatter.format(DateTime.now().subtract(const Duration(days: 3))),
        icon: Icons.wifi,
      ),
    ];
  }
}