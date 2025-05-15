import 'package:flutter/material.dart';
import 'package:psibem/usuarios/views/moodtracker/compartilhamento_page.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ContagemPage extends StatelessWidget {
  final Map<DateTime, String> moods;
  final Map<DateTime, String> autoestima;

  const ContagemPage({
    super.key,
    required this.moods,
    required this.autoestima,
  });

  // Método para contar humores únicos
  int _contarHumoresUnicos() {
    final Set<String> humoresUnicos = moods.values.toSet();
    return humoresUnicos.length;
  }

  // Método para contar a frequência de autoestima
  Map<String, int> _contarFrequenciaAutoestima() {
    final Map<String, int> frequencia = {'Alta': 0, 'Média': 0, 'Baixa': 0};
    for (var valor in autoestima.values) {
      frequencia[valor] = (frequencia[valor] ?? 0) + 1;
    }
    return frequencia;
  }

  @override
  Widget build(BuildContext context) {
    final int totalHumores = _contarHumoresUnicos();
    final Map<String, int> frequenciaAutoestima = _contarFrequenciaAutoestima();

    final Set<String> emojisUnicos =
        moods.values.map((mood) => mood.split(' ')[0]).toSet();

    final bool nenhumaAutoestimaRegistrada =
        frequenciaAutoestima.values.every((value) => value == 0);

    final List<_ChartData> dadosGrafico = nenhumaAutoestimaRegistrada
        ? [
            _ChartData('Nenhum dado', 1, Colors.grey), // Círculo cinza
          ]
        : [
            if (frequenciaAutoestima['Alta']! > 0)
              _ChartData('Alta', frequenciaAutoestima['Alta']?.toDouble() ?? 0,
                  const Color(0xFF208584)),
            if (frequenciaAutoestima['Média']! > 0)
              _ChartData(
                  'Média',
                  frequenciaAutoestima['Média']?.toDouble() ?? 0,
                  const Color(0xFF81C7C6)),
            if (frequenciaAutoestima['Baixa']! > 0)
              _ChartData(
                  'Baixa',
                  frequenciaAutoestima['Baixa']?.toDouble() ?? 0,
                  const Color.fromARGB(255, 215, 236, 230)),
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF208584)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildContagemHumor(totalHumores, emojisUnicos),
              const SizedBox(height: 40),
              _buildGraficoAutoestima(
                  dadosGrafico, nenhumaAutoestimaRegistrada),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompartilhamentoPage(
                        moods: moods,
                        autoestima: autoestima,
                        emocoesPersonalizadas: [],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1E7CD),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Compartilhar',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'HelveticaNeue',
                        color: Color(0xFF208584),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.share, color: Color(0xFF208584)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
     
    );
  }

  // Widget para a contagem de humor
  Widget _buildContagemHumor(int totalHumores, Set<String> emojisUnicos) {
    return Container(
      width: double.infinity,
      height: 300,
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Contagem de Humor',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'HelveticaNeue',
              color: Color(0xFF208584),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$totalHumores humores diferentes selecionados',
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'HelveticaNeue',
              color: Color(0xFF208584),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: emojisUnicos.map((emoji) {
              return Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Humores selecionados esse mês',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'HelveticaNeue',
              color: Color(0xFF208584),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para o gráfico de autoestima
  Widget _buildGraficoAutoestima(
      List<_ChartData> dadosGrafico, bool nenhumaAutoestimaRegistrada) {
    return Container(
      width: double.infinity,
      height: 300,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Avaliação de Autoestima',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'HelveticaNeue',
              color: Color(0xFF208584),
              fontWeight: FontWeight.bold,
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
                  xValueMapper: (_ChartData data, _) => data.categoria,
                  yValueMapper: (_ChartData data, _) => data.valor,
                  pointColorMapper: (_ChartData data, _) => data.cor,
                  dataLabelMapper: (_ChartData data, _) =>
                      nenhumaAutoestimaRegistrada ? '' : data.categoria,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontFamily: 'HelveticaNeue',
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
