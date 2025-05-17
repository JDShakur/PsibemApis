import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:psibem/usuarios/views/profile/perfil_psicologo_page.dart';

class ListaPsicologoPage extends StatefulWidget {
  const ListaPsicologoPage({super.key});

  @override
  State<ListaPsicologoPage> createState() => _ListaPsicologoPageState();
}

class _ListaPsicologoPageState extends State<ListaPsicologoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _psicologos = [];
  List<Map<String, dynamic>> _allPsicologos = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadPsicologos();
  }

  Future<void> _loadPsicologos() async {
    try {
      setState(() => _isLoading = true);

      final querySnapshot = await _firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'psicologo')
          .get();

      final psicologosComCrp = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data,
              'profilePicture':
                  data['profilePicture'] ?? 'lib/assets/images/psicologo1.jpg',
              'crp': data['crp']?.toString() ?? '',
            };
          })
          .where((psicologo) =>
              psicologo['crp'] != null &&
              psicologo['crp'].toString().trim().isNotEmpty)
          .toList();

      setState(() {
        _allPsicologos = psicologosComCrp;
        _psicologos = List.from(_allPsicologos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar psicólogos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _matchesSearch(String? text, String query) {
    if (text == null) return false;
    return text.toLowerCase().contains(query.toLowerCase());
  }

  void _applyFilters() {
    setState(() {
      _psicologos = _allPsicologos.where((psicologo) {
        final matchesSearch = _searchQuery.isEmpty ||
            _matchesSearch(psicologo['nome'], _searchQuery);

        final matchesFilter = _selectedFilter == null ||
            _selectedFilter == 'Todos' ||
            _checkEspecialidadeMatch(
                psicologo['especialidades'], _selectedFilter!);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  bool _checkEspecialidadeMatch(dynamic especialidades, String filter) {
    if (especialidades == null) return false;
    if (especialidades is String) {
      return especialidades.toLowerCase().contains(filter.toLowerCase());
    }
    if (especialidades is List) {
      return especialidades.any(
          (e) => e.toString().toLowerCase().contains(filter.toLowerCase()));
    }
    if (especialidades is Map) {
      return especialidades.values.any(
          (e) => e.toString().toLowerCase().contains(filter.toLowerCase()));
    }
    return false;
  }

  void _showFilterDialog() {
    final especialidadesUnicas = _getEspecialidadesUnicas();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar por especialidade'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              RadioListTile<String>(
                title: const Text('Todos os psicólogos'),
                value: 'Todos',
                groupValue: _selectedFilter,
                onChanged: (value) => setState(() => _selectedFilter = value),
              ),
              const Divider(),
              ...especialidadesUnicas
                  .map((especialidade) => RadioListTile<String>(
                        title: Text(especialidade),
                        value: especialidade,
                        groupValue: _selectedFilter,
                        onChanged: (value) =>
                            setState(() => _selectedFilter = value),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedFilter = null);
              _applyFilters();
            },
            child: const Text('Limpar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  List<String> _getEspecialidadesUnicas() {
    final allEspecialidades = _allPsicologos
        .expand((psicologo) {
          final esp = psicologo['especialidades'];
          if (esp is String) return [esp];
          if (esp is List) return esp.whereType<String>().toList();
          if (esp is Map) {
            return esp.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList();
          }
          return <String>[];
        })
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return allEspecialidades.cast<String>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE3F7F6),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: const Color(0xFF81C7C6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor:  const Color(0xFF81C7C6),
        title: const Text(
          'Profissionais Cadastrados',
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
                color: const Color(0xFF81C7C6),
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
                    _applyFilters();
                  });
                },
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          if (_selectedFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                label: Text('Filtro: $_selectedFilter'),
                onDeleted: () {
                  setState(() {
                    _selectedFilter = null;
                    _applyFilters();
                  });
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _psicologos.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty && _selectedFilter == null
                              ? 'Nenhum psicólogo com CRP cadastrado'
                              : 'Nenhum psicólogo encontrado',
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _psicologos.length,
                        itemBuilder: (context, index) =>
                            _buildPsicologoCard(_psicologos[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterDialog,
        child: IconButton(
          onPressed: () {
            _showFilterDialog();
          },
          icon: Icon(Icons.filter_list_rounded),
          color: const Color(0xFF81C7C6),
        ),
        backgroundColor: const Color.fromARGB(255, 253, 253, 253),
      ),
    );
  }

  Widget _buildPsicologoCard(Map<String, dynamic> psicologo) {
    String formatEspecialidades(dynamic especialidades) {
      if (especialidades == null) return 'Sem especialidade informada';
      if (especialidades is String) return especialidades;
      if (especialidades is List) return especialidades.join(', ');
      if (especialidades is Map) {
        return especialidades.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .join(', ');
      }
      return 'Especialidade não informada';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilPsicologoPage(psicologo: psicologo),
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
              backgroundImage: _getImageProvider(psicologo['profilePicture']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    psicologo['nome'] ?? 'Psicólogo',
                    style: const TextStyle(
                      color: const Color(0xFF81C7C6),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CRP: ${psicologo['crp'] ?? 'Não informado'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatEspecialidades(psicologo['especialidades']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color:const Color(0xFF81C7C6)),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('lib/assets/images/psicologo1.jpg');
    }
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    } else {
      return AssetImage(imagePath);
    }
  }
}
