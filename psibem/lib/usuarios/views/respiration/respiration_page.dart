import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psibem/usuarios/views/conquistas/conquista.dart';

class RespirationPage extends StatelessWidget {
  const RespirationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF81C7C6),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF81C7C6),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        title: const Text(
          'Respiração',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'HelveticaNeue',
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF81C7C6),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Color(0xFFBDE4E3),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Exercício de Respiração",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF208584),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Color(0xFF438778),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BotaoCustomizado("Siga o pontinho"),
                BotaoCustomizado(
                    "Inspire pelo nariz,\n pause, solte pela boca e pause"),
                BotaoCustomizado("Sinta o relaxamento"),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF438778),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await registrarConquista(
                        "Momento Zen", "Completou um exercício de respiração.");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TelaRespiracao()),
                    );
                  },
                  child: const Text("Iniciar sessão"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BotaoCustomizado extends StatelessWidget {
  final String texto;
  const BotaoCustomizado(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF81C7C6),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class TelaRespiracao extends StatefulWidget {
  const TelaRespiracao({super.key});

  @override
  _TelaRespiracaoState createState() => _TelaRespiracaoState();
}

class _TelaRespiracaoState extends State<TelaRespiracao>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isPaused = false;
  Color currentColor = const Color(0xFF438778);
  double currentSize = 15;
  Timer? _colorTimer;
  Timer? _sizeTimer;

  final List<Color> colorPalette = [
    const Color(0xFF438778),
    const Color(0xFF81C7C6),
    const Color(0xFF208584),
    const Color(0xFFBDE4E3),
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Timer para mudança de cor a cada 5 segundos
    _colorTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isPaused) {
        setState(() {
          currentColor = colorPalette[Random().nextInt(colorPalette.length)];
        });
      }
    });

    // Timer para mudança de tamanho a cada 5 segundos (com offset de 2.5s)
    _sizeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isPaused) {
        setState(() {
          currentSize = Random().nextInt(30) + 10.toDouble();
        });
      }
    });
  }

  void toggleAnimation() {
    setState(() {
      if (isPaused) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
      isPaused = !isPaused;
    });
  }

  void resetAnimation() {
    setState(() {
      _controller.reset();
      _controller.repeat();
      isPaused = false;
      currentColor = const Color(0xFF438778);
      currentSize = 15;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _colorTimer?.cancel();
    _sizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = 150;

    return Scaffold(
      backgroundColor: const Color(0xFF81C7C6),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFBDE4E3),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Respiração",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFF438778), width: 4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        double t = _animation.value * 4;
                        double x = 0, y = 0;
                        double padding = 8;
                        double minX = padding + currentSize / 2;
                        double maxX = boxSize - padding - currentSize / 2;
                        double minY = padding + currentSize / 2;
                        double maxY = boxSize - padding - currentSize / 2;

                        if (t < 1) {
                          x = minX + (maxX - minX) * t;
                          y = minY;
                        } else if (t < 2) {
                          x = maxX;
                          y = minY + (maxY - minY) * (t - 1);
                        } else if (t < 3) {
                          x = maxX - (maxX - minX) * (t - 2);
                          y = maxY;
                        } else {
                          x = minX;
                          y = maxY - (maxY - minY) * (t - 3);
                        }

                        return Positioned(
                          left: x - currentSize / 2,
                          top: y - currentSize / 2,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: currentSize,
                            height: currentSize,
                            decoration: BoxDecoration(
                              color: currentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isPaused ? Icons.play_arrow : Icons.pause,
                        color: const Color(0xFF208584),
                        size: 30,
                      ),
                      onPressed: toggleAnimation,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.restart_alt,
                        color: Color(0xFF208584),
                        size: 30,
                      ),
                      onPressed: resetAnimation,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF208584),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Encerrar sessão"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
