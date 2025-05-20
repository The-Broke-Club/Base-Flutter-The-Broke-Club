// services/api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

enum RequestType { get, post, put, delete, patch }

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $message (Code: $statusCode)';
  }
}

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final int maxRetries;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.maxRetries = 3,
  }) : _httpClient = httpClient ?? http.Client();

  Future<Map<String, String>> _getHeaders() async {
    final headers = Map<String, String>.from(defaultHeaders);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('Erro ao obter token: $e');
    }
    
    return headers;
  }

  Future<dynamic> _processResponse(http.Response response) async {
    final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      String errorMessage;
      
      if (responseBody != null && responseBody['message'] != null) {
        errorMessage = responseBody['message'];
      } else if (responseBody != null && responseBody['error'] != null) {
        errorMessage = responseBody['error'];
      } else {
        errorMessage = 'Erro na requisição: ${response.statusCode}';
      }
      
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        data: responseBody,
      );
    }
  }

  Future<dynamic> request({
    required String endpoint,
    required RequestType type,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool retry = true,
  }) async {
    Uri uri = Uri.parse(baseUrl + endpoint);
    
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    
    final headers = await _getHeaders();
    http.Response? response;
    
    int attempts = 0;
    bool success = false;
    dynamic error;
    
    while (!success && attempts < (retry ? maxRetries : 1)) {
      attempts++;
      
      try {
        switch (type) {
          case RequestType.get:
            response = await _httpClient
                .get(uri, headers: headers)
                .timeout(timeout);
            break;
          case RequestType.post:
            response = await _httpClient
                .post(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
                .timeout(timeout);
            break;
          case RequestType.put:
            response = await _httpClient
                .put(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
                .timeout(timeout);
            break;
          case RequestType.delete:
            response = await _httpClient
                .delete(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
                .timeout(timeout);
            break;
          case RequestType.patch:
            response = await _httpClient
                .patch(uri, headers: headers, body: data != null ? jsonEncode(data) : null)
                .timeout(timeout);
            break;
        }
        
        success = true;
      } catch (e) {
        error = e;
        
        // Verifica se deve tentar novamente
        if (!retry || attempts >= maxRetries) {
          break;
        }
        
        // Aguarda antes de tentar novamente
        await Future.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
    
    if (!success) {
      if (error is SocketException) {
        throw ApiException(
          message: 'Não foi possível conectar ao servidor. Verifique sua conexão.',
          statusCode: null,
        );
      } else if (error is TimeoutException) {
        throw ApiException(
          message: 'Tempo de resposta esgotado. Tente novamente.',
          statusCode: null,
        );
      } else {
        throw ApiException(
          message: error.toString(),
          statusCode: null,
        );
      }
    }
    
    return _processResponse(response!);
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    return request(
      endpoint: endpoint,
      type: RequestType.get,
      queryParams: queryParams,
    );
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    return request(
      endpoint: endpoint,
      type: RequestType.post,
      data: data,
    );
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    return request(
      endpoint: endpoint,
      type: RequestType.put,
      data: data,
    );
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? data}) async {
    return request(
      endpoint: endpoint,
      type: RequestType.delete,
      data: data,
    );
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? data}) async {
    return request(
      endpoint: endpoint,
      type: RequestType.patch,
      data: data,
    );
  }

  void close() {
    _httpClient.close();
  }
}