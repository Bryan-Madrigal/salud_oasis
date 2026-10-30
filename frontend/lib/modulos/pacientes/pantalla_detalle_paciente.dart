import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import '../recetas/pantalla_formulario_receta.dart';
import '../recetas/modelos/receta.dart'; 
import 'pantalla_editar_expediente.dart'; // <-- IMPORT NUEVO

class PantallaDetallePaciente extends StatefulWidget {
  final String nombrePaciente;
  final int? pacienteId;

  const PantallaDetallePaciente({
    super.key, 
    required this.nombrePaciente,
    this.pacienteId,
  });

  @override
  State<PantallaDetallePaciente> createState() => _EstadoPantallaDetallePaciente();
}

class _EstadoPantallaDetallePaciente extends State<PantallaDetallePaciente> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  dynamic _pacienteInfo;
  List<dynamic> _seguimiento = [];
  List<Receta> _recetas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    final id = widget.pacienteId ?? 1; 
    
    final urlPaciente = Uri.parse('http://localhost:8080/api/pacientes/$id');
    final urlSeguimiento = Uri.parse('http://localhost:8080/api/seguimiento/paciente/$id');
    final urlRecetas = Uri.parse('http://localhost:8080/api/recetas/paciente/$id');

    try {
      final res = await Future.wait([
        http.get(urlPaciente),
        http.get(urlSeguimiento),
        http.get(urlRecetas),
      ]);

      if (res[0].statusCode == 200) _pacienteInfo = jsonDecode(res[0].body);
      if (res[1].statusCode == 200) _seguimiento = jsonDecode(res[1].body);
      if (res[2].statusCode == 200) {
        final data = jsonDecode(res[2].body) as List;
        _recetas = data.map((j) => Receta.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint("Error cargando expediente: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombrePaciente),
        actions: [
          // BOTON PARA EDITAR EL EXPEDIENTE
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Expediente',
            onPressed: () async {
              if (_pacienteInfo == null) return;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PantallaEditarExpediente(
                    pacienteId: widget.pacienteId ?? 1,
                    pacienteData: _pacienteInfo,
                  ),
                ),
              );
              if (result == true) {
                _cargarTodo(); // Recargar los datos si se guardo algo
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colores.primary,
          labelColor: colores.primary,
          unselectedLabelColor: colores.textSecondary,
          tabs: const [
            Tab(text: 'Expediente'),
            Tab(text: 'Seguimiento'),
            Tab(text: 'Recetas'),
          ],
        ),
      ),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _construirExpediente(context),
              _construirSeguimiento(context),
              _construirRecetas(context),
            ],
          ),
    );
  }

  Widget _construirExpediente(BuildContext context) {
    final colores = context.colors;
    if (_pacienteInfo == null) return const Center(child: Text('Sin datos'));

    final edad = _pacienteInfo['edad'] ?? 'No registrada';
    final sexo = _pacienteInfo['sexo'] ?? 'No registrado';
    final sangre = _pacienteInfo['tipoSangre'] ?? 'No registrado';
    final enfermedades = (_pacienteInfo['enfermedades'] as List?)?.join(', ') ?? 'Ninguna';
    final alergias = (_pacienteInfo['alergias'] as List?)?.join(', ') ?? 'Ninguna';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _infoFila('Edad', '$edad anos', colores),
        _infoFila('Sexo', '$sexo', colores),
        _infoFila('Tipo de sangre', '$sangre', colores),
        _infoFila('Enfermedades', enfermedades, colores),
        _infoFila('Alergias', alergias, colores),
      ],
    );
  }

  Widget _construirSeguimiento(BuildContext context) {
    final colores = context.colors;
    if (_seguimiento.isEmpty) return Center(child: Text('Sin registros de seguimiento', style: TextStyle(color: colores.textSecondary)));
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: _seguimiento.length,
      itemBuilder: (context, i) {
        final r = _seguimiento[i];
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: Icon(Icons.show_chart, color: colores.primary),
            title: Text('${r['nombreMostrar']}: ${r['valor']} ${r['unidad']}'),
            subtitle: Text(r['fechaHora'].toString().substring(0, 10)),
          ),
        );
      },
    );
  }

  Widget _construirRecetas(BuildContext context) {
    final colores = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PantallaFormularioReceta(
                      pacienteId: widget.pacienteId ?? 1,
                      nombrePacienteInicial: widget.nombrePaciente,
                    ),
                  ),
                );
                if (resultado == true) _cargarTodo(); 
              },
              icon: const Icon(Icons.add),
              label: const Text('Nueva receta / medicamento'),
            ),
          ),
        ),
        Expanded(
          child: _recetas.isEmpty 
            ? Center(child: Text('Sin recetas para este paciente', style: TextStyle(color: colores.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: _recetas.length,
                itemBuilder: (context, i) {
                  final r = _recetas[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListTile(
                      leading: Icon(Icons.receipt_long, color: colores.primary),
                      title: Text('Receta ${r.idFormateado}'),
                      subtitle: Text('${r.fechaFormateada} - ${r.items.length} medicamentos'),
                    ),
                  );
                },
              ),
        )
      ],
    );
  }

  Widget _infoFila(String etiqueta, String valor, dynamic colores) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(etiqueta, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textSecondary)),
          ),
          Expanded(
            child: Text(valor, style: TextStyle(fontWeight: FontWeight.w500, color: colores.textPrimary)),
          ),
        ],
      ),
    );
  }
}