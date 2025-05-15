import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> salvarAnotacao(String usuarioUid, String titulo, String conteudo, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost/projects/tcc/Phpigni/public/api/salvar-anotacao'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usuario_uid': usuarioUid,
        'titulo': titulo,
        'conteudo': conteudo,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('Anotação salva com sucesso: ${responseData['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
    } else {
      throw Exception('Falha ao salvar anotação: ${response.body}');
    }
  } catch (e) {
    print('Erro ao salvar anotação: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao salvar anotação: $e')),
    );
  }
}
Future<void> compartilharAnotacao(String anotacaoId, String psicologoUid, BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost/projects/tcc/Phpigni/public/api/compartilhar-anotacao'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'anotacao_id': anotacaoId,
        'psicologo_uid': psicologoUid,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Anotação compartilhada com sucesso: ${responseData['message']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
    } else {
      throw Exception('Falha ao compartilhar anotação: ${response.body}');
    }
  } catch (e) {
    print('Erro ao compartilhar anotação: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao compartilhar anotação: $e')),
    );
  }
}
Future<List<dynamic>> listarAnotacoes(String usuarioUid) async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost/projects/tcc/Phpigni/public/api/listar-anotacoes/$usuarioUid'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar anotações: ${response.body}');
    }
  } catch (e) {
    print('Erro ao carregar anotações: $e');
    throw Exception('Erro ao carregar anotações: $e');
  }
}