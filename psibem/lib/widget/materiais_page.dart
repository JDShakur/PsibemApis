import 'package:flutter/material.dart';

class MateriaisPage extends StatelessWidget {
  final List<String> materiais;

  // Construtor que recebe a lista de materiais
  const MateriaisPage({super.key, required this.materiais});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Materiais de Apoio"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: materiais.isEmpty
            ? Text(
                "Nenhum material disponível por enquanto.",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              )
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: materiais.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(materiais[index]),
                    ),
                  );
                },
              ),
      ),
    );
  }
}