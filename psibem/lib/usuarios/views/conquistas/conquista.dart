import 'package:flutter/material.dart';

const List<String> conquistas = [
  "Cores da Vida",
  "Reflexão Profunda",
  "Sessão Concluída",
  "Check-in da Mente",
  "Pequenos Gestos",
  "Momento Zen",
  "Modo Offline",
  "Resiliência",
  "Onda Positiva",
];

class ConquistasScreen extends StatefulWidget {
  const ConquistasScreen({super.key});

  @override
  State<ConquistasScreen> createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen> {
  bool showPopup = true;

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
                    itemCount: (conquistas.length / 6).ceil(),
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
                        itemCount: (pageIndex + 1) * 6 > conquistas.length
                            ? conquistas.length - pageIndex * 6
                            : 6,
                        itemBuilder: (context, index) {
                          return _ConquistaCard(
                            conquista: conquistas[pageIndex * 6 + index],
                          );
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
  final String conquista;

  const _ConquistaCard({required this.conquista});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _buildModal(context),
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
                conquista,
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

  Widget _buildModal(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Primeiro Passo"),
      content: const Text("Registrou seu primeiro sentimento no calendário."),
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
