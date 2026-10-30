import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import 'modelos/receta.dart';
import 'pantalla_detalle_receta.dart';
import 'pantalla_formulario_receta.dart';

class PantallaRecetasMedico extends StatefulWidget {
  const PantallaRecetasMedico({super.key});

  @override
  State<PantallaRecetasMedico> createState() => _EstadoPantallaRecetasMedico();
}

class _EstadoPantallaRecetasMedico extends State<PantallaRecetasMedico> {
  List<Receta> _recetas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRecetas();
  }

  Future<void> _cargarRecetas() async {
    final url = Uri.parse('http://localhost:8080/api/recetas/medico/${RepositorioApp.instancia.idMedicoActual}');
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

  Future<void> _abrirFormulario(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PantallaFormularioReceta()),
    );

    if (resultado == true) {
      _cargarRecetas(); // Recargar si se guardo una nueva
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xs),
              child: Text('Recetas emitidas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.textPrimary, letterSpacing: -0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text('Historial de recetas que has creado', style: TextStyle(color: colores.textSecondary)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: _cargando 
                  ? const Center(child: CircularProgressIndicator())
                  : _recetas.isEmpty
                      ? Center(child: Text('Aun no has creado recetas', style: TextStyle(color: colores.textSecondary)))
                      : RefreshIndicator(
                          onRefresh: _cargarRecetas,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                            itemCount: _recetas.length,
                            itemBuilder: (context, i) {
                              final receta = _recetas[i];
                              return _TarjetaRecetaMedico(
                                receta: receta,
                                alPresionar: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaDetalleReceta(receta: receta)));
                                },
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        backgroundColor: colores.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva receta'),
      ),
    );
  }
}

class _TarjetaRecetaMedico extends StatelessWidget {
  final Receta receta;
  final VoidCallback alPresionar;

  const _TarjetaRecetaMedico({required this.receta, required this.alPresionar});

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
          onTap: alPresionar,
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
                      Text(receta.nombrePaciente, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(textoMedicamentos, style: TextStyle(color: colores.textSecondary, fontSize: 13)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${receta.idFormateado} - ${receta.fechaFormateada}', style: TextStyle(color: colores.textTertiary, fontSize: 12)),
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