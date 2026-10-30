import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import 'pantalla_detalle_paciente.dart';
import '../recetas/pantalla_formulario_receta.dart';

class PantallaListaPacientes extends StatefulWidget {
  const PantallaListaPacientes({super.key});

  @override
  State<PantallaListaPacientes> createState() => _EstadoPantallaListaPacientes();
}

class _EstadoPantallaListaPacientes extends State<PantallaListaPacientes> {
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
        setState(() {
          _pacientes = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Error al cargar pacientes: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  List<dynamic> _filtrar(List<dynamic> todos) {
    if (_busqueda.isEmpty) return todos;
    final texto = _busqueda.toLowerCase();
    return todos.where((p) {
      final nombre = (p['usuario']?['nombre'] ?? '').toString().toLowerCase();
      return nombre.contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    if (_cargando) return const Center(child: CircularProgressIndicator());

    final filtrados = _filtrar(_pacientes);

    return RefreshIndicator(
      onRefresh: _cargarPacientes,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
            child: TextField(
              controller: _controladorBusqueda,
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Text('${filtrados.length} pacientes', style: TextStyle(color: colores.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: filtrados.isEmpty
                ? Center(child: Text('Sin resultados', style: TextStyle(color: colores.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      return _TarjetaPaciente(pacienteData: filtrados[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPaciente extends StatelessWidget {
  final dynamic pacienteData;
  const _TarjetaPaciente({required this.pacienteData});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final int pacienteId = pacienteData['id'];
    final String nombre = pacienteData['usuario'] != null ? pacienteData['usuario']['nombre'] : 'Paciente sin nombre';
    final int? edad = pacienteData['edad'];
    final String tipoSangre = pacienteData['tipoSangre'] ?? 'N/A';

    return Material(
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
                pacienteId: pacienteId,
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
              CircleAvatar(
                radius: 24,
                backgroundColor: colores.primary.withValues(alpha: 0.12),
                child: Text(
                  nombre.isNotEmpty ? nombre.substring(0, 1) : '?',
                  style: TextStyle(color: colores.primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('${edad != null ? "$edad años · " : ""}Sangre: $tipoSangre', style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('ID Paciente: $pacienteId', style: TextStyle(color: colores.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaFormularioReceta(
                        pacienteId: pacienteId,
                        nombrePacienteInicial: nombre,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text('Recetar'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}