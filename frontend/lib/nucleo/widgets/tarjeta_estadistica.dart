import 'package:flutter/material.dart';
import '../tema/tema_app.dart';

class TarjetaEstadistica extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final String? unidad;
  final IconData icono;
  final Color? color;
  final VoidCallback? alPresionar;

  const TarjetaEstadistica({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    this.unidad,
    this.color,
    this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = color ?? colors.primary;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: colors.shadowSoft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono con fondo suave
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: accent, size: 20),
              ),
              const SizedBox(height: AppSpacing.md),

              // Etiqueta
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Valor grande
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      valor,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (unidad != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      unidad!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}