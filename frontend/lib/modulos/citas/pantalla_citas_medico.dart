import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart'; // <-- IMPORTANTE AÑADIDO
import '../../nucleo/tema/tema_app.dart';
import '../pacientes/pantalla_detalle_paciente.dart';
import 'pantalla_confirmar_cita.dart';
import 'modelos/cita.dart';

class PantallaCitasMedico extends StatefulWidget {
  const PantallaCitasMedico({super.key});

  @override
  State<PantallaCitasMedico> createState() => _EstadoPantallaCitasMedico();
}

class _EstadoPantallaCitasMedico extends State<PantallaCitasMedico> {
  List<Cita> _citas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    // CAMBIO AQUÍ: ID dinámico
    final url = Uri.parse('http://localhost:8080/api/citas/medico/${RepositorioApp.instancia.idMedicoActual}'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _citas = data.map((json) => Cita.fromJson(json)).toList();
          _cargando = false;
        });
      }
    } catch (e) {
      print("Error al cargar citas: $e");
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final pendientes = _citas.where((c) => c.estaPendiente).toList()
      ..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));
    final programadas = _citas.where((c) => c.estaConfirmada).toList()
      ..sort((a, b) => a.fechaHoraEfectiva.compareTo(b.fechaHoraEfectiva));
    final historial = _citas.where((c) => c.estaCompletada || c.estaCancelada).toList()
      ..sort((a, b) => b.fechaHoraEfectiva.compareTo(a.fechaHoraEfectiva));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Citas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.textPrimary)),
          Text('Solicitudes y agenda de consultas', style: TextStyle(color: colores.textSecondary)),
          const SizedBox(height: AppSpacing.xl),

          _EtiquetaSeccion(texto: 'Solicitudes pendientes', cantidad: pendientes.length, color: colores.warning),
          const SizedBox(height: AppSpacing.md),
          if (pendientes.isEmpty)
            _CajaVacia(texto: 'No tienes solicitudes pendientes')
          else
            for (final cita in pendientes) 
              _TarjetaSolicitudPendiente(
                cita: cita, 
                alConfirmar: _cargarCitas
              ),
          
          const SizedBox(height: AppSpacing.xl),

          _EtiquetaSeccion(texto: 'Agenda', cantidad: programadas.length, color: colores.primary),
          const SizedBox(height: AppSpacing.md),
          if (programadas.isEmpty)
            _CajaVacia(texto: 'Sin citas programadas')
          else
            for (final cita in programadas) _TarjetaProgramada(cita: cita),
          
          const SizedBox(height: AppSpacing.xl),

          _EtiquetaSeccion(texto: 'Historial', cantidad: historial.length, color: colores.textSecondary),
          const SizedBox(height: AppSpacing.md),
          if (historial.isEmpty)
            _CajaVacia(texto: 'Sin citas anteriores')
          else
            for (final cita in historial) _FilaHistorial(cita: cita),
            
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ============ WIDGETS DE DISEÑO ============

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;
  final int cantidad;
  final Color color;

  const _EtiquetaSeccion({required this.texto, required this.cantidad, required this.color});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Row(
      children: [
        Text(texto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary)),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.full)),
          child: Text('$cantidad', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _CajaVacia extends StatelessWidget {
  final String texto;
  const _CajaVacia({required this.texto});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
      child: Center(child: Text(texto, style: TextStyle(color: colores.textSecondary))),
    );
  }
}

class _TarjetaSolicitudPendiente extends StatelessWidget {
  final Cita cita;
  final VoidCallback alConfirmar;

  const _TarjetaSolicitudPendiente({required this.cita, required this.alConfirmar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
        border: Border.all(color: colores.warning.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colores.primary.withValues(alpha: 0.12),
                child: Text(
                  cita.nombrePaciente.isNotEmpty ? cita.nombrePaciente.substring(0, 1) : '?',
                  style: TextStyle(color: colores.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cita.nombrePaciente, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(cita.tipo, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(color: colores.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text('Pendiente', style: TextStyle(color: colores.warning, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: colores.divider),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: colores.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Text('${cita.fechaPreferidaFormateada} · ${cita.horarioPreferido.etiqueta}', style: TextStyle(fontSize: 13, color: colores.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.description_outlined, size: 14, color: colores.textTertiary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(cita.motivo, style: TextStyle(fontSize: 13, color: colores.textSecondary))),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PantallaDetallePaciente(nombrePaciente: cita.nombrePaciente)),
                    );
                  },
                  icon: const Icon(Icons.folder_shared_outlined, size: 18),
                  label: const Text('Ver expediente'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PantallaConfirmarCita(cita: cita)),
                );
                if (resultado == true) {
                  alConfirmar();
                }
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Confirmar cita'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProgramada extends StatelessWidget {
  final Cita cita;
  const _TarjetaProgramada({required this.cita});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(color: colores.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Column(
              children: [
                Text(cita.horaFormateada, style: TextStyle(color: colores.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${cita.fechaHoraEfectiva.day} ${cita.mesAbreviado}', style: TextStyle(color: colores.primary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cita.nombrePaciente, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                const SizedBox(height: 2),
                Text(cita.motivo, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colores.textTertiary),
        ],
      ),
    );
  }
}

class _FilaHistorial extends StatelessWidget {
  final Cita cita;
  const _FilaHistorial({required this.cita});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final esCancelada = cita.estaCancelada;
    final colorEstado = esCancelada ? colores.danger : colores.info;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(esCancelada ? Icons.cancel_outlined : Icons.check_circle_outline, color: colorEstado, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cita.nombrePaciente, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${cita.fechaFormateada} · ${cita.motivo}', style: TextStyle(color: colores.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(color: colorEstado.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.full)),
            child: Text(cita.estado.etiqueta, style: TextStyle(color: colorEstado, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}