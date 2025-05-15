import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:psibem/usuarios/views/settings/pdfs.dart';

class GraficoSection extends StatelessWidget {
  final Map<DateTime, String> moods;

  const GraficoSection({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    // Processar dados para o gráfico
    final moodCounts = _processMoodData(moods);

    return Column(
      children: [
        // Container no topo do gráfico
        Container(
          width: 397,
          height: 332,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFF81C7C6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadows: const [
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
        ),
        // Gráfico de barras
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: BarChart(
              BarChartData(
                barGroups: moodCounts.entries.map((entry) {
                  return BarChartGroupData(
                    x: moodCounts.keys.toList().indexOf(entry.key),
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Colors.blue, // Cor das barras
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Exibe os nomes das emoções no eixo X
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            moodCounts.keys.toList()[value.toInt()],
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Exibe os valores no eixo Y
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ),
        // Botão para exportar o gráfico (opcional)
        ElevatedButton(
          onPressed: () {
            ChartToPdfExample();
          },
          child: const Text('Exportar para PDF'),
        ),
      ],
    );
  }

  // Processa os dados das emoções para o gráfico
  Map<String, int> _processMoodData(Map<DateTime, String> moods) {
    final moodCounts = <String, int>{};
    for (var mood in moods.values) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    return moodCounts;
  }
}
