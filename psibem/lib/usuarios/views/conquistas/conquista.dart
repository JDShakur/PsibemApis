import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
  bool showPopup = false;
  List<Conquista> conquistasDesbloqueadas = [];
  List<Conquista> conquistasNovas = [];

  @override
  void initState() {
    super.initState();
    carregarConquistas();
  }

  Future<void> carregarConquistas() async {
    final conquistas = await buscarConquistasDoUsuario();

    final novas = conquistas
        .where((c) => !conquistasDesbloqueadas.any((old) => old.nome == c.nome))
        .toList();

    setState(() {
      conquistasDesbloqueadas = conquistas;
      showPopup = novas.isNotEmpty;
      if (novas.isNotEmpty) {
        conquistasNovas = novas;
        // Fecha automaticamente após 3 segundos
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              showPopup = false;
            });
          }
        });
      }
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
    {
      "titulo": "Comprometimento",
      "descricao": "Acessou o app por 15 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 15
    },
    {
      "titulo": "Dedicação",
      "descricao": "Acessou o app por 30 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 30,
    },
    {
      "titulo": "Superação",
      "descricao": "Acessou o app por 60 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 60,
    },
    {
      "titulo": "Mestre do App",
      "descricao": "Acessou o app por 90 dias consecutivos.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['diasConsecutivos'] >= 90,
    },
    {
      "titulo": "Conquista do Dia",
      "descricao": "Fez login no dia do seu aniversário.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['dataAniversario'] == DateTime.now().day,
    },
    {
      "titulo": "Conquista do Mês",
      "descricao": "Fez login no mês do seu aniversário.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['dataAniversario'] == DateTime.now().month,
    },
    {
      "titulo": "Conquista do Ano",
      "descricao": "Fez login no ano do seu aniversário.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['dataAniversario'] == DateTime.now().year,
    },
    {
      "titulo": "Conquista do Século",
      "descricao": "Fez login no século do seu aniversário.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['dataAniversario'] == DateTime.now().year ~/ 100,
    },
    {
      "titulo": "Conquista do Milênio",
      "descricao": "Fez login no milênio do seu aniversário.",
      "condicao": (Map<String, dynamic> userData) =>
          userData['dataAniversario'] == DateTime.now().year ~/ 1000,
    },
    {
      "titulo": "Leitor Atento",
      "descricao": "Leu os termos de uso",
    },
    {
      "titulo": "Conquista do Século XXI",
      "descricao": "Fez login no século XXI.",
      "condicao": (Map<String, dynamic> userData) =>
          DateTime.now().year >= 2000 && DateTime.now().year < 2100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F7F6),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF81C7C6)),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFFE3F7F6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        backgroundColor: const Color(0xFFE3F7F6),
        title: const Text(
          'Conquistas',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'HelveticaNeue',
            color: Color(0xFF81C7C6),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Image.asset("lib/assets/images/psibi.png", height: 150),
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
                    SizedBox(width: 10),
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
          if (showPopup)
            Positioned(
              top: 70,
              right: 20,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1E7CD),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF208584), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFF208584), size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Nova conquista!",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF208584),
                            ),
                          ),
                          if (conquistasNovas.isNotEmpty)
                            Text(
                              conquistasNovas.first.nome,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF208584),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showPopup = false;
                          });
                        },
                        child: const Icon(Icons.close,
                            size: 16, color: Color(0xFF208584)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
