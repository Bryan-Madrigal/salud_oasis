import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
// import 'modelos/cita.dart'; // <-- Descomenta si decides usar el modelo Cita

class PantallaCitasMedico extends StatefulWidget {
  const PantallaCitasMedico({super.key});

  @override
  State<PantallaCitasMedico> createState() => _EstadoPantallaCitasMedico();
}

class _EstadoPantallaCitasMedico extends State<PantallaCitasMedico> {
  List<dynamic> _citas = [];
  bool _cargando = true;
  
  late DateTime _mesActual;
  DateTime? _diaSeleccionado;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mesActual = DateTime(ahora.year, ahora.month, 1);
    _diaSeleccionado = ahora; // Por defecto seleccionamos hoy
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    final idMedico = RepositorioApp.instancia.idMedicoActual;
    final url = Uri.parse('http://localhost:8080/api/citas/medico/$idMedico');

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        _citas = jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Error cargando citas del medico: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _confirmarCita(dynamic cita) async {
    // Aquí va tu lógica real para confirmar en el backend
    // Ejemplo: http.put(Uri.parse('http://localhost:8080/api/citas/${cita['id']}/confirmar'));
    
    setState(() {
      cita['estado'] = 'confirmada';
      // Si no tiene fecha confirmada, le asignamos la fecha solicitada para que aparezca en el calendario
      if (cita['fechaHoraConfirmada'] == null) {
        cita['fechaHoraConfirmada'] = cita['fechaHoraSolicitada'];
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita confirmada exitosamente')));
  }

  String _nombreMes(int mes) {
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return meses[mes - 1];
  }

  // Obtener las citas confirmadas del día seleccionado
  List<dynamic> get _citasDelDia {
    if (_diaSeleccionado == null) return [];
    
    return _citas.where((c) {
      if (c['estado'] != 'confirmada' || c['fechaHoraConfirmada'] == null) return false;
      final f = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
      return f.year == _diaSeleccionado!.year && 
             f.month == _diaSeleccionado!.month && 
             f.day == _diaSeleccionado!.day;
    }).toList()
      ..sort((a, b) => DateTime.parse(a['fechaHoraConfirmada']).compareTo(DateTime.parse(b['fechaHoraConfirmada'])));
  }

  // Obtener las solicitudes pendientes
  List<dynamic> get _solicitudesPendientes {
    return _citas.where((c) => c['estado'] == 'pendiente').toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ENCABEZADO
              const Text('Mi calendario medico', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text('Revisa tus proximas citas y solicitudes.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 24),

              // 2. CALENDARIO (Copiado del paciente)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month - 1, 1)),
                        ),
                        Text(
                          '${_nombreMes(_mesActual.month)} ${_mesActual.year}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () => setState(() => _mesActual = DateTime(_mesActual.year, _mesActual.month + 1, 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) {
                        return SizedBox(
                          width: 36,
                          child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    _construirCalendario(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. SOLICITUDES PENDIENTES
              if (_solicitudesPendientes.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Solicitudes pendientes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                      child: Text('${_solicitudesPendientes.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                ..._solicitudesPendientes.map((cita) => _TarjetaSolicitudPendiente(cita: cita, alConfirmar: () => _confirmarCita(cita))),
                const SizedBox(height: 32),
              ],

                            // 4. CITAS DEL DÍA SELECCIONADO
              Builder(
                builder: (context) {
                  // Verificamos si el día seleccionado es HOY
                  final hoy = DateTime.now();
                  final esHoy = _diaSeleccionado != null &&
                      _diaSeleccionado!.year == hoy.year &&
                      _diaSeleccionado!.month == hoy.month &&
                      _diaSeleccionado!.day == hoy.day;

                  String titulo;
                  if (_diaSeleccionado == null) {
                    titulo = 'Selecciona un día';
                  } else if (esHoy) {
                    titulo = 'Tus citas de hoy';
                  } else {
                    titulo = 'Citas del ${_diaSeleccionado!.day} de ${_nombreMes(_diaSeleccionado!.month)}';
                  }

                  return Text(
                    titulo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  );
                },
              ),
              const SizedBox(height: 12),

              if (_citasDelDia.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Center(
                    child: Text('No hay citas confirmadas para este día.', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ..._citasDelDia.map((cita) => _TarjetaCitaConfirmada(cita: cita)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // LÓGICA DEL CALENDARIO (Adaptada del paciente)
  Widget _construirCalendario() {
    final primerDiaMes = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final diaSemanaInicio = primerDiaMes.weekday - 1; 
    
    final hoy = DateTime.now();
    const colorProxima = Color(0xFF10B981); // Verde para días con citas

    // Verificar qué días tienen al menos una cita confirmada
    bool diaTieneCitas(DateTime fecha) {
      return _citas.any((c) {
        if (c['estado'] != 'confirmada' || c['fechaHoraConfirmada'] == null) return false;
        final f = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
        return f.year == fecha.year && f.month == fecha.month && f.day == fecha.day;
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: diasEnMes + diaSemanaInicio,
      itemBuilder: (context, index) {
        if (index < diaSemanaInicio) return const SizedBox(); 

        final diaNumero = index - diaSemanaInicio + 1;
        final fechaCelda = DateTime(_mesActual.year, _mesActual.month, diaNumero);
        
        final esHoy = fechaCelda.year == hoy.year && fechaCelda.month == hoy.month && fechaCelda.day == hoy.day;
        final seleccionado = _diaSeleccionado != null && 
            _diaSeleccionado!.year == fechaCelda.year && 
            _diaSeleccionado!.month == fechaCelda.month && 
            _diaSeleccionado!.day == fechaCelda.day;
            
        final tieneCitas = diaTieneCitas(fechaCelda);

        Color bgColor = Colors.transparent;
        Color textColor = const Color(0xFF0F172A);

        if (seleccionado) {
          bgColor = const Color(0xFF0EA5E9); // Azul si está seleccionado
          textColor = Colors.white;
        } else if (tieneCitas) {
          bgColor = colorProxima; // Verde si tiene citas confirmadas
          textColor = Colors.white;
        } else if (esHoy) {
          bgColor = const Color(0xFF0EA5E9).withValues(alpha: 0.1); // Azul claro para hoy
          textColor = const Color(0xFF0EA5E9);
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _diaSeleccionado = seleccionado ? null : fechaCelda;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: (tieneCitas && !seleccionado) ? [
                BoxShadow(color: colorProxima.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))
              ] : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$diaNumero',
              style: TextStyle(
                fontSize: 14,
                fontWeight: esHoy || seleccionado || tieneCitas ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// WIDGETS AUXILIARES (TARJETAS)
// ==========================================

class _TarjetaSolicitudPendiente extends StatelessWidget {
  final dynamic cita;
  final VoidCallback alConfirmar;

  const _TarjetaSolicitudPendiente({required this.cita, required this.alConfirmar});

  @override
  Widget build(BuildContext context) {
    final nombre = cita['paciente']?['usuario']?['nombre'] ?? 'Paciente';
    final inicial = nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'P';
    
    String fechaStr = 'Por definir';
    if (cita['fechaHoraSolicitada'] != null) {
      final f = DateTime.parse(cita['fechaHoraSolicitada']).toLocal();
      fechaStr = '${f.day}/${f.month}/${f.year} - ${f.hour}:${f.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D)), // Borde amarillo suave
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text(cita['motivo'] ?? 'Consulta general', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                child: const Text('Pendiente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
              )
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(fechaStr, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {}, // Aquí puedes ir al expediente
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Ver expediente'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: alConfirmar,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Confirmar'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _TarjetaCitaConfirmada extends StatelessWidget {
  final dynamic cita;
  const _TarjetaCitaConfirmada({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.parse(cita['fechaHoraConfirmada']).toLocal();
    final horaStr = '${fecha.hour > 12 ? fecha.hour - 12 : (fecha.hour == 0 ? 12 : fecha.hour)}:${fecha.minute.toString().padLeft(2, '0')} ${fecha.hour >= 12 ? 'PM' : 'AM'}';
    final nombre = cita['paciente']?['usuario']?['nombre'] ?? 'Paciente';
    final inicial = nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'P';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Text(inicial, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                Text(cita['motivo'] ?? 'Consulta general', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
            child: Text(horaStr, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}