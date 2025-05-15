import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psibem/psicologos/mainScreen/Homepsi.dart';
import 'package:psibem/psicologos/views/lists/listapaciente.dart';
import 'package:psibem/psicologos/views/profile/profile_psicologo.dart';
import 'package:psibem/usuarios/views/lists/listapsicologo.dart';
import 'package:psibem/usuarios/views/mainScreen/home_page.dart';
import 'package:psibem/usuarios/views/moodtracker/emotions_page.dart';
import 'package:psibem/usuarios/views/profile/profile_paciente.dart';
import 'package:psibem/usuarios/views/respiration/respiration_page.dart';
import 'package:psibem/widget/navbar_paciente.dart';
import 'package:psibem/widget/navbar_psicologo.dart';

class Pagerotation extends StatefulWidget {
  const Pagerotation({super.key});

  @override
  State<Pagerotation> createState() => _PagerotationState();
}

class _PagerotationState extends State<Pagerotation> {
  int _selectedIndex = 0;
  late Future<bool> _isPsychologist;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isPsychologist = _checkIfUserIsPsychologist();
    _setupAuthListener();
  }

  Future<bool> _checkIfUserIsPsychologist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      return doc.exists && doc.data()?['crp'] != null;
    } catch (e) {
      setState(() {
        _errorMessage = "Erro ao verificar tipo de usuário";
      });
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Redireciona para a tela de login se o usuário deslogar
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPatientPages() {
    final List<Widget> patientPages = [
      const HomePage(),
      const Calendario(),
      const RespirationPage(),
      const ListaPsicologoPage(),
      const ProfilePaciente(),
    ];

    return Scaffold(
      body: patientPages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavbarpac(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildPsychologistPages() {
    final List<Widget> psychologistPages = [
      const HomePagePsicologo(),
      const ListaPacientesPage(),
      const ProfilePsicologo(),
    ];

    return Scaffold(
      body: psychologistPages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavbarpsi(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      // Se não estiver na home, volta para a home
      setState(() {
        _selectedIndex = 0;
      });
      return false;
    }
    
    // Se estiver na home, mostra diálogo de confirmação
    final shouldExit = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do aplicativo?'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: FutureBuilder<bool>(
        future: _isPsychologist,
        builder: (context, snapshot) {
          if (_isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (_errorMessage != null) {
            return Scaffold(
              body: Center(child: Text(_errorMessage!)),
            );
          }

          if (snapshot.hasData && snapshot.data!) {
            return _buildPsychologistPages();
          } else {
            return _buildPatientPages();
          }
        },
      ),
    );
  }
}