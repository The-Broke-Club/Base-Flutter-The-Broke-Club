import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>().map((json) => {
              'id': json['id'].toString(),
              'name': json['title'],
              'description': json['body'],
            }).toList();
      } else {
        throw Exception('Falha ao carregar itens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na chamada da API: $e');
      rethrow;
    }
  }
}