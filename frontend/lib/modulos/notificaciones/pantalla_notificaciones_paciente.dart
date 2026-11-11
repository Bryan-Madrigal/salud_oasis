import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../medicamentos/modelos/medicamento.dart';
import 'widgets/tarjeta_notificacion.dart'; // Importamos el diseño

class PantallaNotificacionesPaciente extends StatefulWidget {
  const PantallaNotificacionesPaciente({super.key});

  @override
  State<PantallaNotificacionesPaciente> createState() => _EstadoPantallaNotificacionesPaciente();
}

class _EstadoPantallaNotificacionesPaciente extends State<PantallaNotificacionesPaciente> {
  List<dynamic> _citas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final url = Uri.parse('http://localhost:8080/api/citas/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _citas = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final ahora = DateTime.now();
    final notificaciones = <NotificacionModelo>[];

    // 1. Medicamentos pendientes (de tu RepositorioApp)
    final medicamentos = RepositorioApp.instancia.medicamentos.where((m) => m.estado == EstadoMedicamento.activo).toList();
    for (final m in medicamentos) {
      for (final h in m.horarios) {
        if (!m.tomasHoy.contains(h)) {
          notificaciones.add(
            NotificacionModelo(
              fecha: ahora,
              icono: Icons.medication_outlined,
              color: const Color(0xFFD97706), // Naranja
              titulo: 'Toma pendiente: ${m.nombre}',
              subtitulo: '${m.dosis} · Hoy a las $h',
            ),
          );
        }
      }
    }

    // 2. Citas del paciente
    for (final c in _citas) {
      DateTime fechaNotif = ahora;
      if (c['estado'] == 'confirmada' && c['fechaHoraConfirmada'] != null) {
        fechaNotif = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
      } else if (c['estado'] == 'pendiente' && c['fechaPreferida'] != null) {
        try { fechaNotif = DateTime.parse(c['fechaPreferida']); } catch (_) {}
      }

      if (c['estado'] == 'confirmada') {
        notificaciones.add(
          NotificacionModelo(
            fecha: fechaNotif,
            icono: Icons.event_available,
            color: const Color(0xFF0284C7), // Azul
            titulo: '¡Cita confirmada!',
            subtitulo: '${c['motivo']} · ${fechaNotif.day}/${fechaNotif.month} a las ${fechaNotif.hour}:${fechaNotif.minute.toString().padLeft(2, '0')}',
          ),
        );
      } else if (c['estado'] == 'pendiente') {
        notificaciones.add(
          NotificacionModelo(
            fecha: fechaNotif,
            icono: Icons.hourglass_empty,
            color: const Color(0xFFD97706),
            titulo: 'Solicitud en revisión',
            subtitulo: '${c['motivo']} · ${c['fechaPreferida'] ?? 'Por definir'}',
          ),
        );
      }
    }

    // Agrupamos y mostramos
    final agrupadas = agruparNotificaciones(notificaciones);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: agrupadas.isEmpty
          ? const Center(child: Text('No tienes notificaciones'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (var entry in agrupadas.entries) ...[
                  EtiquetaSeccion(texto: entry.key),
                  for (final n in entry.value) TarjetaNotificacion(datos: n),
                  const SizedBox(height: 16),
                ]
              ],
            ),
    );
  }
}