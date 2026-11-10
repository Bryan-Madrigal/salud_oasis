import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../modelos/registro_seguimiento.dart';

class GraficaEvolucion extends StatelessWidget {
  final List<RegistroSeguimiento> registros;
  final String tipo;

  const GraficaEvolucion({super.key, required this.registros, required this.tipo});

  @override
  Widget build(BuildContext context) {
    // Filtrar registros del tipo seleccionado y ordenarlos por fecha
    final filtrados = registros.where((r) => r.tipo == tipo).toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    if (filtrados.isEmpty) {
      return Container(
        height: 250,
        alignment: Alignment.center,
        child: const Text('No hay datos suficientes para graficar', style: TextStyle(color: Colors.grey)),
      );
    }

    // Tomamos los ultimos 7 registros para la grafica
    final ultimos = filtrados.length > 7 ? filtrados.sublist(filtrados.length - 7) : filtrados;

    List<FlSpot> spotsSistolica = [];
    List<FlSpot> spotsDiastolica = [];
    List<FlSpot> spotsUnicos = [];
    List<String> dias = [];

    final nombresDias = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];

    for (int i = 0; i < ultimos.length; i++) {
      final r = ultimos[i];
      dias.add(nombresDias[r.fechaHora.weekday - 1]);

      if (tipo == 'presion') {
        // Formato de presion: "120/80"
        final partes = r.valor.split('/');
        if (partes.length == 2) {
          final sys = double.tryParse(partes[0]) ?? 120;
          final dia = double.tryParse(partes[1]) ?? 80;
          spotsSistolica.add(FlSpot(i.toDouble(), sys));
          spotsDiastolica.add(FlSpot(i.toDouble(), dia));
        }
      } else {
        // Glucosa o peso (un solo valor)
        final val = double.tryParse(r.valor) ?? 0;
        spotsUnicos.add(FlSpot(i.toDouble(), val));
      }
    }

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: tipo == 'presion' ? 20 : 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5], // Linea punteada
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < dias.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(dias[idx], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: tipo == 'presion' ? 20 : 50,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (ultimos.length - 1).toDouble(),
          minY: tipo == 'presion' ? 60 : 0,
          maxY: tipo == 'presion' ? 160 : 250,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y.toInt()}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: tipo == 'presion' ? [
            // Linea Sistolica (Azul)
            LineChartBarData(
              spots: spotsSistolica,
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF3B82F6),
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // Linea Diastolica (Verde)
            LineChartBarData(
              spots: spotsDiastolica,
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF10B981),
                ),
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ] : [
            // Glucosa o peso (Una sola linea azul)
            LineChartBarData(
              spots: spotsUnicos,
              isCurved: true,
              color: const Color(0xFF0EA5E9),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFF0EA5E9),
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}