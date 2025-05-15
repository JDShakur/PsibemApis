import 'package:flutter/material.dart';
import 'package:psibem/usuarios/views/moodtracker/contagem_page.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class MonitoramentoPage extends StatefulWidget {
  final Map<DateTime, String> moods;
  final Map<DateTime, String> autoestima;
  final List<Map<String, dynamic>> emocoesPersonalizadas;

  const MonitoramentoPage({
    super.key,
    required this.moods,
    required this.autoestima,
    required this.emocoesPersonalizadas,
  });

  @override
  _MonitoramentoPageState createState() => _MonitoramentoPageState();
}

class _MonitoramentoPageState extends State<MonitoramentoPage> {



  String _calcularHumorMaisFrequente() {
    final Map<String, int> contagemHumores = {};

    for (var mood in widget.moods.values) {
      contagemHumores[mood] = (contagemHumores[mood] ?? 0) + 1;
    }

    if (contagemHumores.isEmpty) {
      return '';
    }

    return contagemHumores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  int _calcularDiasSeguidos() {
    if (widget.moods.isEmpty) return 0;

    final sortedDates = widget.moods.keys.toList()..sort();

    int maxDiasSeguidos = 0;
    int diasAtuais = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final dataAtual = sortedDates[i];
      final dataAnterior = sortedDates[i - 1];

      if (dataAtual.difference(dataAnterior).inDays == 1) {
        diasAtuais++;
      } else {
        if (diasAtuais > maxDiasSeguidos) {
          maxDiasSeguidos = diasAtuais;
        }
        diasAtuais = 1;
      }
    }

    if (diasAtuais > maxDiasSeguidos) {
      maxDiasSeguidos = diasAtuais;
    }

    return maxDiasSeguidos;
  }

  IconData _obterIconeHumor(String humor) {
    switch (humor) {
      case '😊 Felicidade':
        return Icons.sentiment_very_satisfied;
      case '😢 Tristeza':
        return Icons.sentiment_very_dissatisfied;
      case '😡 Raiva':
        return Icons.sentiment_very_dissatisfied;
      case '😴 Cansaço':
        return Icons.sentiment_dissatisfied;
      case '😐 Apatia':
        return Icons.sentiment_neutral;
      case '😰 Ansiedade':
        return Icons.sentiment_very_dissatisfied;
      case '😍 Amor':
        return Icons.favorite;
      case '🤔 Reflexão':
        return Icons.psychology;
      case '🤯 Sobrecarga':
        return Icons.warning;
      case '🥳 Celebração':
        return Icons.celebration;
      default:
        return Icons.sentiment_neutral;
    }
  }

  List<_ChartData> _gerarDadosGraficoPizza() {
    final Map<String, int> contagemHumores = {};

    for (var mood in widget.moods.values) {
      contagemHumores[mood] = (contagemHumores[mood] ?? 0) + 1;
    }

    if (contagemHumores.isEmpty) {
      return [
        _ChartData('Nenhum dado', 1, Colors.grey), // Círculo cinza
      ];
    }

    return contagemHumores.entries.map((entry) {
      final String humor = entry.key;
      final int valor = entry.value;

      final emoji = humor.split(' ')[0];

      final color = _emojiColors[emoji] ?? Colors.black;

      return _ChartData(emoji, valor.toDouble(), color);
    }).toList();
  }

  final Map<String, Color> _emojiColors = {
    '😊': const Color.fromARGB(255, 255, 251, 215),
    '😢': const Color.fromARGB(255, 133, 172, 204),
    '😡': Colors.red,
    '😴': const Color.fromARGB(255, 244, 210, 250),
    '😐': Colors.grey,
    '😰': const Color.fromARGB(255, 240, 187, 107),
    '😍': const Color.fromARGB(255, 255, 149, 184),
    '🤔': Colors.teal,
    '🤯': const Color.fromARGB(255, 196, 108, 82),
    '🥳': const Color.fromARGB(255, 168, 255, 171),
  };

  @override
  Widget build(BuildContext context) {
    final humorMaisFrequente = _calcularHumorMaisFrequente();
    // ignore: unused_local_variable
    final iconeHumor = _obterIconeHumor(humorMaisFrequente);
    final contagemHumores =
        widget.moods.values.where((mood) => mood == humorMaisFrequente).length;
    final diasSeguidos = _calcularDiasSeguidos();
    final dadosGrafico = _gerarDadosGraficoPizza();

    final Map<String, String> emojiLegenda = {};
    for (var emocao in widget.emocoesPersonalizadas) {
      final emoji = emocao['emoji'];
      final nome = emocao['humor'];
      emojiLegenda[emoji] = nome;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFBEE9E8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF208584)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 30),
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'Dias seguidos',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'HelveticaNeue',
                        color: Color(0xFF208584),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(7, (index) {
                      final dia = index + 1;
                      final temCheck = dia <= diasSeguidos;

                      return Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: temCheck
                                  ? const Color(0xFF208584)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF208584),
                                width: 1,
                              ),
                            ),
                            child: temCheck
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dia',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'HelveticaNeue',
                              color: Color(0xFF208584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(
                      'Check-in da mente: $diasSeguidos',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'HelveticaNeue',
                        color: Color(0xFF208584),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Monitoramento',
              style: TextStyle(
                fontSize: 34,
                fontFamily: 'HelveticaNeue',
                color: Color(0xFF208584),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1E7CD),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  humorMaisFrequente == ''
                                      ? ' '
                                      : humorMaisFrequente.split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontFamily: 'HelveticaNeue',
                                    color: Color(0xFF208584),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Últimos 30 dias",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'HelveticaNeue',
                                    color: Color(0xFF208584),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                const Text(
                                  'Humor deste mês',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'HelveticaNeue',
                                    color: Color(0xFF208584),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  humorMaisFrequente == ''
                                      ? 'Nenhuma entrada'
                                      : '${humorMaisFrequente.split(' ').sublist(1).join(' ')} - $contagemHumores ${contagemHumores == 1 ? 'entrada' : 'entradas'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'HelveticaNeue',
                                    color: Color(0xFF208584),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F7F6),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Gráfico de Humor Semanal',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'HelveticaNeue',
                              color: Color(0xFF208584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: SfCircularChart(
                            tooltipBehavior: TooltipBehavior(enable: false),
                            series: <CircularSeries<_ChartData, String>>[
                              PieSeries<_ChartData, String>(
                                dataSource: dadosGrafico,
                                xValueMapper: (_ChartData data, _) =>
                                    data.categoria,
                                yValueMapper: (_ChartData data, _) =>
                                    data.valor,
                                pointColorMapper: (_ChartData data, _) =>
                                    data.cor,
                                dataLabelMapper: (_ChartData data, _) =>
                                    data.categoria,
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                    fontFamily: 'HelveticaNeue',
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: dadosGrafico.map((data) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data.categoria,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  emojiLegenda[data.categoria] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'HelveticaNeue',
                                    color: Color(0xFF208584),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: const EdgeInsets.only(
                                      top: 20, left: 20, right: 20, bottom: 10),
                                  content: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Color(0xFF208584)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'O sentimento mais registrado é exibido aqui. Para mais informações, verifique a "Contagem de Humor".',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'HelveticaNeue',
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ContagemPage(
                                                        moods: widget.moods,
                                                        autoestima:
                                                            widget.autoestima,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF208584),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 30,
                                                      vertical: 15),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Contagem de Humor',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'HelveticaNeue',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Melhorar meu humor >',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'HelveticaNeue',
                                color: Color(0xFF208584),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

class _ChartData {
  _ChartData(this.categoria, this.valor, this.cor);

  final String categoria;
  final double valor;
  final Color cor;
}
