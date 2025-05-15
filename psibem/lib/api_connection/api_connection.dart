// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Use seu IP local
  static const String _baseUrl = 'http://192.168.1.15/projects/tcc/Phpigni/public';
  final HttpClient _httpClient = HttpClient();
  final String? token;

  ApiService({this.token});

  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      if (kDebugMode) {
        print('Buscando dados do usuário UID: $uid');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/check-user'), 
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'uid': uid}),
      );

      if (kDebugMode) {
        print('Resposta da API: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Falha ao carregar dados do usuário: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro em getUserData: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserData(
      String uid, Map<String, dynamic> data) async {
    try {
      final payload = {'uid': uid, ...data};

      if (kDebugMode) {
        print('Enviando atualização para UID: $uid');
        print('Dados: $payload');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/update-user'), // Ajuste o path
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print(
            'Resposta da atualização: ${response.statusCode} - ${response.body}');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao atualizar: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro em updateUserData: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      final request = await _httpClient.deleteUrl(Uri.parse('$_baseUrl/users/$uid'));
      request.headers.set('Content-Type', 'application/json');
      
      final response = await request.close()
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Falha ao excluir usuário: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sem conexão com o servidor');
    } on TimeoutException {
      throw Exception('Tempo de conexão esgotado');
    } catch (e) {
      throw Exception('Erro ao excluir usuário: ${e.toString()}');
    } finally {
      _httpClient.close();
    }
  }
 Future<Map<String, dynamic>> updatePassword(String uid, String newPassword) async {
  final url = Uri.parse('http://192.168.1.15/projects/tcc/Phpigni/public/api/update-password');
  
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'new_password': newPassword
      }),
    ).timeout(const Duration(seconds: 5));

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': responseData,
      };
    } else {
      throw Exception(responseData['message'] ?? 'Falha ao atualizar senha');
    }
  } on SocketException {
    throw Exception('Sem conexão com o servidor');
  } on TimeoutException {
    throw Exception('Tempo de conexão esgotado');
  } catch (e) {
    debugPrint('Erro no updatePassword: $e');
    throw Exception('Erro ao atualizar senha: ${e.toString()}');
  }
}
}
 

