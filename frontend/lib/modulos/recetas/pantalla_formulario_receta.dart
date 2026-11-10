import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';


class PantallaFormularioReceta extends StatefulWidget {
  final int? pacienteId;
  final String? nombrePacienteInicial;

  const PantallaFormularioReceta({super.key, this.pacienteId, this.nombrePacienteInicial});

  @override
  State<PantallaFormularioReceta> createState() => _EstadoPantallaFormularioReceta();
}

class _EstadoPantallaFormularioReceta extends State<PantallaFormularioReceta> {
  final _controladorPaciente = TextEditingController();
  final _controladorNotas = TextEditingController();
  final _controladorDiagnostico = TextEditingController();
  final _controladorEdad = TextEditingController();
  final _controladorPeso = TextEditingController();
  final _controladorAltura = TextEditingController();
  
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
    _controladorDiagnostico.dispose();
    _controladorEdad.dispose();
    _controladorPeso.dispose();
    _controladorAltura.dispose();
    for (final item in _medicamentos) { item.dispose(); }
    super.dispose();
  }

  Future<void> _guardarReceta() async {
    if (widget.pacienteId == null) return _mostrarError('Paciente no valido');

    final List<Map<String, String>> detallesJson = [];
    for (final c in _medicamentos) {
      if (c.nombre.text.trim().isEmpty) return _mostrarError('Escribe al menos un medicamento');
      
      detallesJson.add({
        "nombreMedicamento": c.nombre.text.trim(),
        "dosis": c.dosis.text.trim().isEmpty ? "Segun indicacion" : c.dosis.text.trim(),
        "frecuencia": c.frecuencia.text.trim().isEmpty ? "Segun indicacion" : c.frecuencia.text.trim(),
        "duracion": c.duracion.text.trim().isEmpty ? "Segun indicacion" : c.duracion.text.trim(),
        "viaAdministracion": c.via.text.trim(),
        "cantidad": c.cantidad.text.trim(),
      });
    }

    setState(() => _cargando = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/recetas'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": widget.pacienteId,
          "medicoId": RepositorioApp.instancia.idMedicoActual,
          "notas": _controladorNotas.text.trim(),
          "diagnostico": _controladorDiagnostico.text.trim(),
          "edad": int.tryParse(_controladorEdad.text.trim()),
          "peso": _controladorPeso.text.trim(),
          "altura": _controladorAltura.text.trim(),
          "detalles": detallesJson,
        }),
      );
      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        _mostrarError('Error al guardar');
      }
    } catch (e) {
      _mostrarError('Error de conexion');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr = '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Nueva Receta Medica'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save, color: Colors.blue),
            tooltip: 'Guardar Receta',
            onPressed: _cargando ? null : _guardarReceta,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ENCABEZADO CENTRADO
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/receta.png', width: 80, height: 80, errorBuilder: (_,__,___) => const Icon(Icons.medical_services, size: 80)),
                      const SizedBox(height: 12),
                      Text('Dr. ${RepositorioApp.instancia.nombreMedicoActual}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      const Text('Medico Familiar', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 8),
                      const Text('Cedula de Profesional 2174322-E\nC. Pablo Valdez, La Perla\n44360 Guadalajara, Jal. Mexico', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // PACIENTE
                const Text('Informacion del paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildInput('Nombre completo', _controladorPaciente, readOnly: true),
                Row(
                  children: [
                    Expanded(child: _buildInput('Edad', _controladorEdad, keyboard: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Fecha', TextEditingController(text: fechaStr), readOnly: true)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildInput('Peso', _controladorPeso)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInput('Altura', _controladorAltura)),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 24),

                // DIAGNOSTICO
                const Text('Diagnostico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildInput('Diagnostico medico', _controladorDiagnostico),
                
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 24),

                // MEDICAMENTOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('RX - Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    TextButton.icon(
                      onPressed: () => setState(() => _medicamentos.add(_ControladoresMedicamento())),
                      icon: const Icon(Icons.add, size: 16, color: Colors.blue),
                      label: const Text('Agregar', style: TextStyle(color: Colors.blue)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < _medicamentos.length; i++) _buildCardMedicamento(i),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 24),

                // INDICACIONES
                const Text('Indicaciones adicionales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _buildInput('Escribir indicaciones del tratamiento...', _controladorNotas, maxLines: 4),

                const SizedBox(height: 48),
                
                // FIRMA
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Divider(color: Colors.black, thickness: 1),
                      ),
                      const SizedBox(height: 8),
                      const Text('Firma del medico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('Nombre y cedula profesional', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool readOnly = false, int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMedicamento(int index) {
    final c = _medicamentos[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Medicamento ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
              if (_medicamentos.length > 1)
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => setState(() { _medicamentos.removeAt(index); })),
            ],
          ),
          const SizedBox(height: 8),
          _buildInput('Nombre y presentacion', c.nombre),
          Row(
            children: [
              Expanded(child: _buildInput('Dosis', c.dosis)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('Via', c.via)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildInput('Frecuencia', c.frecuencia)),
              const SizedBox(width: 16),
              Expanded(child: _buildInput('Duracion', c.duracion)),
            ],
          ),
          _buildInput('Cantidad total', c.cantidad),
        ],
      ),
    );
  }
}

class _ControladoresMedicamento {
  final nombre = TextEditingController();
  final dosis = TextEditingController();
  final via = TextEditingController();
  final frecuencia = TextEditingController();
  final duracion = TextEditingController();
  final cantidad = TextEditingController();
  void dispose() { nombre.dispose(); dosis.dispose(); via.dispose(); frecuencia.dispose(); duracion.dispose(); cantidad.dispose(); }
}