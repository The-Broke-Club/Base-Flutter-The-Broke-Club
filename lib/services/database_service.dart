import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveItems(List<Map<String, dynamic>> items, String userId) async {
    try {
      final batch = _db.batch();
      final collection = _db.collection('users').doc(userId).collection('items');

      for (var item in items) {
        final docRef = collection.doc(item['id']);
        batch.set(docRef, item);
      }

      await batch.commit();
    } catch (e) {
      print('Erro ao salvar itens: $e');
      rethrow;
    }
  }
}