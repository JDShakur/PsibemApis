import 'package:flutter/material.dart';
import 'package:psibem/psicologos/views/profile/perfil_paciente_page.dart';

class ListaPacientesPage extends StatelessWidget {
  const ListaPacientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF81C7C6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 200,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      'Meus Pacientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Pesquisar...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.search,
                                      color: Color(0xFF81C7C6)),
                                  onPressed: () {
                                    // Lógica para pesquisar
                                    _realizarPesquisa(context);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.filter_list, size: 30),
                          color: Colors.white,
                          onPressed: () {
                            // Lógica para filtrar a pesquisa
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // Lista de pacientes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildPacienteContainer(
                      context, 'Paciente 1', 'lib/assets/images/paciente3.jpg'),
                  const SizedBox(height: 16),
                  _buildPacienteContainer(
                      context, 'Paciente 2', 'lib/assets/images/paciente2.jpg'),
                  const SizedBox(height: 16),
                  _buildPacienteContainer(
                      context, 'Paciente 3', 'lib/assets/images/paciente1.jpg'),
                  const SizedBox(height: 16)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para construir o container de cada paciente
  Widget _buildPacienteContainer(
      BuildContext context, String nome, String imagem) {
    return GestureDetector(
      onTap: () {
        // Navega para a página de perfil do paciente
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PerfilPacientePage(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 120,
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
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                top: 8,
                bottom: 8,
                right: 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagem,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(
                      color: Color(0xFF81C7C6),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF81C7C6),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Função para realizar a pesquisa
  void _realizarPesquisa(BuildContext context) {
    // Adicione aqui a lógica de pesquisa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesquisa realizada!'),
      ),
    );
  }
}
