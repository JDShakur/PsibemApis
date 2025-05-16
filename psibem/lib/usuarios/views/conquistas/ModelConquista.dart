import 'package:cloud_firestore/cloud_firestore.dart';

class Conquista {
  final String id;
  final String nome;
  final String descricao;
  final DateTime conquistadoEm;

  Conquista({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.conquistadoEm,
  });

  factory Conquista.fromMap(String id, Map<String, dynamic> data) {
    final timestamp = data['dataDesbloqueio'] as Timestamp?;
    return Conquista(
      id: id,
      nome: data['titulo'] ?? '', // cuidado com nomes divergentes
      descricao: data['descricao'] ?? '',
      conquistadoEm: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}
