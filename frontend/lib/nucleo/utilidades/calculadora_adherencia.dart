import '../../modulos/medicamentos/modelos/medicamento.dart';

class DatosAdherencia {
  final double porcentaje;
  final int completadas;
  final int total;

  const DatosAdherencia({
    required this.porcentaje,
    required this.completadas,
    required this.total,
  });

  bool get tieneDatos => total > 0;
}

class CalculadoraAdherencia {
  /// Calcula la adherencia de los últimos 7 días.
  static DatosAdherencia semanal(List<Medicamento> medicamentos) {
    final ahora = DateTime.now();
    int total = 0;
    int completadas = 0;

    for (int i = 0; i < 7; i++) {
      final dia = ahora.subtract(Duration(days: i));
      final diaSolo = DateTime(dia.year, dia.month, dia.day);
      final claveDia = claveFecha(dia);

      for (final m in medicamentos) {
        if (m.estado != EstadoMedicamento.activo) continue;
        
        final inicio = DateTime(m.fechaInicio.year, m.fechaInicio.month, m.fechaInicio.day);
        final fin = DateTime(m.fechaFin.year, m.fechaFin.month, m.fechaFin.day);
        
        if (diaSolo.isBefore(inicio) || diaSolo.isAfter(fin)) continue;

        for (final hora in m.horarios) {
          total++;
          if (m.historialTomas.contains('$claveDia|$hora')) {
            completadas++;
          }
        }
      }
    }

    final porcentaje = total == 0 ? 0.0 : (completadas / total).clamp(0.0, 1.0);
    return DatosAdherencia(
      porcentaje: porcentaje,
      completadas: completadas,
      total: total,
    );
  }

  static String claveFecha(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}