import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psibem/psicologos/views/settings/profile_picture_selector.dart';
import 'package:psibem/usuarios/views/conquistas/conquista.dart';
import 'package:psibem/usuarios/views/settings/settings_paci.dart';
import 'package:psibem/widget/logout_button.dart';

class ProfilePaciente extends StatefulWidget {
  const ProfilePaciente({super.key});

  @override
  State<ProfilePaciente> createState() => _ProfilePacienteState();
}

class _ProfilePacienteState extends State<ProfilePaciente> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  final List<String> _profilePictures = [
    'lib/assets/images/paciente1.jpg',
    'lib/assets/images/paciente2.jpg',
    'lib/assets/images/paciente3.jpg',
    'lib/assets/images/meditation7.jpg',
    'lib/assets/images/psicologo1.jpg',
    'lib/assets/images/psicologo2.jpg',
    'lib/assets/images/psicologo3.jpg',
    'lib/assets/images/psicologo4.jpg',
  ];
  String? _selectedProfilePicture;

  Future<void> _updateProfilePicture(String newPicture) async {
    try {
      setState(() => _isLoading = true);

      if (newPicture.startsWith('http')) return;
      await _firestore.collection('usuarios').doc(_user!.uid).update({
        'profilePicture': newPicture,
      });
      if (mounted) {
        setState(() {
          _selectedProfilePicture = newPicture;
          _userData?['profilePicture'] = newPicture;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto atualizada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar foto: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    await _loadUserData();
  }

  String _formatarTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) return '(00) 00000-0000';
    final apenasNumeros = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    if (apenasNumeros.length == 11) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 7)}-${apenasNumeros.substring(7)}';
    } else if (apenasNumeros.length == 10) {
      return '(${apenasNumeros.substring(0, 2)}) ${apenasNumeros.substring(2, 6)}-${apenasNumeros.substring(6)}';
    }

    return telefone;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      _user = _auth.currentUser;
      if (_user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não autenticado')),
          );
        }
        return;
      }

      final userDoc = await _firestore
          .collection('usuarios')
          .doc(_user!.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userData = {
            'apelido': data['apelido'] ?? '',
            'nome': data['nome'] ?? data['Nome'] ?? '',
            'telefone': data['telefone'] ?? '',
            'profilePicture': data['profilePicture'] ?? _profilePictures[2],
          };
          _selectedProfilePicture = data['profilePicture'] ??
              _profilePictures[2]; // Atualize aqui também
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dados do usuário não encontrados')),
          );
        }
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tempo de conexão esgotado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
      debugPrint('Erro ao carregar dados do usuário: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF81C7C6),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF81C7C6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFBEE9E8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF81C7C6)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Topo da página com foto e nome
            Container(
              width: double.infinity,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFBEE9E8),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4C000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 50,
                    left: 24,
                    child: Text(
                      'Meu Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Botão de configurações
                  Positioned(
                    top: 50,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.settings,
                          size: 37, color: Color(0xFF81C7C6)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPaciente(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Foto e nome do usuário
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 100),
                        ProfilePictureSelector(
                          availablePictures: _profilePictures,
                          currentPicture:
                              _selectedProfilePicture ?? _profilePictures[2],
                          onPictureSelected: _updateProfilePicture,
                          mainPictureSize: 120,
                          accentColor: const Color(0xFF81C7C6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userData?['nome'] ?? _user?.displayName ?? 'Usuário',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Seção de Contato
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FC),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x4C000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contato',
                      style: TextStyle(
                        color: Color(0xFF81C7C6),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading:
                          const Icon(Icons.email, color: Color(0xFF81C7C6)),
                      title: Text(
                        _user?.email ?? 'emailuser@email.com',
                        style: const TextStyle(
                          color: Color(0xFF81C7C6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFF81C7C6)),
                    ListTile(
                      leading:
                          const Icon(Icons.phone, color: Color(0xFF81C7C6)),
                      title: Text(
                        _formatarTelefone(_userData?['telefone']),
                        style: const TextStyle(
                          color: Color(0xFF81C7C6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Conquistas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => ConquistasScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1E7CD),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Conquistas',
                  style: TextStyle(
                    color: Color(0xFF81C7C6),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Sair
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: LogoutButton()),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
