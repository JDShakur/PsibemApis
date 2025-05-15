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
  bool _isLoading = false;

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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);

                  final result = <String, dynamic>{
                    'apelido': _apelidoController.text,
                    'nome': _nomeController.text, // Note o lowercase
                    'telefone': _telefoneController.text,
                  };

                  Navigator.pop(context, result);
                },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
