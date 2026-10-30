import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
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
    final colores = context.colors;

    if (_cargando) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _cargarRecetas,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis recetas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.textPrimary, letterSpacing: -0.3)),
            const SizedBox(height: AppSpacing.xs),
            Text('Historial de recetas medicas', style: TextStyle(color: colores.textSecondary)),
            const SizedBox(height: AppSpacing.xl),

            if (_recetas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Aun no tienes recetas', style: TextStyle(color: colores.textSecondary))),
              )
            else
              for (final receta in _recetas) _TarjetaReceta(receta: receta),
          ],
        ),
      ),
    );
  }
}

class _TarjetaReceta extends StatelessWidget {
  final Receta receta;

  const _TarjetaReceta({required this.receta});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final cantidad = receta.items.length;
    final textoMedicamentos = cantidad == 1
        ? receta.items.first.nombreMedicamento
        : '${receta.items.first.nombreMedicamento} + ${cantidad - 1} mas';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaDetalleReceta(receta: receta)));
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: colores.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Icon(Icons.description_outlined, color: colores.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Receta ${receta.idFormateado}', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(textoMedicamentos, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${receta.nombreMedico} - ${receta.fechaFormateada}', style: TextStyle(color: colores.textTertiary, fontSize: 12)),
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