import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:psibem/usuarios/views/settings/termosdeuso.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CompartilhamentoPage extends StatefulWidget {
  final Map<DateTime, String> moods;
  final Map<DateTime, String> autoestima;
  final List<Map<String, dynamic>> emocoesPersonalizadas;

  const CompartilhamentoPage({
    super.key,
    required this.moods,
    required this.autoestima,
    required this.emocoesPersonalizadas,
  });

  @override
  _CompartilhamentoPageState createState() => _CompartilhamentoPageState();
}

class _CompartilhamentoPageState extends State<CompartilhamentoPage> {
  bool psicologoSelecionado = false;
  bool somenteEuSelecionado = false;
  bool termosAceitos = false;
  final GlobalKey _humorChartKey = GlobalKey();
  final GlobalKey _autoestimaChartKey = GlobalKey();

  Future<Uint8List> _captureWidget(GlobalKey key) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // pequeno delay
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception("Falha ao capturar widget: $e");
    }
  }

  // Método para gerar o PDF
  Future<void> _exportToPdf() async {
    try {
      final Uint8List humorImage = await _captureWidget(_humorChartKey);
      final Uint8List autoestimaImage =
          await _captureWidget(_autoestimaChartKey);

      final humorMaisFrequente = _calcularHumorMaisFrequente();
      final diasSeguidos = _calcularDiasSeguidos();
      final contagemAutoestima = _contarFrequenciaAutoestima();
      final totalRegistros = widget.moods.length;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Header(
                  level: 0,
                  child: pw.Text('Relatório de Saúde Emocional',
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 5),

                // Seção de resumo
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  padding: const pw.EdgeInsets.all(15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Resumo:',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text('Total de registros: $totalRegistros'),
                      pw.Text('Humor mais frequente: $humorMaisFrequente'),
                      pw.Text('Maior sequência de dias: $diasSeguidos'),
                      pw.Text(
                          'Autoestima Alta: ${contagemAutoestima['Alta'] ?? 0}'),
                      pw.Text(
                          'Autoestima Média: ${contagemAutoestima['Média'] ?? 0}'),
                      pw.Text(
                          'Autoestima Baixa: ${contagemAutoestima['Baixa'] ?? 0}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 5),

                // Gráfico de humor
                pw.Text('Distribuição de Humores',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(humorImage),
                    width: 300,
                    height: 250,
                  ),
                ),
                pw.SizedBox(height: 5),

                // Gráfico de autoestima
                pw.Text('Níveis de Autoestima',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(autoestimaImage),
                    width: 250,
                    height: 250,
                  ),
                ),
              ],
            );
          },
        ),
      );

      // 4. Mostrar diálogo de impressão/compartilhamento
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      // 5. Lógica adicional de compartilhamento
      if (psicologoSelecionado) {
        // Implementar envio para psicólogo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviado para seu psicólogo')),
        );
      }
      if (somenteEuSelecionado) {
        // Implementar salvamento local
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salvo localmente com sucesso')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    }
  }

  // Métodos auxiliares para processamento de dados
  String _calcularHumorMaisFrequente() {
    final Map<String, int> contagem = {};
    for (var mood in widget.moods.values) {
      contagem[mood] = (contagem[mood] ?? 0) + 1;
    }
    return contagem.isEmpty
        ? 'Nenhum registro'
        : contagem.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  int _calcularDiasSeguidos() {
    if (widget.moods.isEmpty) return 0;
    final dates = widget.moods.keys.toList()..sort();
    int max = 1, current = 1;
    for (int i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        current++;
        if (current > max) max = current;
      } else {
        current = 1;
      }
    }
    return max;
  }

  Map<String, int> _contarFrequenciaAutoestima() {
    final Map<String, int> contagem = {'Alta': 0, 'Média': 0, 'Baixa': 0};
    for (var valor in widget.autoestima.values) {
      contagem[valor] = (contagem[valor] ?? 0) + 1;
    }
    return contagem;
  }

  List<_ChartData> _gerarDadosHumor() {
    final Map<String, int> contagem = {};
    for (var mood in widget.moods.values) {
      contagem[mood] = (contagem[mood] ?? 0) + 1;
    }
    return contagem.isEmpty
        ? [_ChartData('Sem dados', 1, Colors.grey)]
        : contagem.entries.map((e) {
            final emoji = e.key.split(' ')[0];
            return _ChartData(emoji, e.value.toDouble(), _emojiColor(emoji));
          }).toList();
  }

  List<_ChartData> _gerarDadosAutoestima() {
    final contagem = _contarFrequenciaAutoestima();
    return [
      if (contagem['Alta']! > 0)
        _ChartData(
            'Alta', contagem['Alta']!.toDouble(), const Color(0xFF208584)),
      if (contagem['Média']! > 0)
        _ChartData(
            'Média', contagem['Média']!.toDouble(), const Color(0xFF81C7C6)),
      if (contagem['Baixa']! > 0)
        _ChartData(
            'Baixa', contagem['Baixa']!.toDouble(), const Color(0xFFE3F7F6)),
    ];
  }

  Color _emojiColor(String emoji) {
    const colors = {
      '😊': Color(0xFFFFD700),
      '😢': Color(0xFF87CEEB),
      '😡': Color(0xFFFF4500),
      '😴': Color(0xFF9370DB),
      '😐': Color(0xFFA9A9A9),
      '😰': Color(0xFFFFA500),
      '😍': Color(0xFFFF69B4),
      '🤔': Color(0xFF008080),
      '🤯': Color(0xFFA0522D),
      '🥳': Color(0xFF32CD32),
    };
    return colors[emoji] ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final dadosHumor = _gerarDadosHumor();
    final dadosAutoestima = _gerarDadosAutoestima();

    return Scaffold(
      backgroundColor: const Color(0xFF208584),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF208584)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Compartilhar Relatório',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Pré-visualização dos gráficos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Gráfico de humor
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const Text(
                            'Distribuição de Humores',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF208584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RepaintBoundary(
                            key: _humorChartKey,
                            child: SizedBox(
                              height: 250,
                              child: SfCircularChart(
                                series: <CircularSeries<_ChartData, String>>[
                                  PieSeries<_ChartData, String>(
                                    dataSource: dadosHumor,
                                    xValueMapper: (d, _) => d.categoria,
                                    yValueMapper: (d, _) => d.valor,
                                    pointColorMapper: (d, _) => d.cor,
                                    dataLabelMapper: (d, _) => d.categoria,
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gráfico de autoestima
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          const Text(
                            'Níveis de Autoestima',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF208584),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RepaintBoundary(
                            key: _autoestimaChartKey,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 250,
                              child: dadosAutoestima.isEmpty
                                  ? const Center(
                                      child: Text(
                                          "Nenhum dado de autoestima disponível"))
                                  : SfCircularChart(
                                      series: <CircularSeries<_ChartData,
                                          String>>[
                                        PieSeries<_ChartData, String>(
                                          dataSource: dadosAutoestima,
                                          xValueMapper: (d, _) => d.categoria,
                                          yValueMapper: (d, _) => d.valor,
                                          pointColorMapper: (d, _) => d.cor,
                                          dataLabelMapper: (d, _) =>
                                              '${d.categoria}\n${d.valor}',
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                            isVisible: true,
                                            textStyle:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Opções de compartilhamento
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Com quem compartilhar?',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF208584),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Opção Psicólogo
                      _buildOpcaoCompartilhamento(
                        icon: Icons.psychology,
                        label: 'Com psicólogo',
                        selected: psicologoSelecionado,
                        onTap: () => setState(
                            () => psicologoSelecionado = !psicologoSelecionado),
                      ),
                      const SizedBox(height: 15),

                      // Opção Somente eu
                      _buildOpcaoCompartilhamento(
                        icon: Icons.person,
                        label: 'Somente eu',
                        selected: somenteEuSelecionado,
                        onTap: () => setState(
                            () => somenteEuSelecionado = !somenteEuSelecionado),
                      ),
                      const SizedBox(height: 20),

                      // Termos de privacidade
                      Row(
                        children: [
                          Checkbox(
                            value: termosAceitos,
                            onChanged: (value) =>
                                setState(() => termosAceitos = value ?? false),
                            activeColor: const Color(0xFF208584),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Concordo com os ',
                                    style: TextStyle(color: Color(0xFF208584)),
                                  ),
                                  TextSpan(
                                      text: 'termos de privacidade',
                                      style: const TextStyle(
                                        color: Color(0xFF208584),
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
            ..onTap = () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // Permite rolagem
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: TermsOfUseContent(), 
                  ),
                ),
              );
            },),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Botão de ação
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: termosAceitos ? _exportToPdf : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1E7CD),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf, color: Color(0xFF208584)),
                      SizedBox(width: 10),
                      Text(
                        'Gerar e Compartilhar PDF',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF208584),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcaoCompartilhamento({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF208584) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF208584),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : const Color(0xFF208584)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: selected ? Colors.white : const Color(0xFF208584),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Checkbox(
              value: selected,
              onChanged: (value) => onTap(),
              activeColor: Colors.white,
              checkColor: const Color(0xFF208584),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String categoria;
  final double valor;
  final Color cor;

  _ChartData(this.categoria, this.valor, this.cor);
}
