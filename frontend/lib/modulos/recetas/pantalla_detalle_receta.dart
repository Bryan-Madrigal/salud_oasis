import 'package:flutter/material.dart';
import '../../nucleo/tema/tema_app.dart';
import 'modelos/receta.dart';

class PantallaDetalleReceta extends StatelessWidget {
  final Receta receta;

  const PantallaDetalleReceta({
    super.key,
    required this.receta,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Receta ${receta.idFormateado}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Descargar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Descargar receta (proximamente)')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Imprimir receta (proximamente)')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colores.primary,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'RECETA ${receta.idFormateado}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _CampoEncabezado(etiqueta: 'Paciente', valor: receta.nombrePaciente),
                    const SizedBox(height: AppSpacing.sm),
                    _CampoEncabezado(etiqueta: 'Medico', valor: receta.nombreMedico),
                    const SizedBox(height: AppSpacing.sm),
                    _CampoEncabezado(etiqueta: 'Fecha', valor: receta.fechaFormateada),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              for (int i = 0; i < receta.items.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _TarjetaMedicamento(item: receta.items[i], indice: i + 1),
              ],

              if (receta.notas != null && receta.notas!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text('Indicaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: colores.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Text(receta.notas!, style: TextStyle(color: colores.textPrimary, height: 1.5)),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              Center(
                child: Column(
                  children: [
                    Container(width: 180, height: 1, color: colores.textSecondary.withValues(alpha: 0.4)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(receta.nombreMedico, style: TextStyle(color: colores.textPrimary, fontWeight: FontWeight.w600)),
                    Text('Medico tratante', style: TextStyle(color: colores.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoEncabezado extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _CampoEncabezado({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(etiqueta, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Expanded(child: Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
      ],
    );
  }
}

class _TarjetaMedicamento extends StatelessWidget {
  final ItemReceta item;
  final int indice;

  const _TarjetaMedicamento({required this.item, required this.indice});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: colores.primary.withValues(alpha: 0.12),
                child: Text('$indice', style: TextStyle(color: colores.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(item.nombreMedicamento, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 16))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _CampoItem(etiqueta: 'Dosis', valor: item.dosis, icono: Icons.straighten)),
              Expanded(child: _CampoItem(etiqueta: 'Frecuencia', valor: item.frecuencia, icono: Icons.access_time)),
              Expanded(child: _CampoItem(etiqueta: 'Duracion', valor: item.duracion, icono: Icons.event_repeat)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampoItem extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final IconData icono;

  const _CampoItem({required this.etiqueta, required this.valor, required this.icono});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, size: 12, color: colores.textTertiary),
            const SizedBox(width: AppSpacing.xs),
            Text(etiqueta, style: TextStyle(fontSize: 11, color: colores.textTertiary)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(valor, style: TextStyle(color: colores.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}