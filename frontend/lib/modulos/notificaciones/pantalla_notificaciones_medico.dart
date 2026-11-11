import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import 'widgets/tarjeta_notificacion.dart'; // Importamos el diseño

class PantallaNotificacionesMedico extends StatefulWidget {
  const PantallaNotificacionesMedico({super.key});

  @override
  State<PantallaNotificacionesMedico> createState() => _EstadoPantallaNotificacionesMedico();
}

class _EstadoPantallaNotificacionesMedico extends State<PantallaNotificacionesMedico> {
  List<dynamic> _citas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final url = Uri.parse('http://localhost:8080/api/citas/medico/${RepositorioApp.instancia.idMedicoActual}');
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

    for (final c in _citas) {
      DateTime fechaNotif = ahora;
      if (c['estado'] == 'confirmada' && c['fechaHoraConfirmada'] != null) {
        fechaNotif = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
      } else if (c['estado'] == 'pendiente' && c['fechaPreferida'] != null) {
        try { fechaNotif = DateTime.parse(c['fechaPreferida']); } catch (_) {}
      }

      final nombrePaciente = c['paciente']?['usuario']?['nombre'] ?? 'Un paciente';

      if (c['estado'] == 'pendiente') {
        notificaciones.add(
          NotificacionModelo(
            fecha: fechaNotif,
            icono: Icons.notification_important_outlined,
            color: const Color(0xFFD97706), // Naranja
            titulo: 'Nueva solicitud de cita',
            subtitulo: '$nombrePaciente · ${c['motivo'] ?? 'Consulta general'}',
          ),
        );
      } else if (c['estado'] == 'confirmada') {
        notificaciones.add(
          NotificacionModelo(
            fecha: fechaNotif,
            icono: Icons.event_available,
            color: const Color(0xFF0284C7), // Azul
            titulo: 'Cita confirmada',
            subtitulo: '$nombrePaciente · ${fechaNotif.day}/${fechaNotif.month} a las ${fechaNotif.hour}:${fechaNotif.minute.toString().padLeft(2, '0')}',
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