import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:psibem/api_connection/api_connection.dart';
import 'package:psibem/psicologos/views/settings/termosdeuso.dart';
import 'package:psibem/usuarios/views/settings/ProfileEditDialog.dart';
import 'package:psibem/widget/logout_button.dart';

class SettingsPaciente extends StatefulWidget {
  const SettingsPaciente({super.key});

  @override
  _SettingsPacienteState createState() => _SettingsPacienteState();
}

class _SettingsPacienteState extends State<SettingsPaciente> {
  // Dados do usuário
  String _uid = '';
  String _email = '';
  String _apelido = '';
  String _nome = '';
  String _telefone = '';
  String _dataNascimento = '';
  String _sexo = '';
  bool _notificacoesAtivadas = true;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Instâncias de serviço
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _loadUserData();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) _showErrorSnackbar('Usuário não autenticado');
        return;
      }

      // Carrega dados do Firestore
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _uid = user.uid;
          _email = user.email ?? '';
          _apelido = data['apelido'] ?? '';
          _nome = data['nome'] ?? data['Nome'] ?? '';
          _telefone = data['telefone'] ?? '';
          _sexo = data['sexo'] ?? '';
          _dataNascimento = data['data'] ?? data['dataNascimento'] ?? '';
        });
      } else {
        // Fallback para API local se Firestore não tiver dados
        await _loadFromLocalApi(user);
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Erro ao carregar dados: $e');
      debugPrint('Erro ao carregar dados: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFromLocalApi(User user) async {
    try {
      final apiData = await _apiService.getUserData(user.uid);
      if (apiData['exists']) {
        setState(() {
          _uid = user.uid;
          _email = user.email ?? '';
          _nome = apiData['data']['nome'] ?? '';
          _dataNascimento = apiData['data']['data'] ?? '';
          _sexo = apiData['data']['sexo'] ?? '';
        });
        // Sincroniza com Firestore
        await _syncUserData();
      }
    } catch (e) {
      debugPrint('Erro ao carregar da API local: $e');
    }
  }

  Future<void> _syncUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'Email': user.email ?? _email,
        'apelido': _apelido.isNotEmpty ? _apelido : 'Sem apelido',
        'nome': _nome.isNotEmpty ? _nome : 'Sem nome',
        'telefone': _telefone.isNotEmpty ? _telefone : 'Sem telefone',
        'dataNascimento':
            _dataNascimento.isNotEmpty ? _dataNascimento : 'Sem data',
        'sexo': _sexo.isNotEmpty ? _sexo : 'Sem informação',
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Erro ao sincronizar dados: $e');
    }
  }

  Future<void> _editarPerfil() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ProfileEditDialog(
        apelido: _apelido,
        nome: _nome,
        telefone: _telefone,
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Atualiza Firestore
      await _firestore.collection('usuarios').doc(_uid).update({
        'apelido': result['apelido'],
        'nome': result['nome'],
        'telefone': result['telefone'],
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      // Atualiza estado local
      setState(() {
        _apelido = result['apelido'];
        _nome = result['nome'];
        _telefone = result['telefone'];
      });

      // Atualiza API local (opcional)
      try {
        await _apiService.updateUserData(_uid, result);
      } catch (e) {
        debugPrint('Erro ao atualizar API local: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnackbar('Erro ao atualizar perfil: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editarEmail() async {
    final novoEmail = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _email);
        final formKey = GlobalKey<FormState>();

        return AlertDialog(
          title: const Text('Editar E-mail'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Novo E-mail'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Digite um e-mail';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'E-mail inválido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoEmail == null || novoEmail == _email) return;

    setState(() => _isLoading = true);

    try {
      // Reautenticação
      final password = await _showPasswordDialog('Confirme sua senha atual');
      if (password.isEmpty) return;

      final credential = EmailAuthProvider.credential(
        email: _email,
        password: password,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);

      // Atualiza e-mail
      await _auth.currentUser?.verifyBeforeUpdateEmail(novoEmail);

      // Atualiza Firestore
      await _firestore.collection('usuarios').doc(_uid).update({
        'Email': novoEmail,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      // Atualiza estado local
      setState(() => _email = novoEmail);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link de confirmação enviado para seu novo e-mail!'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String error = 'Erro ao atualizar e-mail';
      if (e.code == 'requires-recent-login') {
        error = 'Sessão expirada. Faça login novamente.';
      } else if (e.code == 'email-already-in-use') {
        error = 'E-mail já está em uso por outra conta.';
      }
      if (mounted) _showErrorSnackbar('$error (${e.code})');
    } catch (e) {
      if (mounted) _showErrorSnackbar('Erro ao atualizar e-mail: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Alterar Senha'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Senha Atual'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Nova Senha'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Confirmar Nova Senha'),
                  ),
                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        try {
                          setStateDialog(() => _isLoading = true);

                          // Validações
                          if (_newPasswordController.text.length < 8) {
                            throw 'A senha deve ter pelo menos 8 caracteres';
                          }

                          if (_newPasswordController.text !=
                              _confirmPasswordController.text) {
                            throw 'As senhas não coincidem';
                          }

                          // Reautenticação
                          final credential = EmailAuthProvider.credential(
                            email: _email,
                            password: _oldPasswordController.text,
                          );

                          await _auth.currentUser!
                              .reauthenticateWithCredential(credential);

                          // Atualiza senha
                          await _auth.currentUser!
                              .updatePassword(_newPasswordController.text);

                          // Atualiza API local (opcional)
                          try {
                            await _apiService.updatePassword(
                                _uid, _newPasswordController.text);
                          } catch (e) {
                            debugPrint(
                                'Erro ao atualizar senha na API local: $e');
                          }

                          Navigator.pop(context, true);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro: $e')),
                            );
                          }
                          Navigator.pop(context, false);
                        }
                      },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<String> _showPasswordDialog(String title) async {
    final controller = TextEditingController();
    return await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        '';
  }

  Future<void> _excluirConta() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text(
            'Tem certeza que deseja excluir sua conta? Esta ação é irreversível.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      // Reautenticação
      final password =
          await _showPasswordDialog('Digite sua senha para confirmar');
      if (password.isEmpty) return;

      final credential = EmailAuthProvider.credential(
        email: _email,
        password: password,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);

      // Exclui da API local
      await _apiService.deleteUser(_uid);

      // Exclui do Firestore
      await _firestore.collection('usuarios').doc(_uid).delete();

      // Exclui conta do Firebase Auth
      await _auth.currentUser?.delete();

      // Redireciona para login
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      String error = 'Erro ao excluir conta';
      if (e.code == 'requires-recent-login') {
        error = 'Sessão expirada. Faça login novamente para excluir a conta.';
      }
      if (mounted) _showErrorSnackbar(error);
    } catch (e) {
      if (mounted) _showErrorSnackbar('Erro ao excluir conta: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          if (title == 'UID Firebase')
            Row(
              children: [
                Expanded(
                  child: Text(value.isNotEmpty ? value : "Não informado",
                      style: const TextStyle(fontSize: 16)),
                ),
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('UID copiado para a área de transferência'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            )
          else
            Text(value.isNotEmpty ? value : "Não informado",
                style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildEditableTile(String title, String value, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(value.isNotEmpty ? value : "Não informado",
                      style: const TextStyle(fontSize: 16)),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FC),
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Configurações',
            style: TextStyle(
              color: Color(0xFF81C7C6),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF81C7C6)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoTile('UID Firebase', _uid),
                  _buildEditableTile('E-mail', _email, _editarEmail),
                  _buildEditableTile('Perfil', 'Editar', _editarPerfil),
                  _buildInfoTile('Apelido',
                      _apelido.isNotEmpty ? _apelido : 'Não definido'),
                  _buildInfoTile(
                      'Nome', _nome.isNotEmpty ? _nome : 'Não definido'),
                  _buildInfoTile('Telefone',
                      _telefone.isNotEmpty ? _telefone : 'Não definido'),
                  _buildInfoTile('Data de Nascimento', _dataNascimento),
                  _buildInfoTile('Sexo', _sexo),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Alterar Senha'),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Ativar notificações'),
                    value: _notificacoesAtivadas,
                    onChanged: (value) =>
                        setState(() => _notificacoesAtivadas = value),
                    activeColor: const Color(0xFF81C7C6),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Excluir conta',
                        style: TextStyle(color: Colors.red)),
                    onTap: _excluirConta,
                  ),
                  Container(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Concordo com os ',
                            style: TextStyle(color: Color(0xFF208584)),
                          ),
                          TextSpan(
                            text: 'termos de privacidade',
                            style: const TextStyle(
                              color: Color(0xFF208584),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true, 
                                  builder: (context) => Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      child:
                                          TermsOfUseContent(), 
                                    ),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const LogoutButton(),
                ],
              ),
            ),
    );
  }
}
