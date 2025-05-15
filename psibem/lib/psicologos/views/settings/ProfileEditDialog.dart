import 'package:flutter/material.dart';

class ProfileEditDialog extends StatefulWidget {
  final String apelido;
  final String nome;
  final String telefone;

  const ProfileEditDialog({
    required this.apelido,
    required this.nome,
    required this.telefone,
    super.key,
  });

  @override
  _ProfileEditDialogState createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _apelidoController;
  late final TextEditingController _nomeController;
  late final TextEditingController _telefoneController;

  @override
  void initState() {
    super.initState();
    _apelidoController = TextEditingController(text: widget.apelido);
    _nomeController = TextEditingController(text: widget.nome);
    _telefoneController = TextEditingController(text: widget.telefone);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //adicionar outros campos
            TextField(
              controller: _apelidoController,
              decoration: const InputDecoration(labelText: 'Apelido'),
            ),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
            ),
            TextField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final result = <String, dynamic>{};
            
         //adicionar outros campos
            if (_apelidoController.text != widget.apelido) {
              result['apelido'] = _apelidoController.text;
            }
            if (_nomeController.text != widget.nome) {
              result['nome'] = _nomeController.text;
            }
            if (_telefoneController.text != widget.telefone) {
              result['telefone'] = _telefoneController.text;
            }
            
            Navigator.pop(context, result);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}