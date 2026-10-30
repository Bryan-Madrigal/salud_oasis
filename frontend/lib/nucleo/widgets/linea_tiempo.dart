import 'package:flutter/material.dart';
import '../tema/tema_app.dart';

/// Un evento individual del timeline.
class EventoLineaTiempo {
  final DateTime fechaHora;
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final String? etiqueta;
  final Color? colorEtiqueta;

  const EventoLineaTiempo({
    required this.fechaHora,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    this.etiqueta,
    this.colorEtiqueta,
  });
}

class LineaTiempo extends StatelessWidget {
  final List<EventoLineaTiempo> eventos;

  const LineaTiempo({super.key, required this.eventos});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (eventos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: colors.shadowSoft,
        ),
        child: Center(
          child: Text(
            'Sin eventos registrados',
            style: TextStyle(color: colors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colors.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < eventos.length; i++)
            _ItemLineaTiempo(
              evento: eventos[i],
              esPrimero: i == 0,
              esUltimo: i == eventos.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ItemLineaTiempo extends StatelessWidget {
  final EventoLineaTiempo evento;
  final bool esPrimero;
  final bool esUltimo;

  const _ItemLineaTiempo({
    required this.evento,
    required this.esPrimero,
    required this.esUltimo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna del indicador
          SizedBox(
            width: 36,
            child: Column(
              children: [
                // Ícono
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: evento.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: evento.color.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    evento.icono,
                    color: evento.color,
                    size: 16,
                  ),
                ),
                // Línea conectora (excepto en el último)
                if (!esUltimo)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Contenido
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: esUltimo ? AppSpacing.lg : AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fecha
                  Text(
                    _formatearFecha(evento.fechaHora),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Título + tag
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          evento.titulo,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      if (evento.etiqueta != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (evento.colorEtiqueta ?? evento.color)
                                .withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            evento.etiqueta!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: evento.colorEtiqueta ?? evento.color,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Subtítulo
                  Text(
                    evento.subtitulo,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime d) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final ahora = DateTime.now();
    final esHoy = d.year == ahora.year &&
        d.month == ahora.month &&
        d.day == ahora.day;
    if (esHoy) return 'HOY';

    final ayer = ahora.subtract(const Duration(days: 1));
    final esAyer = d.year == ayer.year &&
        d.month == ayer.month &&
        d.day == ayer.day;
    if (esAyer) return 'AYER';

    return '${d.day} ${meses[d.month - 1].toUpperCase()} ${d.year}';
  }
}