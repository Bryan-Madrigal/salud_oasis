import 'package:flutter/material.dart';
import '../tema/tema_app.dart';
import '../utilidades/calculadora_adherencia.dart';

class CirculoAdherencia extends StatelessWidget {
  final DatosAdherencia datos;

  const CirculoAdherencia({super.key, required this.datos});

  Color _colorPara(AppColors colores) {
    if (datos.porcentaje >= 0.9) return colores.success;
    if (datos.porcentaje >= 0.7) return colores.primary;
    if (datos.porcentaje >= 0.5) return colores.warning;
    return colores.danger;
  }

  String _titulo() {
    if (datos.porcentaje >= 0.9) return '¡Excelente!';
    if (datos.porcentaje >= 0.7) return 'Buen trabajo';
    if (datos.porcentaje >= 0.5) return 'Atención';
    return 'Mejora tu adherencia';
  }

  String _mensaje() {
    if (datos.porcentaje >= 0.9) return 'Sigue así, lo estás haciendo increíble.';
    if (datos.porcentaje >= 0.7) return 'Casi lo logras, no te detengas.';
    if (datos.porcentaje >= 0.5) return 'Te faltaron varias tomas esta semana.';
    return 'Necesitas retomar tu tratamiento.';
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
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.insights_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ADHERENCIA SEMANAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _titulo(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colores.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Contenido: círculo + stats
          Row(
            children: [
              // Círculo
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 9,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          color.withValues(alpha: 0.12),
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: datos.porcentaje,
                        strokeWidth: 9,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(color),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(datos.porcentaje * 100).round()}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colores.textPrimary,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'semana',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: colores.textTertiary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              // Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LineaEstadistica(
                      icono: Icons.check_circle_outline,
                      color: color,
                      valor: '${datos.completadas}',
                      etiqueta: 'tomas completadas',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LineaEstadistica(
                      icono: Icons.radio_button_unchecked,
                      color: colores.textTertiary,
                      valor: '${(datos.total - datos.completadas).clamp(0, 999)}',
                      etiqueta: 'tomas pendientes',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _mensaje(),
                      style: TextStyle(
                        fontSize: 12,
                        color: colores.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineaEstadistica extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String valor;
  final String etiqueta;

  const _LineaEstadistica({
    required this.icono,
    required this.color,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Row(
      children: [
        Icon(icono, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(
          valor,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colores.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 12,
              color: colores.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}