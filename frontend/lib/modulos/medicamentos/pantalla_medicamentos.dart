import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import 'pantalla_toma_medicamento.dart';

class PantallaMedicamentos extends StatefulWidget {
  const PantallaMedicamentos({super.key});

  @override
  State<PantallaMedicamentos> createState() => _EstadoPantallaMedicamentos();
}

class _EstadoPantallaMedicamentos extends State<PantallaMedicamentos> {
  List<dynamic> _medicamentos = [];
  List<DosisHoy> _dosisDeHoy = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    final url = Uri.parse('http://localhost:8080/api/medicamentos/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _medicamentos = jsonDecode(response.body);
        _procesarDosis();
      }
    } catch (e) {
      debugPrint("Error al cargar medicamentos: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _procesarDosis() {
    _dosisDeHoy.clear();
    final ahora = DateTime.now();
    final fechaHoyStr = "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";

    for (var med in _medicamentos) {
      if (med['estado'] != 'activo') continue;
      
      final horarios = med['horarios'] as List;
      final historial = med['historialTomas'] as List;

      for (var h in horarios) {
        final hora = h['horaDia'];
        
        final registro = historial.firstWhere(
          (hist) => hist['fechaProgramada'] == fechaHoyStr && hist['horaProgramada'] == hora,
          orElse: () => null,
        );

        String estado = 'programada';
        String? horaRegistro;

        if (registro != null) {
          if (registro['estado'] == 'tomada') {
            estado = 'completada';
            if (registro['fechaRegistro'] != null) {
              final dt = DateTime.parse(registro['fechaRegistro']).toLocal();
              horaRegistro = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }
          } else if (registro['estado'] == 'omitida') {
            estado = 'omitida';
          }
        }

        _dosisDeHoy.add(DosisHoy(
          medicamento: med,
          hora: hora,
          estado: estado,
          horaRegistro: horaRegistro,
        ));
      }
    }

    _dosisDeHoy.sort((a, b) => a.hora.compareTo(b.hora));

    bool proximaAsignada = false;
    for (int i = 0; i < _dosisDeHoy.length; i++) {
      if (_dosisDeHoy[i].estado == 'programada' && !proximaAsignada) {
        _dosisDeHoy[i] = _dosisDeHoy[i].copyWith(estado: 'proxima');
        proximaAsignada = true;
      }
    }
  }

  String _formatearFechaLarga() {
    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final dias = ['LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'];
    final ahora = DateTime.now();
    return '${dias[ahora.weekday - 1]} - ${ahora.day} DE ${meses[ahora.month - 1].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    final totalTomas = _dosisDeHoy.length;
    final tomasCompletadas = _dosisDeHoy.where((d) => d.estado == 'completada').length;
    final progreso = totalTomas > 0 ? tomasCompletadas / totalTomas : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EL ENCABEZADO DUPLICADO DE "MI OASIS" FUE ELIMINADO DE AQUI

              Text(_formatearFechaLarga(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 8),
              const Text('Mi tratamiento', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Text('Organiza tus medicamentos durante el dia.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TRATAMIENTO DIARIO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
                          const SizedBox(height: 8),
                          Text('$tomasCompletadas de $totalTomas', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const Text('Tomas registradas', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Text('Tu progreso se actualiza con las tomas que confirmas.', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: progreso,
                            strokeWidth: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                          ),
                        ),
                        Text('${(progreso * 100).round()}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Agenda de hoy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text('Ver todas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                ],
              ),
              const SizedBox(height: 16),

              if (_dosisDeHoy.isEmpty)
                const Center(child: Text('No hay medicamentos programados para hoy.'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dosisDeHoy.length,
                  itemBuilder: (context, index) {
                    final dosis = _dosisDeHoy[index];
                    return _TimelineDosisItem(dosis: dosis, onRecargar: _cargarMedicamentos);
                  },
                ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Consejo del dia', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A), fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Manten tus medicamentos organizados y sigue las indicaciones de tu profesional de salud.', style: TextStyle(color: Colors.blue.shade800, fontSize: 12, height: 1.4)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DosisHoy {
  final dynamic medicamento;
  final String hora;
  final String estado; 
  final String? horaRegistro;

  DosisHoy({
    required this.medicamento,
    required this.hora,
    required this.estado,
    this.horaRegistro,
  });

  DosisHoy copyWith({String? estado}) {
    return DosisHoy(
      medicamento: medicamento,
      hora: hora,
      estado: estado ?? this.estado,
      horaRegistro: horaRegistro,
    );
  }
}

class _TimelineDosisItem extends StatelessWidget {
  final DosisHoy dosis;
  final VoidCallback onRecargar;

  const _TimelineDosisItem({required this.dosis, required this.onRecargar});

  @override
  Widget build(BuildContext context) {
    Color colorEstado;
    IconData iconoEstado;
    
    switch (dosis.estado) {
      case 'completada':
        colorEstado = const Color(0xFF10B981); 
        iconoEstado = Icons.check_circle;
        break;
      case 'proxima':
        colorEstado = const Color(0xFF3B82F6); 
        iconoEstado = Icons.access_time;
        break;
      default:
        colorEstado = const Color(0xFF94A3B8); 
        iconoEstado = Icons.circle_outlined;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(dosis.hora, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dosis.estado == 'completada' ? colorEstado : Colors.white,
                    border: Border.all(color: colorEstado, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dosis.estado == 'proxima' ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorEstado.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dosis.estado == 'completada' ? 'Completada' : (dosis.estado == 'proxima' ? 'Proxima toma' : 'Programada'),
                            style: TextStyle(color: colorEstado, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Icon(iconoEstado, color: colorEstado, size: 18),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(dosis.medicamento['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                    Text('${dosis.medicamento['dosis']} - Segun receta', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    
                    if (dosis.estado == 'completada' && dosis.horaRegistro != null) ...[
                      const SizedBox(height: 8),
                      Text('Registrada a las ${dosis.horaRegistro}', style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500)),
                    ],

                    if (dosis.estado == 'proxima') ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PantallaTomaMedicamento(
                                  medicamento: dosis.medicamento,
                                  horaProgramada: dosis.hora,
                                  fechaProgramada: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                                ),
                              ),
                            );
                            if (result == true) onRecargar();
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Revisar medicamento', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}