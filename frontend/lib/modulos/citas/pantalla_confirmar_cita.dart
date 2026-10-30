import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import 'modelos/cita.dart';

class PantallaConfirmarCita extends StatefulWidget {
  final Cita cita;

  const PantallaConfirmarCita({
    super.key,
    required this.cita,
  });

  @override
  State<PantallaConfirmarCita> createState() => _EstadoPantallaConfirmarCita();
}

class _EstadoPantallaConfirmarCita extends State<PantallaConfirmarCita> {
  final _notasMedicoController = TextEditingController();

  late DateTime _fecha;
  late TimeOfDay _hora;
  int _duracionMinutos = 30;
  bool _cargando = false;

  static const _duraciones = [15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _fecha = widget.cita.fechaPreferida;
    switch (widget.cita.horarioPreferido) {
      case HorarioPreferido.manana:
        _hora = const TimeOfDay(hour: 10, minute: 0);
        break;
      case HorarioPreferido.tarde:
        _hora = const TimeOfDay(hour: 16, minute: 0);
        break;
      case HorarioPreferido.cualquiera:
        _hora = const TimeOfDay(hour: 10, minute: 0);
        break;
    }
  }

  @override
  void dispose() {
    _notasMedicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final cita = widget.cita;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar cita')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(color: colores.primarySoft, borderRadius: BorderRadius.circular(AppRadius.lg)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: colores.primary.withValues(alpha: 0.2),
                          child: Text(
                            cita.nombrePaciente.isNotEmpty ? cita.nombrePaciente.substring(0, 1) : '?',
                            style: TextStyle(color: colores.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cita.nombrePaciente, style: TextStyle(fontWeight: FontWeight.bold, color: colores.textPrimary, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(cita.tipo, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Motivo: ${cita.motivo}', style: TextStyle(color: colores.textPrimary, fontSize: 13)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Preferencia: ${cita.fechaPreferidaFormateada} · ${cita.horarioPreferido.etiqueta}', style: TextStyle(color: colores.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Fecha y hora', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _campoSelector(
                      context,
                      icono: Icons.calendar_today_outlined,
                      etiqueta: 'Fecha',
                      valor: '${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
                      alPresionar: _seleccionarFecha,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _campoSelector(
                      context,
                      icono: Icons.access_time_outlined,
                      etiqueta: 'Hora',
                      valor: '${_hora.hour.toString().padLeft(2, '0')}:${_hora.minute.toString().padLeft(2, '0')}',
                      alPresionar: _seleccionarHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Duración', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: _duraciones.map((duracion) {
                  final seleccionado = _duracionMinutos == duracion;
                  return ChoiceChip(
                    selected: seleccionado,
                    onSelected: (_) => setState(() => _duracionMinutos = duracion),
                    label: Text('$duracion min'),
                    labelStyle: TextStyle(color: seleccionado ? Colors.white : colores.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                    selectedColor: colores.primary,
                    backgroundColor: colores.surface,
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text('Notas para el paciente (opcional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notasMedicoController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Ej. Traer resultados de laboratorio'),
              ),
              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _confirmarCita,
                  icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(_cargando ? 'Confirmando...' : 'Confirmar cita'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoSelector(BuildContext context, {required IconData icono, required String etiqueta, required String valor, required VoidCallback alPresionar}) {
    final colores = context.colors;
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: colores.surfaceAlt, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            Icon(icono, color: colores.primary, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etiqueta, style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                  const SizedBox(height: 2),
                  Text(valor, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (seleccionada != null) setState(() => _fecha = seleccionada);
  }

  Future<void> _seleccionarHora() async {
    final seleccionada = await showTimePicker(context: context, initialTime: _hora);
    if (seleccionada != null) setState(() => _hora = seleccionada);
  }

  Future<void> _confirmarCita() async {
    setState(() => _cargando = true);
    
    final fechaHora = DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);
    final fechaHoraString = fechaHora.toUtc().toIso8601String();
    
    // Recuerda cambiar localhost por 10.0.2.2 si usas Android
    final url = Uri.parse('http://localhost:8080/api/citas/${widget.cita.id}/confirmar');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fechaHora": fechaHoraString,
          "duracion": _duracionMinutos,
          "notas": _notasMedicoController.text.trim().isEmpty ? null : _notasMedicoController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // Envía 'true' a la pantalla anterior para recargar
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita confirmada exitosamente')));
      } else {
        throw Exception('Error del servidor');
      }
    } catch (e) {
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al conectar con el servidor')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
}