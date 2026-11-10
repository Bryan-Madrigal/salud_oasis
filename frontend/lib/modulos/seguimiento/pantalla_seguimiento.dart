import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import 'pantalla_formulario_seguimiento.dart';
import 'modelos/registro_seguimiento.dart';

class PantallaSeguimiento extends StatefulWidget {
  const PantallaSeguimiento({super.key});

  @override
  State<PantallaSeguimiento> createState() => _EstadoPantallaSeguimiento();
}

class _EstadoPantallaSeguimiento extends State<PantallaSeguimiento> {
  List<RegistroSeguimiento> _registros = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final url = Uri.parse('http://localhost:8080/api/seguimiento/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _registros = data.map((json) => RegistroSeguimiento.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error al cargar seguimiento: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatearFechaLarga() {
    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final dias = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];
    final ahora = DateTime.now();
    return '${dias[ahora.weekday - 1]}, ${ahora.day} DE ${meses[ahora.month - 1].toUpperCase()}';
  }

  RegistroSeguimiento? _ultimoDeTipo(String tipo) {
    try {
      return _registros.firstWhere((r) => r.tipo == tipo);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    final ultimaPresion = _ultimoDeTipo('presion');
    final ultimaGlucosa = _ultimoDeTipo('glucosa');
    final ultimoPeso = _ultimoDeTipo('peso');
    final ultimoBienestar = _ultimoDeTipo('checkin');

    // El registro mas reciente de todos para "Mi actividad"
    final registroReciente = _registros.isNotEmpty ? _registros.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarRegistros,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ENCABEZADO
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatearFechaLarga(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        const Text('Mi seguimiento', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const Text('Conoce como evoluciona tu salud.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.show_chart, color: Colors.blue),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // RESUMEN DE SALUD
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Resumen de salud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                      child: const Text('3 indicadores', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                
                // Grid de 4 tarjetas
                Row(
                  children: [
                    Expanded(child: _TarjetaResumen(titulo: 'Presion arterial', valor: ultimaPresion?.valor ?? '--', unidad: ultimaPresion?.unidad ?? 'mmHg', icono: Icons.favorite_border, colorIcono: Colors.blue, registrado: ultimaPresion != null)),
                    const SizedBox(width: 12),
                    Expanded(child: _TarjetaResumen(titulo: 'Glucosa', valor: ultimaGlucosa?.valor ?? '--', unidad: ultimaGlucosa?.unidad ?? 'mg/dL', icono: Icons.water_drop_outlined, colorIcono: Colors.orange, registrado: ultimaGlucosa != null)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _TarjetaResumen(titulo: 'Peso', valor: ultimoPeso?.valor ?? '--', unidad: ultimoPeso?.unidad ?? 'kg', icono: Icons.monitor_weight_outlined, colorIcono: Colors.green, registrado: ultimoPeso != null)),
                    const SizedBox(width: 12),
                    Expanded(child: _TarjetaResumen(titulo: 'Bienestar', valor: ultimoBienestar?.valor ?? '--', unidad: ultimoBienestar != null ? 'Ultimo check-in' : '', icono: Icons.mood, colorIcono: Colors.pink, registrado: ultimoBienestar != null)),
                  ],
                ),
                const SizedBox(height: 24),

                // MI ACTIVIDAD (Ultimo registro)
                if (registroReciente != null) ...[
                  const Text('Mi actividad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ULTIMO REGISTRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(registroReciente.nombreMostrar, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        Text('${registroReciente.valor} ${registroReciente.unidad}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 8),
                        Text('${registroReciente.fechaFormateada} - ${registroReciente.horaFormateada}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // BOTON DE REGISTRAR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('Registrar medicion', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Actualiza tus indicadores de salud.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: FilledButton(
                          onPressed: () async {
                            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaFormularioSeguimiento()));
                            if (res == true) _cargarRegistros();
                          },
                          style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0EA5E9)),
                          child: const Text('Nueva medicion ->', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= WIDGETS AUXILIARES =================

class _TarjetaResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final String unidad;
  final IconData icono;
  final Color colorIcono;
  final bool registrado;

  const _TarjetaResumen({
    required this.titulo, required this.valor, required this.unidad, required this.icono, required this.colorIcono, required this.registrado
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icono, color: colorIcono, size: 24),
              if (registrado)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Registrado', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                )
            ],
          ),
          const SizedBox(height: 16),
          Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Text(unidad, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}