import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PantallaTomaMedicamento extends StatefulWidget {
  final dynamic medicamento;
  final String horaProgramada;
  final String fechaProgramada;

  const PantallaTomaMedicamento({
    super.key,
    required this.medicamento,
    required this.horaProgramada,
    required this.fechaProgramada,
  });

  @override
  State<PantallaTomaMedicamento> createState() => _EstadoPantallaTomaMedicamento();
}

class _EstadoPantallaTomaMedicamento extends State<PantallaTomaMedicamento> {
  int _pasoActual = 1; 
  bool _cargando = false;

  String _estadoSeleccionado = 'tomada'; 
  String? _motivoOmision;
  String _estadoAnimo = ''; 
  final _controladorObservaciones = TextEditingController();

  static const _motivos = [
    'Se me olvido',
    'No tenia el medicamento',
    'Me senti mal',
    'El medico me dijo que lo suspendiera',
    'Otro motivo'
  ];

  @override
  void dispose() {
    _controladorObservaciones.dispose();
    super.dispose();
  }

  void _siguientePaso() {
    if (_pasoActual < 4) {
      setState(() => _pasoActual++);
    }
  }

  void _regresarPaso() {
    if (_pasoActual > 1) {
      setState(() => _pasoActual--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _guardarRegistro() async {
    setState(() => _cargando = true);

    final url = Uri.parse('http://localhost:8080/api/medicamentos/${widget.medicamento['id']}/tomar');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fecha": widget.fechaProgramada,
          "hora": widget.horaProgramada,
          "estado": _estadoSeleccionado,
          "motivoOmision": _motivoOmision,
          "observaciones": _estadoAnimo.isNotEmpty || _controladorObservaciones.text.isNotEmpty 
              ? 'Animo: $_estadoAnimo - ${_controladorObservaciones.text}' 
              : null,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); 
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorFondo = Color(0xFFF8FAFC);
    const colorPrimario = Color(0xFF0EA5E9);
    const colorTextoOscuro = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorTextoOscuro),
          onPressed: _regresarPaso,
        ),
        title: const Text('Mi toma de medicamento', style: TextStyle(color: colorTextoOscuro, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paso $_pasoActual de 4', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _pasoActual / 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(colorPrimario),
                borderRadius: BorderRadius.circular(10),
                minHeight: 8,
              ),
              const SizedBox(height: 32),

              // AQUI ESTA LA MAGIA: Envolvemos el contenido en un Scroll para que no desborde
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _construirPasoActual(colorPrimario, colorTextoOscuro),
                  ),
                ),
              ),

              // Botonera inferior
              if (_pasoActual == 1 || _pasoActual == 2)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _siguientePaso,
                    style: FilledButton.styleFrom(backgroundColor: colorPrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (_pasoActual == 3)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _siguientePaso,
                    style: FilledButton.styleFrom(backgroundColor: colorPrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Confirmar registro', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (_pasoActual == 4)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _cargando ? null : _guardarRegistro,
                    style: FilledButton.styleFrom(backgroundColor: colorPrimario, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: _cargando 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Finalizar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirPasoActual(Color colorPrimario, Color colorTextoOscuro) {
    switch (_pasoActual) {
      case 1: return _Paso1Revisar(medicamento: widget.medicamento, hora: widget.horaProgramada);
      case 2: return _Paso2Preparar(medicamento: widget.medicamento);
      case 3: return _Paso3Confirmar(
        estado: _estadoSeleccionado,
        onCambiarEstado: (val) => setState(() => _estadoSeleccionado = val),
        motivo: _motivoOmision,
        onCambiarMotivo: (val) => setState(() => _motivoOmision = val),
        motivos: _motivos,
      );
      case 4: return _Paso4Finalizar(
        medicamento: widget.medicamento,
        hora: widget.horaProgramada,
        estadoAnimo: _estadoAnimo,
        onCambiarAnimo: (val) => setState(() => _estadoAnimo = val),
        observacionesCtrl: _controladorObservaciones,
      );
      default: return const SizedBox();
    }
  }
}

class _Paso1Revisar extends StatelessWidget {
  final dynamic medicamento;
  final String hora;
  const _Paso1Revisar({required this.medicamento, required this.hora});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Es hora de tu medicamento', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Revisa los datos de tu tratamiento antes de continuar.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(medicamento['nombre'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                    child: Text('Pendiente', style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.medication, color: Color(0xFF0EA5E9)),
                  const SizedBox(width: 8),
                  Text(medicamento['dosis'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),
              _infoFila('Horario', hora),
              const Divider(height: 32),
              _infoFila('Via', 'Oral (Segun receta)'),
            ],
          ),
        )
      ],
    );
  }

  Widget _infoFila(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Paso2Preparar extends StatelessWidget {
  final dynamic medicamento;
  const _Paso2Preparar({required this.medicamento});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prepara tu toma', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Sigue las indicaciones medicas.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue, size: 40),
              const SizedBox(height: 16),
              Text(medicamento['notas'] ?? 'Tomar con un vaso de agua. No suspender sin consultar al medico.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
            ],
          ),
        )
      ],
    );
  }
}

class _Paso3Confirmar extends StatelessWidget {
  final String estado;
  final Function(String) onCambiarEstado;
  final String? motivo;
  final Function(String) onCambiarMotivo;
  final List<String> motivos;

  const _Paso3Confirmar({
    required this.estado,
    required this.onCambiarEstado,
    required this.motivo,
    required this.onCambiarMotivo,
    required this.motivos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Que ocurrio con tu medicamento?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _opcion('Si, ya lo tome', 'Registrar la toma y guardar la hora', 'tomada', Icons.check_circle, Colors.green),
        _opcion('Todavia no lo he tomado', 'Mantener el registro pendiente', 'pendiente', Icons.access_time, Colors.orange),
        _opcion('No pude tomarlo', 'Registrar la situacion y el motivo', 'omitida', Icons.cancel, Colors.red),
        
        if (estado == 'omitida') ...[
          const SizedBox(height: 24),
          const Text('Selecciona el motivo:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: motivo,
            isExpanded: true,
            decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            items: motivos.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => onCambiarMotivo(v!),
          )
        ]
      ],
    );
  }

  Widget _opcion(String titulo, String subtitulo, String valor, IconData icono, Color color) {
    final seleccionado = estado == valor;
    return GestureDetector(
      onTap: () => onCambiarEstado(valor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: seleccionado ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: seleccionado ? color : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icono, color: seleccionado ? color : Colors.grey, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: seleccionado ? color : Colors.black)),
                  Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Paso4Finalizar extends StatelessWidget {
  final dynamic medicamento;
  final String hora;
  final String estadoAnimo;
  final Function(String) onCambiarAnimo;
  final TextEditingController observacionesCtrl;

  const _Paso4Finalizar({
    required this.medicamento,
    required this.hora,
    required this.estadoAnimo,
    required this.onCambiarAnimo,
    required this.observacionesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registro completado', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(medicamento['nombre'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${medicamento['dosis']} - Programado a las $hora', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text('Como te sientes? (Opcional)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _botonAnimo('Bien', '😊'),
            _botonAnimo('Regular', '😐'),
            _botonAnimo('Mal', '😔'),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: observacionesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Alguna molestia o nota adicional...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 20), // Espacio extra al final
      ],
    );
  }

  Widget _botonAnimo(String etiqueta, String emoji) {
    final seleccionado = estadoAnimo == etiqueta;
    return GestureDetector(
      onTap: () => onCambiarAnimo(etiqueta),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue.shade50 : Colors.white,
          border: Border.all(color: seleccionado ? Colors.blue : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(etiqueta, style: TextStyle(fontWeight: FontWeight.bold, color: seleccionado ? Colors.blue : Colors.black)),
          ],
        ),
      ),
    );
  }
}