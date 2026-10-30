import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import '../pacientes/pantalla_detalle_paciente.dart';

class PantallaExpedientesMedico extends StatefulWidget {
  const PantallaExpedientesMedico({super.key});

  @override
  State<PantallaExpedientesMedico> createState() =>
      _EstadoPantallaExpedientesMedico();
}

class _EstadoPantallaExpedientesMedico extends State<PantallaExpedientesMedico> {
  final _controladorBusqueda = TextEditingController();
  String _busqueda = '';
  List<dynamic> _pacientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  Future<void> _cargarPacientes() async {
    final url = Uri.parse('http://localhost:8080/api/pacientes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _pacientes = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error al cargar expedientes: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<dynamic> _filtrar(List<dynamic> todos) {
    if (_busqueda.isEmpty) return todos;
    final texto = _busqueda.toLowerCase();
    return todos.where((p) {
      final nombre = (p['usuario']?['nombre'] ?? '').toString().toLowerCase();
      final enfermedades = (p['enfermedades'] as List?)?.join(' ').toLowerCase() ?? '';
      return nombre.contains(texto) || enfermedades.contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    if (_cargando) return const Center(child: CircularProgressIndicator());

    final filtrados = _filtrar(_pacientes);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xs),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Expedientes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.textPrimary, letterSpacing: -0.3),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Selecciona un paciente para ver su expediente', style: TextStyle(color: colores.textSecondary)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: TextField(
            controller: _controladorBusqueda,
            onChanged: (v) => setState(() => _busqueda = v),
            decoration: InputDecoration(
              hintText: 'Buscar paciente o enfermedad',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busqueda.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controladorBusqueda.clear();
                        setState(() => _busqueda = '');
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('${filtrados.length} expedientes', style: TextStyle(color: colores.textSecondary, fontSize: 13)),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: filtrados.isEmpty
              ? Center(child: Text('Sin resultados', style: TextStyle(color: colores.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: filtrados.length,
                  itemBuilder: (context, i) => _EntradaExpediente(pacienteData: filtrados[i]),
                ),
        ),
      ],
    );
  }
}

class _EntradaExpediente extends StatelessWidget {
  final dynamic pacienteData;
  const _EntradaExpediente({required this.pacienteData});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    
    final int pacienteId = pacienteData['id'];
    final String nombre = pacienteData['usuario'] != null ? pacienteData['usuario']['nombre'] : 'Paciente';
    final List<String> enfermedades = List<String>.from(pacienteData['enfermedades'] ?? []);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PantallaDetallePaciente(
                  nombrePaciente: nombre,
                  pacienteId: pacienteId, // <-- LE PASAMOS EL ID REAL
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: colores.shadowSoft,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colores.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.folder_shared_outlined, color: colores.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        enfermedades.isEmpty ? 'Sin enfermedades registradas' : enfermedades.join(', '),
                        style: TextStyle(color: colores.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colores.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}