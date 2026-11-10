import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../seguimiento/modelos/registro_seguimiento.dart';
import '../pacientes/pantalla_detalle_paciente.dart'; 

class PantallaExpedientePaciente extends StatefulWidget {
  const PantallaExpedientePaciente({super.key});

  @override
  State<PantallaExpedientePaciente> createState() => _EstadoPantallaExpedientePaciente();
}

class _EstadoPantallaExpedientePaciente extends State<PantallaExpedientePaciente> {
  dynamic _pacienteInfo;
  List<RegistroSeguimiento> _seguimiento = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final id = RepositorioApp.instancia.idPacienteActual;
    final urlPaciente = Uri.parse('http://localhost:8080/api/pacientes/$id');
    final urlSeguimiento = Uri.parse('http://localhost:8080/api/seguimiento/paciente/$id');

    try {
      final res = await Future.wait([http.get(urlPaciente), http.get(urlSeguimiento)]);
      if (res[0].statusCode == 200) _pacienteInfo = jsonDecode(res[0].body);
      if (res[1].statusCode == 200) {
        final data = jsonDecode(res[1].body) as List;
        _seguimiento = data.map((j) => RegistroSeguimiento.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint("Error al cargar expediente del paciente: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_pacienteInfo == null) return const Center(child: Text('Sin datos'));

    RegistroSeguimiento? getUltimo(String tipo) {
      try { return _seguimiento.firstWhere((r) => r.tipo == tipo); } catch (_) { return null; }
    }
    
    final glucosa = getUltimo('glucosa');
    final presion = getUltimo('presion');
    final peso = getUltimo('peso');
    final temperatura = getUltimo('temperatura');
    final frecuencia = getUltimo('frecuencia');

    final edad = _pacienteInfo['edad']?.toString() ?? 'No reg.';
    final sexo = _pacienteInfo['sexo']?.toString() ?? 'No reg.';
    final sangre = _pacienteInfo['tipoSangre']?.toString() ?? 'No reg.';
    final List<String> enfermedades = List<String>.from(_pacienteInfo['enfermedades'] ?? []);
    final List<String> alergias = List<String>.from(_pacienteInfo['alergias'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mi expediente', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            const Text('Informacion clinica registrada por tu medico.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 24),

            TarjetaPerfilPacientePublica(
              nombre: RepositorioApp.instancia.nombrePacienteActual,
              edad: edad,
              sexo: sexo,
              sangre: sangre,
            ),
            const SizedBox(height: 20),
            
            TarjetaSignosVitalesPublica(
              glucosa: glucosa, 
              presion: presion, 
              peso: peso, 
              temperatura: temperatura, 
              frecuencia: frecuencia
            ),
            const SizedBox(height: 20),

            // AQUI LE DECIMOS QUE NO PUEDE EDITAR
            TarjetaAntecedentesPublica(
              enfermedades: enfermedades,
              alergias: alergias,
              onEditar: () {}, 
              puedeEditar: false, // <-- ESTO OCULTA LOS BOTONES
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}