import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import 'modelos/receta.dart';
import 'pantalla_detalle_receta.dart';

class PantallaRecetasPaciente extends StatefulWidget {
  const PantallaRecetasPaciente({super.key});

  @override
  State<PantallaRecetasPaciente> createState() => _EstadoPantallaRecetasPaciente();
}

class _EstadoPantallaRecetasPaciente extends State<PantallaRecetasPaciente> {
  List<Receta> _recetas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRecetas();
  }

  Future<void> _cargarRecetas() async {
    final url = Uri.parse('http://localhost:8080/api/recetas/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _recetas = data.map((json) => Receta.fromJson(json)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error al cargar recetas: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    // ORDENAMOS LAS RECETAS (De la más reciente a la más antigua)
    final recetasOrdenadas = List<Receta>.from(_recetas)
      ..sort((a, b) => b.id.compareTo(a.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              const Text(
                'Mis recetas',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Historial de recetas médicas',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),

              // LISTA DE RECETAS
              Expanded(
                child: recetasOrdenadas.isEmpty
                    ? const Center(child: Text('No tienes recetas registradas', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: recetasOrdenadas.length,
                        itemBuilder: (context, index) {
                          final receta = recetasOrdenadas[index];
                          return _TarjetaRecetaPaciente(receta: receta);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET DE LA TARJETA
// ==========================================
class _TarjetaRecetaPaciente extends StatelessWidget {
  final Receta receta;
  const _TarjetaRecetaPaciente({required this.receta});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // CLIC PARA ABRIR EL DETALLE
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaDetalleReceta(receta: receta),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icono de la receta
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE), // Azul claro
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long, color: Color(0xFF0284C7)),
                ),
                const SizedBox(width: 16),
                
                // Información de la receta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receta ${receta.idFormateado}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        receta.items.isNotEmpty ? receta.items.first.nombreMedicamento : 'Medicamento',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // AQUI ESTA LA CORRECCION (Se quitó el ?? 'Médico')
                      Text(
                        'Dr. ${receta.nombreMedico} - ${receta.fechaFormateada}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                
                // Flechita a la derecha
                const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}