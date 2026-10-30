import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';

class PantallaReportes extends StatefulWidget {
  const PantallaReportes({super.key});

  @override
  State<PantallaReportes> createState() => _EstadoPantallaReportes();
}

class _EstadoPantallaReportes extends State<PantallaReportes> {
  int _totalPacientes = 0;
  int _totalRecetas = 0;
  int _citasCompletadas = 0;
  int _citasPendientes = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final idMedico = RepositorioApp.instancia.idMedicoActual;
    
    final urlPacientes = Uri.parse('http://localhost:8080/api/pacientes');
    final urlRecetas = Uri.parse('http://localhost:8080/api/recetas/medico/$idMedico');
    final urlCitas = Uri.parse('http://localhost:8080/api/citas/medico/$idMedico');

    try {
      final respuestas = await Future.wait([
        http.get(urlPacientes),
        http.get(urlRecetas),
        http.get(urlCitas),
      ]);

      if (respuestas[0].statusCode == 200) {
        final pacientes = jsonDecode(respuestas[0].body) as List;
        _totalPacientes = pacientes.length;
      }

      if (respuestas[1].statusCode == 200) {
        final recetas = jsonDecode(respuestas[1].body) as List;
        _totalRecetas = recetas.length;
      }

      if (respuestas[2].statusCode == 200) {
        final citas = jsonDecode(respuestas[2].body) as List;
        
        _citasCompletadas = citas.where((c) => c['estado'] == 'completada').length;
        _citasPendientes = citas.where((c) => c['estado'] == 'pendiente' || c['estado'] == 'confirmada').length;
      }
    } catch (e) {
      debugPrint("Error al cargar reportes: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    if (_cargando) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reportes de mi consulta',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.textPrimary, letterSpacing: -0.3),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Resumen de actividad y estadisticas',
              style: TextStyle(color: colores.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tarjeta Principal (Hero Card)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppGradients.ocean,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: colores.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.bar_chart, color: Colors.white, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Total de Pacientes',
                    style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalPacientes',
                    style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              'Desglose de actividad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),

            // Grid de Tarjetas
            Row(
              children: [
                Expanded(
                  child: _TarjetaReporte(
                    titulo: 'Recetas Emitidas',
                    valor: '$_totalRecetas',
                    icono: Icons.receipt_long,
                    color: colores.info,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _TarjetaReporte(
                    titulo: 'Citas Atendidas',
                    valor: '$_citasCompletadas',
                    icono: Icons.check_circle_outline,
                    color: colores.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TarjetaReporte(
                    titulo: 'Citas Pendientes',
                    valor: '$_citasPendientes',
                    icono: Icons.hourglass_empty,
                    color: colores.warning,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox()), // Espacio vacio para mantener el grid
              ],
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Mensaje motivacional
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colores.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(Icons.insights, color: colores.primary, size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Sigue asi! Tu labor diaria mejora la calidad de vida de tus pacientes.',
                      style: TextStyle(color: colores.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReporte extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _TarjetaReporte({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            valor,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colores.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            titulo,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colores.textSecondary),
          ),
        ],
      ),
    );
  }
}