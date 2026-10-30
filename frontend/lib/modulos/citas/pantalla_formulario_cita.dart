import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import 'modelos/medico.dart'; 

class PantallaFormularioCita extends StatefulWidget {
  const PantallaFormularioCita({super.key});

  @override
  State<PantallaFormularioCita> createState() => _EstadoPantallaFormularioCita();
}

class _EstadoPantallaFormularioCita extends State<PantallaFormularioCita> {
  Especialidad? _especialidad;
  int? _medicoIdSeleccionado;
  // _medicoNombreSeleccionado ELIMINADO (no se usaba)
  DateTime? _fechaSeleccionada;
  String? _horaSeleccionada; 
  String _tipo = 'Consulta de seguimiento';
  bool _enviando = false;

  List<dynamic> _medicosReales = [];
  bool _cargandoMedicos = true;

  static const _tipos = [
    'Consulta de seguimiento',
    'Consulta general',
    'Urgencia',
    'Revision de resultados',
  ];

  final List<String> _horariosDisponibles = [
    '08:00', '09:00', '10:00', '11:00', '12:00', 
    '15:00', '16:00', '17:00', '18:00', '19:00'
  ];

  @override
  void initState() {
    super.initState();
    _cargarMedicos();
  }

  Future<void> _cargarMedicos() async {
    final url = Uri.parse('http://localhost:8080/api/medicos');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _medicosReales = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error al cargar medicos: $e");
    } finally {
      if (mounted) setState(() => _cargandoMedicos = false);
    }
  }

  bool get _estaCompleto =>
      _especialidad != null &&
      _medicoIdSeleccionado != null &&
      _fechaSeleccionada != null &&
      _horaSeleccionada != null;

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar cita'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agenda tu consulta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colores.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Elige especialidad, medico, fecha y horario',
                style: TextStyle(color: colores.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ===== Paso 1: Especialidad =====
              _EncabezadoPaso(numero: 1, titulo: 'Especialidad'),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: RepositorioApp.especialidades.map((esp) {
                  final seleccionada = _especialidad?.id == esp.id;
                  return _ChipEspecialidad(
                    especialidad: esp,
                    seleccionada: seleccionada,
                    alPresionar: () {
                      setState(() {
                        _especialidad = esp;
                        _medicoIdSeleccionado = null;
                        _horaSeleccionada = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ===== Paso 2: Medico =====
              if (_especialidad != null) ...[
                _EncabezadoPaso(numero: 2, titulo: 'Medico'),
                const SizedBox(height: AppSpacing.md),
                ..._construirListaMedicos(context),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ===== Paso 3: Fecha =====
              if (_medicoIdSeleccionado != null) ...[
                _EncabezadoPaso(numero: 3, titulo: 'Fecha de la cita'),
                const SizedBox(height: AppSpacing.md),
                _construirTiraCalendario(context),
                const SizedBox(height: AppSpacing.xl),

                // ===== Paso 4: Horarios Especificos =====
                _EncabezadoPaso(numero: 4, titulo: 'Horario disponible'),
                const SizedBox(height: AppSpacing.sm),
                Text('Horarios de atencion del medico', style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _horariosDisponibles.map((hora) {
                    final seleccionado = _horaSeleccionada == hora;
                    return GestureDetector(
                      onTap: () => setState(() => _horaSeleccionada = hora),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: seleccionado ? colores.primary : colores.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: seleccionado ? colores.primary : colores.border),
                          boxShadow: seleccionado ? [] : colores.shadowSoft,
                        ),
                        child: Text(
                          hora,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: seleccionado ? Colors.white : colores.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ===== Paso 5: Detalles de la consulta =====
                _EncabezadoPaso(numero: 5, titulo: 'Tipo de consulta'),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  value: _tipo,
                  isExpanded: true,
                  decoration: const InputDecoration(),
                  icon: Icon(Icons.keyboard_arrow_down, color: colores.textSecondary),
                  items: _tipos.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // ===== Boton =====
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: (_estaCompleto && !_enviando) ? _guardar : null,
                  icon: _enviando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_outlined),
                  label: Text(_enviando ? 'Solicitando...' : 'Solicitar cita'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Lista de medicos (DESDE LA BASE DE DATOS) =====
  List<Widget> _construirListaMedicos(BuildContext context) {
    final colores = context.colors;

    if (_cargandoMedicos) {
      return [const Center(child: CircularProgressIndicator())];
    }

    final lista = _medicosReales.where((m) {
      final especialidadMedico = (m['especialidad'] ?? '').toString().toLowerCase();
      return especialidadMedico == _especialidad!.nombre.toLowerCase();
    }).toList();

    if (lista.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
          child: Text('No hay medicos registrados en la base de datos para esta especialidad', style: TextStyle(color: colores.textSecondary)),
        ),
      ];
    }

    return lista.map((medicoData) {
      final int medicoId = medicoData['id'];
      final String nombre = medicoData['usuario'] != null ? medicoData['usuario']['nombre'] : 'Medico';
      final String especialidad = medicoData['especialidad'] ?? 'Medicina general';
      final String consultorio = medicoData['consultorio'] ?? 'Consultorio 1';
      
      final seleccionado = _medicoIdSeleccionado == medicoId;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Material(
          color: seleccionado ? colores.primarySoft : colores.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: () => setState(() {
              _medicoIdSeleccionado = medicoId;
              _horaSeleccionada = null;
            }),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: seleccionado ? colores.primary : Colors.transparent, width: 1.5),
                boxShadow: seleccionado ? [] : colores.shadowSoft,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: seleccionado ? AppGradients.ocean : null,
                      color: seleccionado ? null : colores.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(nombre.substring(0, 1), style: TextStyle(color: seleccionado ? Colors.white : colores.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: TextStyle(fontWeight: FontWeight.w700, color: colores.textPrimary, fontSize: 15)),
                        const SizedBox(height: 2),
                        Text(especialidad, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 12, color: colores.textTertiary),
                            const SizedBox(width: 2),
                            Text(consultorio, style: TextStyle(fontSize: 11, color: colores.textTertiary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (seleccionado) Icon(Icons.check_circle, color: colores.primary, size: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ===== Calendar strip =====
  Widget _construirTiraCalendario(BuildContext context) {
    final colores = context.colors;
    final ahora = DateTime.now();
    final dias = List.generate(14, (i) => ahora.add(Duration(days: i)));

    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dias.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final dia = dias[i];
          final seleccionado = _fechaSeleccionada != null && _fechaSeleccionada!.year == dia.year && _fechaSeleccionada!.month == dia.month && _fechaSeleccionada!.day == dia.day;
          final esHoy = i == 0;

          return GestureDetector(
            onTap: () => setState(() {
              _fechaSeleccionada = dia;
              _horaSeleccionada = null;
            }),
            child: Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: seleccionado ? AppGradients.ocean : null,
                color: seleccionado ? null : colores.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: seleccionado ? [] : colores.shadowSoft,
                border: Border.all(color: seleccionado ? colores.primary : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_abreviaturaDia(dia.weekday).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: seleccionado ? Colors.white.withValues(alpha: 0.85) : colores.textTertiary, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text('${dia.day}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: seleccionado ? Colors.white : colores.textPrimary, letterSpacing: -0.5, height: 1)),
                  const SizedBox(height: 4),
                  Text(esHoy ? 'HOY' : _abreviaturaMes(dia.month), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: seleccionado ? Colors.white.withValues(alpha: 0.85) : colores.textTertiary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _abreviaturaDia(int dia) {
    const dias = ['lun', 'mar', 'mie', 'jue', 'vie', 'sab', 'dom'];
    return dias[dia - 1];
  }

  String _abreviaturaMes(int mes) {
    const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return meses[mes - 1];
  }

  // ===== GUARDAR EN EL BACKEND =====
  Future<void> _guardar() async {
    if (!_estaCompleto) return;

    setState(() => _enviando = true);

    final fechaStr = "${_fechaSeleccionada!.year.toString().padLeft(4, '0')}-"
                     "${_fechaSeleccionada!.month.toString().padLeft(2, '0')}-"
                     "${_fechaSeleccionada!.day.toString().padLeft(2, '0')}";

    final url = Uri.parse('http://localhost:8080/api/citas');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": RepositorioApp.instancia.idPacienteActual,
          "medicoId": _medicoIdSeleccionado, 
          "especialidad": _especialidad!.nombre,
          "tipo": _tipo,
          "motivo": _tipo, 
          "fechaPreferida": fechaStr,
          "horarioPreferido": _horaSeleccionada,
          "notasPaciente": null,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita solicitada con exito')));
        Navigator.pop(context, true);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error al solicitar cita: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexion con el servidor')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }
}

// ===== Widgets auxiliares =====

class _EncabezadoPaso extends StatelessWidget {
  final int numero;
  final String titulo;

  const _EncabezadoPaso({required this.numero, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(color: colores.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text('$numero', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colores.textPrimary, letterSpacing: -0.2)),
      ],
    );
  }
}

class _ChipEspecialidad extends StatelessWidget {
  final Especialidad especialidad;
  final bool seleccionada;
  final VoidCallback alPresionar;

  const _ChipEspecialidad({required this.especialidad, required this.seleccionada, required this.alPresionar});

  IconData get _icono {
    switch (especialidad.nombreIcono) {
      case 'cardio': return Icons.favorite_border;
      case 'endo': return Icons.water_drop_outlined;
      case 'nefro': return Icons.water_outlined;
      case 'neumo': return Icons.air_outlined;
      default: return Icons.medical_services_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: seleccionada ? AppGradients.ocean : null,
          color: seleccionada ? null : colores.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: seleccionada ? [] : colores.shadowSoft,
          border: Border.all(color: seleccionada ? colores.primary : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icono, size: 16, color: seleccionada ? Colors.white : colores.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(especialidad.nombre, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: seleccionada ? Colors.white : colores.textPrimary)),
          ],
        ),
      ),
    );
  }
}