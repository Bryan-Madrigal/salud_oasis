import '../../modulos/seguimiento/modelos/registro_seguimiento.dart';
import 'rangos_medicion.dart';

/// Nivel general de salud del paciente.
enum NivelSalud { estable, atencion, riesgo }

class EvaluacionSalud {
  final NivelSalud nivel;
  final String titulo;
  final String mensaje;

  const EvaluacionSalud({
    required this.nivel,
    required this.titulo,
    required this.mensaje,
  });
}

class EvaluadorSalud {
  /// Evalúa el estado general a partir de las últimas mediciones.
  ///
  /// Regla:
  /// - estable: todas las últimas mediciones están normales.
  /// - atencion: 1-2 mediciones fuera de rango (elevado).
  /// - riesgo: 3+ mediciones fuera de rango o alguna en "alto".
  static EvaluacionSalud evaluar(List<RegistroSeguimiento> registros) {
    if (registros.isEmpty) {
      return const EvaluacionSalud(
        nivel: NivelSalud.estable,
        titulo: 'Sin datos aún',
        mensaje: 'Comienza a registrar tus mediciones para ver tu estado.',
      );
    }

    // Tomamos las últimas mediciones (una por tipo).
    final ultimosPorTipo = <String, RegistroSeguimiento>{};
    for (final r in registros) {
      ultimosPorTipo.putIfAbsent(r.tipo, () => r);
    }

    int elevados = 0;
    int altos = 0;

    ultimosPorTipo.forEach((tipo, registro) {
      final estado = RangosMedicion.evaluarRegistro(
        tipo: tipo,
        valor: registro.valor,
      );
      if (estado == EstadoMedicion.elevado ||
          estado == EstadoMedicion.bajo) {
        elevados++;
      } else if (estado == EstadoMedicion.alto) {
        altos++;
      }
    });

    if (altos >= 1 || elevados >= 3) {
      return const EvaluacionSalud(
        nivel: NivelSalud.riesgo,
        titulo: 'Requiere atención',
        mensaje:
            'Detectamos valores fuera de rango. Contacta a tu médico.',
      );
    }

    if (elevados >= 1) {
      return const EvaluacionSalud(
        nivel: NivelSalud.atencion,
        titulo: 'Atención moderada',
        mensaje:
            'Algunos valores están fuera de rango. Sigue monitoreando.',
      );
    }

    return const EvaluacionSalud(
      nivel: NivelSalud.estable,
      titulo: 'Tu salud está estable',
      mensaje: 'Tus últimas mediciones están dentro de los valores normales.',
    );
  }
}