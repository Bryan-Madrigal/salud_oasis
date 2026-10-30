import 'package:flutter/material.dart';
import '../tema/tema_app.dart';
import '../utilidades/evaluador_salud.dart';
import '../utilidades/rangos_medicion.dart';

class SemaforoSalud extends StatelessWidget {
  final EvaluacionSalud evaluacion;

  const SemaforoSalud({super.key, required this.evaluacion});

  Color _colorPara(AppColors colores) {
    switch (evaluacion.nivel) {
      case NivelSalud.estable:
        return colores.success;
      case NivelSalud.atencion:
        return colores.warning;
      case NivelSalud.riesgo:
        return colores.danger;
    }
  }

  IconData get _icono {
    switch (evaluacion.nivel) {
      case NivelSalud.estable:
        return Icons.check_circle_outline;
      case NivelSalud.atencion:
        return Icons.info_outline;
      case NivelSalud.riesgo:
        return Icons.warning_amber_rounded;
    }
  }

  String _etiquetaCorta() {
    switch (evaluacion.nivel) {
      case NivelSalud.estable:
        return 'Estable';
      case NivelSalud.atencion:
        return 'Atención';
      case NivelSalud.riesgo:
        return 'Riesgo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final color = _colorPara(colores);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icono grande
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icono, color: color, size: 26),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESTADO ACTUAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _etiquetaCorta(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colores.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            evaluacion.titulo,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: colores.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            evaluacion.mensaje,
            style: TextStyle(
              color: colores.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge pequeño para mostrar el estado de una medición.
class EtiquetaEstadoMedicion extends StatelessWidget {
  final EstadoMedicion estado;
  final bool compacto;

  const EtiquetaEstadoMedicion({
    super.key,
    required this.estado,
    this.compacto = false,
  });

  Color _color(AppColors colores) {
    switch (estado) {
      case EstadoMedicion.bajo:
        return colores.info;
      case EstadoMedicion.normal:
        return colores.success;
      case EstadoMedicion.elevado:
        return colores.warning;
      case EstadoMedicion.alto:
        return colores.danger;
      case EstadoMedicion.desconocido:
        return colores.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (estado == EstadoMedicion.desconocido) {
      return const SizedBox.shrink();
    }

    final colores = context.colors;
    final color = _color(colores);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compacto ? 8 : AppSpacing.md,
        vertical: compacto ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        estado.etiqueta,
        style: TextStyle(
          color: color,
          fontSize: compacto ? 10 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}