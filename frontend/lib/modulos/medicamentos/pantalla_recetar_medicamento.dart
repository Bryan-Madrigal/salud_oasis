import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';

class PantallaRecetarMedicamento extends StatefulWidget {
  final String nombrePaciente;

  const PantallaRecetarMedicamento({
    super.key, 
    required this.nombrePaciente,
  });

  @override
  State<PantallaRecetarMedicamento> createState() =>
      _EstadoPantallaRecetarMedicamento();
}

class _EstadoPantallaRecetarMedicamento
    extends State<PantallaRecetarMedicamento> {
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _notasController = TextEditingController();

  String _viaAdministracion = 'Oral';
  String _frecuencia = 'Cada 24 horas';
  TimeOfDay _horaRecordatorio = const TimeOfDay(hour: 8, minute: 0);
  DateTime _fechaInicio = DateTime.now();
  DateTime? _fechaFin;
  bool _cargando = false;

  final _opcionesVia = ['Oral', 'Intravenosa', 'Subcutánea', 'Tópica', 'Inhalada'];
  final _opcionesFrecuencia = [
    'Cada 24 horas',
    'Cada 12 horas',
    'Cada 8 horas',
    'Cada 6 horas',
    'Una vez al día',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _dosisController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo medicamento'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.assignment_outlined, color: colores.primary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prescripción médica',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colores.textPrimary,
                          ),
                        ),
                        Text(
                          'Para: ${widget.nombrePaciente}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colores.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Nombre
              _construirEtiqueta('Nombre del medicamento'),
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(hintText: 'Ej. Losartán'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Dosis y Vía
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirEtiqueta('Dosis indicada'),
                        TextField(
                          controller: _dosisController,
                          decoration: const InputDecoration(hintText: 'Ej. 50 mg'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirEtiqueta('Vía de administración'),
                        DropdownButtonFormField<String>(
                          value: _viaAdministracion,
                          isExpanded: true,
                          decoration: const InputDecoration(),
                          icon: Icon(Icons.keyboard_arrow_down, color: colores.textSecondary),
                          items: _opcionesVia.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (valor) => setState(() => _viaAdministracion = valor!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Frecuencia
              _construirEtiqueta('Frecuencia prescrita'),
              DropdownButtonFormField<String>(
                value: _frecuencia,
                isExpanded: true,
                decoration: const InputDecoration(),
                icon: Icon(Icons.keyboard_arrow_down, color: colores.textSecondary),
                items: _opcionesFrecuencia.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (valor) => setState(() => _frecuencia = valor!),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'La frecuencia definitiva debe corresponder a la receta médica.',
                style: TextStyle(fontSize: 11, color: colores.textTertiary),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Hora recordatorio
              _construirEtiqueta('Hora del recordatorio'),
              InkWell(
                onTap: _seleccionarHora,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 16),
                  decoration: BoxDecoration(
                    color: colores.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colores.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: colores.primary, size: 20),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _horaRecordatorio.format(context),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colores.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirEtiqueta('Inicio del tratamiento'),
                        _construirSelectorFecha(
                          fecha: _fechaInicio,
                          alPresionar: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaInicio,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (fecha != null) setState(() => _fechaInicio = fecha);
                          },
                          alLimpiar: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construirEtiqueta('Fin del tratamiento (opcional)'),
                        _construirSelectorFecha(
                          fecha: _fechaFin,
                          pista: 'Seleccionar fecha',
                          alPresionar: () async {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: _fechaFin ?? _fechaInicio.add(const Duration(days: 30)),
                              firstDate: _fechaInicio,
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (fecha != null) setState(() => _fechaFin = fecha);
                          },
                          alLimpiar: _fechaFin != null ? () => setState(() => _fechaFin = null) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Indicaciones
              _construirEtiqueta('Indicaciones adicionales'),
              TextField(
                controller: _notasController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Instrucciones que aparecen en la receta...',
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Guardar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar prescripción'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEtiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }

  Widget _construirSelectorFecha({
    required DateTime? fecha,
    required VoidCallback alPresionar,
    VoidCallback? alLimpiar,
    String pista = 'Seleccionar',
  }) {
    final colores = context.colors;
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
        decoration: BoxDecoration(
          color: colores.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colores.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: colores.primary, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                fecha != null
                    ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year.toString().substring(2)}'
                    : pista,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: fecha != null ? FontWeight.w600 : FontWeight.normal,
                  color: fecha != null ? colores.textPrimary : colores.textTertiary,
                ),
              ),
            ),
            if (alLimpiar != null)
              GestureDetector(
                onTap: alLimpiar,
                child: Icon(Icons.close, size: 16, color: colores.textSecondary),
              )
            else
              Icon(Icons.keyboard_arrow_down, size: 18, color: colores.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(context: context, initialTime: _horaRecordatorio);
    if (hora != null) setState(() => _horaRecordatorio = hora);
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    final dosis = _dosisController.text.trim();

    if (nombre.isEmpty || dosis.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el nombre y la dosis')),
      );
      return;
    }

    setState(() => _cargando = true);

    // Formatear fecha (AAAA-MM-DD)
    final fechaInicioStr = "${_fechaInicio.year}-${_fechaInicio.month.toString().padLeft(2, '0')}-${_fechaInicio.day.toString().padLeft(2, '0')}";
    
    // Si no hay fecha fin, le damos 90 días por defecto
    final fechaFinCalculada = _fechaFin ?? _fechaInicio.add(const Duration(days: 90));
    final fechaFinStr = "${fechaFinCalculada.year}-${fechaFinCalculada.month.toString().padLeft(2, '0')}-${fechaFinCalculada.day.toString().padLeft(2, '0')}";

    final horaString = '${_horaRecordatorio.hour.toString().padLeft(2, '0')}:${_horaRecordatorio.minute.toString().padLeft(2, '0')}';

    final url = Uri.parse('http://localhost:8080/api/medicamentos');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": 1, // ⚠️ En un futuro, esto vendrá del paciente seleccionado
          "nombre": nombre,
          "dosis": dosis,
          "frecuencia": _frecuencia,
          "fechaInicio": fechaInicioStr,
          "fechaFin": fechaFinStr,
          "notas": _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
          "horaRecordatorio": horaString
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento recetado correctamente')),
        );
      } else {
        throw Exception('Error del servidor');
      }
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión con el servidor')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
}