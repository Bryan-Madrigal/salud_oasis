import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../nucleo/tema/tema_app.dart';
import '../modelos/registro_seguimiento.dart';

class GraficaEvolucion extends StatelessWidget {
  final List<RegistroSeguimiento> registros;
  final String tipo;

  const GraficaEvolucion({
    super.key,
    required this.registros,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    final filtrados = registros.where((r) => r.tipo == tipo).toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    if (filtrados.length < 2) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colores.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colores.border),
        ),
        child: Text(
          'Se necesitan al menos 2 mediciones\npara mostrar la gráfica',
          textAlign: TextAlign.center,
          style: TextStyle(color: colores.textSecondary),
        ),
      );
    }

    final puntos1 = <FlSpot>[];
    final puntos2 = <FlSpot>[];
    bool esLineaDoble = tipo == 'presion';

    for (int i = 0; i < filtrados.length; i++) {
      final valorStr = filtrados[i].valor;
      if (esLineaDoble) {
        final partes = valorStr.split('/');
        if (partes.length == 2) {
          final sistolica = double.tryParse(partes[0]) ?? 0;
          final diastolica = double.tryParse(partes[1]) ?? 0;
          puntos1.add(FlSpot(i.toDouble(), sistolica));
          puntos2.add(FlSpot(i.toDouble(), diastolica));
        }
      } else {
        final valor = double.tryParse(valorStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        puntos1.add(FlSpot(i.toDouble(), valor));
      }
    }

    double minY = 0, maxY = 200;
    if (esLineaDoble) {
      final todosLosValores = [...puntos1.map((e) => e.y), ...puntos2.map((e) => e.y)];
      if (todosLosValores.isNotEmpty) {
        final valorMin = todosLosValores.reduce((a, b) => a < b ? a : b);
        final valorMax = todosLosValores.reduce((a, b) => a > b ? a : b);
        minY = (valorMin - 20).clamp(0, double.infinity);
        maxY = valorMax + 20;
      }
    } else {
      if (puntos1.isNotEmpty) {
        final valorMin = puntos1.map((e) => e.y).reduce((a, b) => a < b ? a : b);
        final valorMax = puntos1.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        minY = (valorMin - (valorMax - valorMin) * 0.2).clamp(0, double.infinity);
        maxY = valorMax + (valorMax - valorMin) * 0.2;
      }
    }

    // Definimos colores seguros que no sean nulos
    final color1 = esLineaDoble ? colores.info : colores.primary;
    final color2 = colores.success;

    return Column(
      children: [
        Container(
          height: 240,
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
          decoration: BoxDecoration(
            color: colores.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colores.border),
          ),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: esLineaDoble ? 20 : null,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colores.border,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    interval: esLineaDoble ? 20 : null,
                    getTitlesWidget: (value, meta) => Text(
                      '${value.toInt()} ${tipo == 'presion' ? 'mmHg' : ''}',
                      style: TextStyle(fontSize: 10, color: colores.textSecondary),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= filtrados.length) return const SizedBox.shrink();
                      if (esLineaDoble) {
                        return Text(filtrados[i].valor, style: TextStyle(fontSize: 10, color: colores.textSecondary));
                      }
                      final d = filtrados[i].fechaHora;
                      return Text('${d.day}/${d.month}', style: TextStyle(fontSize: 10, color: colores.textSecondary));
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((s) {
                      final esSistolica = s.barIndex == 0;
                      final etiqueta = esLineaDoble ? (esSistolica ? 'Sistólica' : 'Diastólica') : tipo;
                      return LineTooltipItem(
                        '$etiqueta: ${s.y.toInt()}',
                        TextStyle(color: s.bar.color ?? color1, fontWeight: FontWeight.bold),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: puntos1,
                  isCurved: true,
                  color: color1,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 3,
                      color: color1,
                      strokeWidth: 0,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color1.withValues(alpha: 0.05),
                  ),
                ),
                if (esLineaDoble)
                  LineChartBarData(
                    spots: puntos2,
                    isCurved: true,
                    color: color2,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: color2,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PuntoLeyenda(color: color1, etiqueta: esLineaDoble ? 'Sistólica' : tipo),
            if (esLineaDoble) ...[
              const SizedBox(width: AppSpacing.lg),
              _PuntoLeyenda(color: color2, etiqueta: 'Diastólica'),
            ],
          ],
        ),
      ],
    );
  }
}

class _PuntoLeyenda extends StatelessWidget {
  final Color color;
  final String etiqueta;
  
  const _PuntoLeyenda({required this.color, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(etiqueta, style: TextStyle(fontSize: 12, color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}