import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import 'pantalla_formulario_cita.dart';
import 'modelos/cita.dart';

class PantallaCitasPaciente extends StatefulWidget {
  const PantallaCitasPaciente({super.key});

  @override
  State<PantallaCitasPaciente> createState() => _EstadoPantallaCitasPaciente();
}

class _EstadoPantallaCitasPaciente extends State<PantallaCitasPaciente> {
  List<Cita> _citas = [];
  bool _cargando = true;
  
  late DateTime _mesActual;
  DateTime? _diaSeleccionado;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _mesActual = DateTime(ahora.year, ahora.month, 1);
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    final url = Uri.parse('http://localhost:8080/api/citas/paciente/${RepositorioApp.instancia.idPacienteActual}'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _citas = data.map((json) => Cita.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error al cargar citas: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirFormulario(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaFormularioCita()),
    );
    
    if (resultado == true) {
      _cargarCitas();
    }
  }

  DateTime? get _fechaProximaCita {
    final ahora = DateTime.now();
    final proximas = _citas.where((c) {
      final f = c.fechaHoraEfectiva;
      return (c.estaPendiente || c.estaConfirmada) && f.isAfter(ahora.subtract(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.fechaHoraEfectiva.compareTo(b.fechaHoraEfectiva));

    if (proximas.isNotEmpty) {
      return proximas.first.fechaHoraEfectiva;
    }
    return null;
  }

  List<Cita> get _citasFiltradas {
    if (_diaSeleccionado != null) {
      // Si el paciente toca un dia en el calendario, mostrar solo las de ese dia
      return _citas.where((c) {
        final f = c.fechaHoraEfectiva;
        return f.year == _diaSeleccionado!.year && f.month == _diaSeleccionado!.month && f.day == _diaSeleccionado!.day;
      }).toList()
      ..sort((a, b) => a.fechaHoraEfectiva.compareTo(b.fechaHoraEfectiva));
    } else {
      // Si NO hay dia seleccionado, mostrar UNICAMENTE la proxima cita
      final fechaProxima = _fechaProximaCita;
      if (fechaProxima == null) return [];
      
      return _citas.where((c) {
        final f = c.fechaHoraEfectiva;
        return f.year == fechaProxima.year && 
               f.month == fechaProxima.month && 
               f.day == fechaProxima.day &&
               (c.estaPendiente || c.estaConfirmada);
      }).toList()
      ..sort((a, b) => a.fechaHoraEfectiva.compareTo(b.fechaHoraEfectiva));
    }
  }

  String _nombreMes(int mes) {
    const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return meses[mes - 1];
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
              const Text('Organiza y consulta tus proximas citas.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () => _abrirFormulario(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Solicitar nueva cita', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // 2. CALENDARIO
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
              const SizedBox(height: 24),

              // 3. LISTA DE CITAS (Solo proxima cita o citas del dia)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _diaSeleccionado == null ? 'Tu próxima cita' : 'Citas del dia',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  if (_diaSeleccionado != null)
                    TextButton(
                      onPressed: () => setState(() => _diaSeleccionado = null),
                      child: const Text('Ver próxima cita', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9))),
                    )
                ],
              ),
              const SizedBox(height: 12),

              if (_citasFiltradas.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No hay citas proximas para mostrar', style: TextStyle(color: Colors.grey)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _citasFiltradas.length,
                  itemBuilder: (context, index) {
                    final cita = _citasFiltradas[index];
                    
                    // Si estamos en la vista general, esta SIEMPRE sera la proxima
                    final esLaProxima = _diaSeleccionado == null;

                    return _TarjetaCitaCalendario(cita: cita, esProxima: esLaProxima);
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCalendario() {
    final primerDiaMes = DateTime(_mesActual.year, _mesActual.month, 1);
    final diasEnMes = DateTime(_mesActual.year, _mesActual.month + 1, 0).day;
    final diaSemanaInicio = primerDiaMes.weekday - 1; 
    
    final hoy = DateTime.now();
    final fechaProxima = _fechaProximaCita;
    final colores = context.colors;

    // AQUI ESTA EL VERDE PARA LA PROXIMA CITA
    const colorProxima = Color(0xFF10B981); 

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: diasEnMes + diaSemanaInicio,
      itemBuilder: (context, index) {
        if (index < diaSemanaInicio) {
          return const SizedBox(); 
        }

        final diaNumero = index - diaSemanaInicio + 1;
        final fechaCelda = DateTime(_mesActual.year, _mesActual.month, diaNumero);
        
        final esHoy = fechaCelda.year == hoy.year && fechaCelda.month == hoy.month && fechaCelda.day == hoy.day;
        final seleccionado = _diaSeleccionado != null && 
            _diaSeleccionado!.year == fechaCelda.year && 
            _diaSeleccionado!.month == fechaCelda.month && 
            _diaSeleccionado!.day == fechaCelda.day;
            
        final esProxima = fechaProxima != null && 
            fechaCelda.year == fechaProxima.year && 
            fechaCelda.month == fechaProxima.month && 
            fechaCelda.day == fechaProxima.day;

        Color bgColor = Colors.transparent;
        Color textColor = const Color(0xFF0F172A);

        if (seleccionado) {
          bgColor = colores.primary; // Azul si el usuario lo selecciona
          textColor = Colors.white;
        } else if (esProxima) {
          bgColor = colorProxima; // VERDE para la proxima cita
          textColor = Colors.white;
        } else if (esHoy) {
          bgColor = colores.primary.withValues(alpha: 0.1); // Azul claro para hoy
          textColor = colores.primary;
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
              boxShadow: (esProxima && !seleccionado) ? [
                BoxShadow(color: colorProxima.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 3))
              ] : null,
            ),
            alignment: Alignment.center,
            child: Text(
              '$diaNumero',
              style: TextStyle(
                fontSize: 14,
                fontWeight: esHoy || seleccionado || esProxima ? FontWeight.bold : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= TARJETA DE CITA =================
class _TarjetaCitaCalendario extends StatelessWidget {
  final Cita cita;
  final bool esProxima;

  const _TarjetaCitaCalendario({required this.cita, this.esProxima = false});

  @override
  Widget build(BuildContext context) {
    final esPendiente = cita.estaPendiente;
    final esCancelada = cita.estaCancelada;
    
    // Azul para la proxima cita, naranja/rojo para otras
    const colorPrimario = Color(0xFF0EA5E9);
    
    Color colorEstado = colorPrimario; 
    if (!esProxima) {
      if (esPendiente) colorEstado = Colors.orange;
      else if (esCancelada) colorEstado = Colors.red;
    }
    
    final fecha = cita.fechaHoraEfectiva;
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'][fecha.month - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: esProxima ? colorPrimario : const Color(0xFFE2E8F0), 
          width: esProxima ? 2.5 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: esProxima ? colorPrimario.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02), 
            blurRadius: esProxima ? 15 : 8, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FRANJA AZUL DE "TU PROXIMA CITA"
          if (esProxima)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: colorPrimario, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('⭐', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'Tu próxima cita', 
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dia,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorEstado, height: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mes,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorEstado),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.1), 
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              esPendiente ? 'Pendiente' : (esCancelada ? 'Cancelada' : 'Confirmada'),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorEstado),
                            ),
                          ),
                          if (!esPendiente && !esCancelada)
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: colorEstado),
                                const SizedBox(width: 4),
                                Text(
                                  cita.horaFormateada,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colorEstado),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        cita.especialidad,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cita.motivo,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 6),
                          Text(
                            cita.nombreMedico ?? 'Medico por asignar',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF94A3B8)),
                          SizedBox(width: 6),
                          Text(
                            'Consultorio / Hospital',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}