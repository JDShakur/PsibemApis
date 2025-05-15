import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartToPdfExample extends StatelessWidget {
  final GlobalKey _chartKey = GlobalKey();

  ChartToPdfExample({super.key});

  Future<Uint8List> _captureChartImage() async {
    try {
      RenderRepaintBoundary boundary =
          _chartKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception("Failed to capture chart: $e");
    }
  }

  Future<void> _exportToPdf() async {
    final Uint8List chartImage = await _captureChartImage();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(chartImage),
              width: 300,
              height: 300,
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Export Chart to PDF")),
      body: Center(
        child: Column(
          children: [
            RepaintBoundary(
              key: _chartKey,
              child: SizedBox(
                width: 300,
                height: 300,
                child: LineChart(
                  LineChartData(
                    // Defina seus dados do gráfico aqui
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 1),
                          FlSpot(1, 3),
                          FlSpot(2, 2),
                          FlSpot(3, 5),
                        ],
                        isCurved: true,
                        color: Colors.blue
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _exportToPdf,
              child: Text("Exportar PDF"),
            ),
          ],
        ),
      ),
    );
  }
}