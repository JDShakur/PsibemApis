import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:psibem/psicologos/views/profile/perfil_paciente_page.dart';

class ListaPacientePage extends StatefulWidget {
  const ListaPacientePage({super.key});

  @override
  State<ListaPacientePage> createState() => _ListaPacientePageState();
}

class _ListaPacientePageState extends State<ListaPacientePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _pacientes = [];
  List<Map<String, dynamic>> _allPacientes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPacientes();
  }

  Future<void> _loadPacientes() async {
    try {
      setState(() => _isLoading = true);

      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'Paciente')
          .get();

      final pacientes = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'profilePicture':
              data['profilePicture'] ?? 'lib/assets/images/paciente1.jpg',
        };
      }).toList();

      setState(() {
        _allPacientes = pacientes;
        _pacientes = List.from(_allPacientes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar pacientes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterPacientes() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _pacientes = List.from(_allPacientes);
      });
      return;
    }

    setState(() {
      _pacientes = _allPacientes.where((paciente) {
        final nome = paciente['nome']?.toString().toLowerCase() ?? '';
        return nome.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F7F6),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF81C7C6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: const Color(0xFF81C7C6),
        title: const Text(
          'Usuários Cadastrados',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'HelveticaNeue',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xFF81C7C6),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterPacientes();
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _pacientes.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Nenhum paciente cadastrado'
                              : 'Nenhum paciente encontrado',
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _pacientes.length,
                        itemBuilder: (context, index) =>
                            _buildPacienteCard(_pacientes[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPacienteCard(Map<String, dynamic> paciente) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilPacientePage(paciente: paciente),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: _getImageProvider(paciente['profilePicture']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paciente['nome'] ?? 'Paciente',
                    style: const TextStyle(
                      color: Color(0xFF81C7C6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF81C7C6)),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('lib/assets/images/paciente1.jpg');
    }
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }
}