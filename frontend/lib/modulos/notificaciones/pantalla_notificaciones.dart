import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import '../medicamentos/modelos/medicamento.dart';

class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _EstadoPantallaNotificaciones();
}

class _EstadoPantallaNotificaciones extends State<PantallaNotificaciones> {
  List<dynamic> _citasPaciente = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarNotificacionesCitas();
  }

  Future<void> _cargarNotificacionesCitas() async {
    // CAMBIO AQUÍ: ID dinámico
    final url = Uri.parse('http://localhost:8080/api/citas/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _citasPaciente = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print("Error al cargar notificaciones: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final repo = RepositorioApp.instancia;
    final ahora = DateTime.now();

    final notificacionesLocales = <_Notificacion>[];
    final medicamentos = repo.medicamentos
        .where((m) => m.estado == EstadoMedicamento.activo)
        .toList();

    for (final m in medicamentos) {
      for (final h in m.horarios) {
        if (!m.tomasHoy.contains(h)) {
          notificacionesLocales.add(
            _Notificacion(
              icono: Icons.medication_outlined,
              color: colors.warning,
              titulo: 'Toma pendiente: ${m.nombre}',
              subtitulo: '${m.dosis} · Hoy a las $h',
              grupo: _Grupo.hoy,
              noLeida: true,
            ),
          );
        }
      }
    }

    final notificacionesReales = <_Notificacion>[];
    if (!_cargando) {
      for (final c in _citasPaciente) {
        if (c['estado'] == 'confirmada') {
          final fecha = c['fechaHoraConfirmada'] != null
              ? DateTime.parse(c['fechaHoraConfirmada']).toLocal()
              : ahora;
          notificacionesReales.add(
            _Notificacion(
              icono: Icons.event_available,
              color: colors.primary,
              titulo: '¡Cita confirmada!',
              subtitulo: '${c['motivo']} · ${fecha.day}/${fecha.month} a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
              grupo: _Grupo.hoy,
              noLeida: true,
            ),
          );
        } else if (c['estado'] == 'pendiente') {
          notificacionesReales.add(
            _Notificacion(
              icono: Icons.hourglass_top_outlined,
              color: colors.warning,
              titulo: 'Solicitud en revisión',
              subtitulo: '${c['tipo']} · ${c['fechaPreferida']}',
              grupo: _Grupo.hoy,
              noLeida: true,
            ),
          );
        }
      }
    }

    final todas = [...notificacionesReales, ...notificacionesLocales];

    final hoy = todas.where((n) => n.grupo == _Grupo.hoy).toList();
    final semana = todas.where((n) => n.grupo == _Grupo.semana).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : todas.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Text(
                        'No tienes notificaciones',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    children: [
                      if (hoy.isNotEmpty) ...[
                        const _EtiquetaSeccion(texto: 'Hoy'),
                        for (final n in hoy) _TarjetaNotificacion(datos: n),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (semana.isNotEmpty) ...[
                        const _EtiquetaSeccion(texto: 'Esta semana'),
                        for (final n in semana) _TarjetaNotificacion(datos: n),
                      ],
                    ],
                  ),
      ),
    );
  }
}

enum _Grupo { hoy, semana }

class _Notificacion {
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final _Grupo grupo;
  final bool noLeida;

  const _Notificacion({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.grupo,
    this.noLeida = false,
  });
}

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;

  const _EtiquetaSeccion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
        top: AppSpacing.xs,
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final _Notificacion datos;

  const _TarjetaNotificacion({required this.datos});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: datos.noLeida
            ? colors.primary.withValues(alpha: 0.06)
            : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: datos.noLeida ? colors.shadowMedium : colors.shadowSoft,
        border: datos.noLeida
            ? Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: datos.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(datos.icono, color: datos.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        datos.titulo,
                        style: TextStyle(
                          fontWeight: datos.noLeida
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: colors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (datos.noLeida)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  datos.subtitulo,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}