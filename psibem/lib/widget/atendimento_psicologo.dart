import 'package:cloud_firestore/cloud_firestore.dart';

class Atendimento {
  final String id;
  final String paciente;
  final DateTime dataHora;
  final String? observacoes;

  Atendimento({
    required this.id,
    required this.paciente,
    required this.dataHora,
    this.observacoes,
  });

  factory Atendimento.fromMap(Map<String, dynamic> map, String id) {
    return Atendimento(
      id: id,
      paciente: map['paciente'] ?? '',
      dataHora: (map['dataHora'] as Timestamp).toDate(),
      observacoes: map['observacoes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paciente': paciente,
      'dataHora': Timestamp.fromDate(dataHora),
      'observacoes': observacoes,
    };
  }
}