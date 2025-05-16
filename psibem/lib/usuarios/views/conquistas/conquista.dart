import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psibem/usuarios/views/conquistas/ModelConquista.dart';

Future<List<Conquista>> buscarConquistasDoUsuario() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(uid)
      .collection('conquistas')
      .get();

  return snapshot.docs
      .map((doc) => Conquista.fromMap(doc.id, doc.data()))
      .toList();
}

Future<void> registrarConquista(String titulo, String descricao) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final conquistaRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('conquistas')
      .doc(titulo);

  final doc = await conquistaRef.get();

  if (!doc.exists) {
    await conquistaRef.set({
      'titulo': titulo,
      'descricao': descricao,
      'dataDesbloqueio': DateTime.now(),
    });
  }
}

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({super.key});

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  bool showPopup = true;
  List<Conquista> conquistasDesbloqueadas = [];

  @override
  void initState() {
    super.initState();
    carregarConquistas();
  }

  Future<void> carregarConquistas() async {
    final conquistas = await buscarConquistasDoUsuario();
    setState(() {
      conquistasDesbloqueadas = conquistas;
    });
  }

  final conquistasDisponiveis = [
    {
      "titulo": "Primeiro Passo",
      "descricao": "Fez login pela primeira vez.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] == 1,
    },
    {
      "titulo": "Resiliência",
      "descricao": "Acessou o app por 3 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 3,
    },
    {
      "titulo": "Persistência",
      "descricao": "Acessou o app por 7 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 7,
    },
  ];
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F7F6),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Conquistas",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF81C7C6),
                ),
              ),
              const SizedBox(height: 15),
              Image.asset("lib/assets/images/psibi.png", height: 80),
              const SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.symmetric(horizontal: 50),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.favorite, color: Color(0xFF208584)),
                    SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Você está indo muito bem!",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Confira suas Conquistas!",
                          style: TextStyle(
                            color: Color(0xFF81C7C6),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: PageView.builder(
                    itemCount: (conquistasDesbloqueadas.length / 6).ceil(),
                    itemBuilder: (context, pageIndex) {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 1,
                        ),
                        itemCount:
                            (pageIndex + 1) * 6 > conquistasDesbloqueadas.length
                                ? conquistasDesbloqueadas.length - pageIndex * 6
                                : 6,
                        itemBuilder: (context, index) {
                          final conquista =
                              conquistasDesbloqueadas[pageIndex * 6 + index];
                          return _ConquistaCard(conquista: conquista);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (showPopup) _buildPopup(),
        ],
      ),
    );
  }

  Widget _buildPopup() {
    return Positioned(
      top: 40,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1E7CD),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.new_releases_rounded, color: Color(0xFF208584)),
            const SizedBox(width: 5),
            const Text(
              "Nova Conquista!",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF208584)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF208584)),
              onPressed: () {
                setState(() {
                  showPopup = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ConquistaCard extends StatelessWidget {
  final Conquista conquista;

  const _ConquistaCard({required this.conquista});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              _buildModal(context, conquista.nome, conquista.descricao),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Color(0xFF208584),
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                conquista.nome,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModal(BuildContext context, String titulo, String descricao) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(titulo),
      content: Text(descricao),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF208584),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Confirmar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
