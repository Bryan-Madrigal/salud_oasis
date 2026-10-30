import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';

class PantallaFormularioReceta extends StatefulWidget {
  final int? pacienteId;
  final String? nombrePacienteInicial;

  const PantallaFormularioReceta({
    super.key, 
    this.pacienteId, 
    this.nombrePacienteInicial
  });

  @override
  State<PantallaFormularioReceta> createState() => _EstadoPantallaFormularioReceta();
}

class _EstadoPantallaFormularioReceta extends State<PantallaFormularioReceta> {
  final _controladorPaciente = TextEditingController();
  final _controladorNotas = TextEditingController();
  final List<_ControladoresMedicamento> _medicamentos = [_ControladoresMedicamento()];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    if (widget.nombrePacienteInicial != null) {
      _controladorPaciente.text = widget.nombrePacienteInicial!;
    }
  }

  @override
  void dispose() {
    _controladorPaciente.dispose();
    _controladorNotas.dispose();
    for (final item in _medicamentos) {
      item.dispose();
    }
    super.dispose();
  }

  void _agregarMedicamento() {
    setState(() => _medicamentos.add(_ControladoresMedicamento()));
  }

  void _eliminarMedicamento(int indice) {
    if (_medicamentos.length <= 1) return;
    setState(() {
      _medicamentos[indice].dispose();
      _medicamentos.removeAt(indice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final pacienteBloqueado = widget.nombrePacienteInicial != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva receta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              if (pacienteBloqueado)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: colores.primarySoft, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: colores.primary),
                      const SizedBox(width: AppSpacing.md),
                      Text(widget.nombrePacienteInicial!, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                    ],
                  ),
                )
              else
                TextField(
                  controller: _controladorPaciente,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nombre del paciente', hintText: 'Ej. Juan Perez', prefixIcon: Icon(Icons.person_outline)),
                ),
              const SizedBox(height: AppSpacing.xl),

              Row(
                children: [
                  Expanded(child: Text('Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary))),
                  TextButton.icon(onPressed: _agregarMedicamento, icon: const Icon(Icons.add, size: 18), label: const Text('Agregar')),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              for (int i = 0; i < _medicamentos.length; i++) ...[
                _FormularioMedicamento(
                  indice: i,
                  controladores: _medicamentos[i],
                  alEliminar: _medicamentos.length > 1 ? () => _eliminarMedicamento(i) : null,
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              const SizedBox(height: AppSpacing.sm),
              Text('Indicaciones (opcional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              TextField(controller: _controladorNotas, maxLines: 3, decoration: const InputDecoration(hintText: 'Ej. Tomar con alimentos...')),
              const SizedBox(height: AppSpacing.xxl),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar receta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (widget.pacienteId == null) {
      _mostrarError('Error: No se selecciono un paciente valido');
      return;
    }

    final List<Map<String, String>> detallesJson = [];
    for (final c in _medicamentos) {
      final nombre = c.nombre.text.trim();
      final dosis = c.dosis.text.trim();
      final frecuencia = c.frecuencia.text.trim();
      final duracion = c.duracion.text.trim();

      if (nombre.isEmpty || dosis.isEmpty || frecuencia.isEmpty || duracion.isEmpty) {
        _mostrarError('Completa todos los campos de cada medicamento');
        return;
      }

      detallesJson.add({
        "nombreMedicamento": nombre,
        "dosis": dosis,
        "frecuencia": frecuencia,
        "duracion": duracion,
      });
    }

    setState(() => _cargando = true);
    final url = Uri.parse('http://localhost:8080/api/recetas');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": widget.pacienteId,
          "medicoId": RepositorioApp.instancia.idMedicoActual,
          "notas": _controladorNotas.text.trim(),
          "detalles": detallesJson,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _mostrarError('Error al guardar la receta en el servidor');
      }
    } catch (e) {
      debugPrint("Error: $e");
      _mostrarError('Error de conexion con el servidor');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class _ControladoresMedicamento {
  final nombre = TextEditingController();
  final dosis = TextEditingController();
  final frecuencia = TextEditingController();
  final duracion = TextEditingController();

  void dispose() {
    nombre.dispose();
    dosis.dispose();
    frecuencia.dispose();
    duracion.dispose();
  }
}

class _FormularioMedicamento extends StatelessWidget {
  final int indice;
  final _ControladoresMedicamento controladores;
  final VoidCallback? alEliminar;

  const _FormularioMedicamento({required this.indice, required this.controladores, this.alEliminar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: colores.primary.withValues(alpha: 0.12),
                child: Text('${indice + 1}', style: TextStyle(color: colores.primary, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('Medicamento', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary)),
              const Spacer(),
              if (alEliminar != null)
                IconButton(icon: Icon(Icons.delete_outline, color: colores.danger), onPressed: alEliminar, tooltip: 'Eliminar'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(controller: controladores.nombre, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nombre', hintText: 'Ej. Metformina', isDense: true)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: TextField(controller: controladores.dosis, decoration: const InputDecoration(labelText: 'Dosis', hintText: '850 mg', isDense: true))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: TextField(controller: controladores.duracion, decoration: const InputDecoration(labelText: 'Duracion', hintText: '30 dias', isDense: true))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: controladores.frecuencia, decoration: const InputDecoration(labelText: 'Frecuencia', hintText: 'Cada 12 horas', isDense: true)),
        ],
      ),
    );
  }
}