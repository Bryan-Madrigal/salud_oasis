import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';

class PantallaEditarExpediente extends StatefulWidget {
  final int pacienteId;
  final dynamic pacienteData;

  const PantallaEditarExpediente({
    super.key,
    required this.pacienteId,
    required this.pacienteData,
  });

  @override
  State<PantallaEditarExpediente> createState() => _EstadoPantallaEditarExpediente();
}

class _EstadoPantallaEditarExpediente extends State<PantallaEditarExpediente> {
  final _edadController = TextEditingController();
  final _enfermedadesController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _sexoController = TextEditingController();
  
  String _tipoSangre = 'O+';
  bool _cargando = false;

  final List<String> _tiposSangre = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    final p = widget.pacienteData;
    _edadController.text = p['edad']?.toString() ?? '';
    _sexoController.text = p['sexo'] ?? 'Masculino';
    _tipoSangre = p['tipoSangre'] != null && _tiposSangre.contains(p['tipoSangre']) ? p['tipoSangre'] : 'O+';
    
    final enfermedades = List<String>.from(p['enfermedades'] ?? []);
    _enfermedadesController.text = enfermedades.join(', ');
    
    final alergias = List<String>.from(p['alergias'] ?? []);
    _alergiasController.text = alergias.join(', ');
  }

  @override
  void dispose() {
    _edadController.dispose();
    _enfermedadesController.dispose();
    _alergiasController.dispose();
    _sexoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _cargando = true);

    final enfermedadesList = _enfermedadesController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
        
    final alergiasList = _alergiasController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final url = Uri.parse('http://localhost:8080/api/pacientes/${widget.pacienteId}');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "edad": _edadController.text.trim(),
          "sexo": _sexoController.text.trim(),
          "tipoSangre": _tipoSangre,
          "enfermedades": enfermedadesList,
          "alergias": alergiasList,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexion')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Expediente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Datos Clinicos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colores.textPrimary)),
              const SizedBox(height: AppSpacing.xl),

              Text('Edad', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _edadController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Ej. 25'),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Sexo', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _sexoController.text == 'Femenino' ? 'Femenino' : 'Masculino',
                decoration: const InputDecoration(),
                items: ['Masculino', 'Femenino'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _sexoController.text = v!),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Tipo de Sangre', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _tipoSangre,
                decoration: const InputDecoration(),
                items: _tiposSangre.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _tipoSangre = v!),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Enfermedades Cronicas', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _enfermedadesController,
                decoration: const InputDecoration(hintText: 'Ej. Diabetes, Hipertension (separados por coma)'),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('Alergias', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _alergiasController,
                decoration: const InputDecoration(hintText: 'Ej. Penicilina, Polvo (separados por coma)'),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar Cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}