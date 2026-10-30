import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../nucleo/utilidades/rangos_medicion.dart';
import 'pantalla_formulario_seguimiento.dart';
import 'modelos/registro_seguimiento.dart';
import 'widgets/grafica_evolucion.dart';

class PantallaSeguimiento extends StatefulWidget {
  const PantallaSeguimiento({super.key});

  @override
  State<PantallaSeguimiento> createState() => _EstadoPantallaSeguimiento();
}

class _EstadoPantallaSeguimiento extends State<PantallaSeguimiento> with SingleTickerProviderStateMixin {
  late TabController _controladorPestanas;
  List<RegistroSeguimiento> _registros = [];
  List<dynamic> _medicamentos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _controladorPestanas = TabController(length: 3, vsync: this);
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    final id = RepositorioApp.instancia.idPacienteActual;
    final urlSeguimiento = Uri.parse('http://localhost:8080/api/seguimiento/paciente/$id');
    final urlMedicamentos = Uri.parse('http://localhost:8080/api/medicamentos/paciente/$id');

    try {
      final res = await Future.wait([
        http.get(urlSeguimiento),
        http.get(urlMedicamentos),
      ]);

      if (res[0].statusCode == 200) {
        final data = jsonDecode(res[0].body) as List;
        _registros = data.map((j) => RegistroSeguimiento.fromJson(j)).toList();
      }
      if (res[1].statusCode == 200) {
        _medicamentos = jsonDecode(res[1].body);
      }
    } catch (e) {
      debugPrint("Error al cargar seguimiento: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _controladorPestanas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi seguimiento'),
        bottom: TabBar(
          controller: _controladorPestanas,
          indicatorColor: colores.primary,
          labelColor: colores.primary,
          unselectedLabelColor: colores.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Registrar'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _controladorPestanas,
            children: [
              _PestanaResumen(registros: _registros, medicamentos: _medicamentos, onRecargar: _cargarTodo),
              _PestanaRegistrar(onRecargar: _cargarTodo), // <-- Le pasamos la funcion para recargar
              _PestanaHistorial(registros: _registros),
            ],
          ),
    );
  }
}

class _PestanaResumen extends StatefulWidget {
  final List<RegistroSeguimiento> registros;
  final List<dynamic> medicamentos;
  final VoidCallback onRecargar;

  const _PestanaResumen({required this.registros, required this.medicamentos, required this.onRecargar});

  @override
  State<_PestanaResumen> createState() => _EstadoPestanaResumen();
}

class _EstadoPestanaResumen extends State<_PestanaResumen> {
  int _diasPeriodo = 7;
  String _indicador = 'presion';

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final hoy = DateTime.now();

    // 1. Calcular registros de salud de hoy
    final registrosHoy = widget.registros.where((r) => 
      r.fechaHora.year == hoy.year && r.fechaHora.month == hoy.month && r.fechaHora.day == hoy.day
    ).length;

    // 2. Calcular Tomas de medicamentos programadas para hoy y tomadas
    int tomasProgramadasHoy = 0;
    int tomasTomadasHoy = 0;
    
    for (final med in widget.medicamentos) {
      if (med['estado'] != 'activo') continue;
      
      final horarios = med['horarios'] as List;
      tomasProgramadasHoy += horarios.length;

      final historial = med['historialTomas'] as List;
      final fechaHoyStr = "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";
      
      for (final h in historial) {
        if (h['fechaProgramada'] == fechaHoyStr && h['estado'] == 'tomada') {
          tomasTomadasHoy++;
        }
      }
    }

    // 3. Calcular progreso
    double progreso = 0;
    if (tomasProgramadasHoy > 0) {
      progreso = tomasTomadasHoy / tomasProgramadasHoy;
      if (progreso > 1) progreso = 1; // Tope del 100%
    }

    final fechaLimite = DateTime.now().subtract(Duration(days: _diasPeriodo));
    final registrosFiltrados = widget.registros.where((r) => r.fechaHora.isAfter(fechaLimite)).toList();

    return RefreshIndicator(
      onRefresh: () async => widget.onRecargar(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola! Como te sientes hoy?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: colores.textPrimary)),
            const SizedBox(height: AppSpacing.xs),
            Text('Lleva el control de tu salud a tu ritmo.', style: TextStyle(color: colores.textSecondary)),
            const SizedBox(height: AppSpacing.xl),

            // TARJETAS DE RESUMEN (AHORA CON DATOS REALES)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(gradient: AppGradients.heroSoft, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: colores.primary.withValues(alpha: 0.2))),
              child: Row(
                children: [
                  Expanded(
                    child: _EstadisticaProgreso(
                      valor: '$tomasTomadasHoy/$tomasProgramadasHoy', 
                      etiqueta: 'Tomas\nregistradas', 
                      icono: Icons.medication_outlined
                    ),
                  ),
                  Container(width: 1, height: 40, color: colores.primary.withValues(alpha: 0.2)),
                  Expanded(
                    child: _EstadisticaProgreso(
                      valor: '$registrosHoy', 
                      etiqueta: 'Registros\nde salud', 
                      icono: Icons.show_chart
                    ),
                  ),
                  Container(width: 1, height: 40, color: colores.primary.withValues(alpha: 0.2)),
                  Expanded(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 40, 
                              height: 40, 
                              child: CircularProgressIndicator(
                                value: progreso, 
                                strokeWidth: 4, 
                                backgroundColor: colores.primary.withValues(alpha: 0.1), 
                                valueColor: AlwaysStoppedAnimation(colores.primary)
                              )
                            ),
                            Text('${(progreso * 100).round()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colores.primary)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Progreso', style: TextStyle(fontSize: 11, color: colores.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Check-in diario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colores.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Como te has sentido hoy?', style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _BotonEstadoAnimo(emoji: '😊', etiqueta: 'Bien', alPresionar: () => _guardarCheckin(context, 'Bien')),
                      _BotonEstadoAnimo(emoji: '😐', etiqueta: 'Regular', alPresionar: () => _guardarCheckin(context, 'Regular')),
                      _BotonEstadoAnimo(emoji: '😔', etiqueta: 'Mal', alPresionar: () => _guardarCheckin(context, 'Mal')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Mi evolucion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colores.textPrimary)),
            const SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                _ChipPeriodo(etiqueta: '7 dias', seleccionado: _diasPeriodo == 7, alPresionar: () => setState(() => _diasPeriodo = 7)),
                const SizedBox(width: AppSpacing.sm),
                _ChipPeriodo(etiqueta: '30 dias', seleccionado: _diasPeriodo == 30, alPresionar: () => setState(() => _diasPeriodo = 30)),
                const SizedBox(width: AppSpacing.sm),
                _ChipPeriodo(etiqueta: '90 dias', seleccionado: _diasPeriodo == 90, alPresionar: () => setState(() => _diasPeriodo = 90)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Indicador', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colores.textSecondary)),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                _RadioIndicador(etiqueta: 'Presion', valor: 'presion', valorGrupo: _indicador, alCambiar: (v) => setState(() => _indicador = v!)),
                _RadioIndicador(etiqueta: 'Glucosa', valor: 'glucosa', valorGrupo: _indicador, alCambiar: (v) => setState(() => _indicador = v!)),
                _RadioIndicador(etiqueta: 'Peso', valor: 'peso', valorGrupo: _indicador, alCambiar: (v) => setState(() => _indicador = v!)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            GraficaEvolucion(registros: registrosFiltrados, tipo: _indicador),
          ],
        ),
      ),
    );
  }

  Future<void> _guardarCheckin(BuildContext context, String estado) async {
    final url = Uri.parse('http://localhost:8080/api/seguimiento');
    try {
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": RepositorioApp.instancia.idPacienteActual,
          "tipo": "checkin",
          "nombreMostrar": "Check-in",
          "valor": estado,
          "unidad": "",
          "observaciones": "Estado de animo: $estado",
        }),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check-in guardado: $estado')));
      widget.onRecargar(); // Recargamos los datos
    } catch (e) {
      debugPrint("Error checkin: $e");
    }
  }
}

class _PestanaRegistrar extends StatelessWidget {
  final VoidCallback onRecargar;
  const _PestanaRegistrar({required this.onRecargar}); // <-- Recibe la funcion

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Que deseas registrar?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colores.textPrimary)),
          const SizedBox(height: AppSpacing.xs),
          Text('Selecciona una opcion para abrir el formulario.', style: TextStyle(color: colores.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(child: _BotonRegistroGrande(icono: Icons.water_drop_outlined, titulo: 'Glucosa', subtitulo: 'Medir azucar', color: colores.primary, alPresionar: () => _abrirFormulario(context, 'glucosa'))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _BotonRegistroGrande(icono: Icons.favorite_border, titulo: 'Presion', subtitulo: 'Medir presion', color: colores.accent, alPresionar: () => _abrirFormulario(context, 'presion'))),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _BotonRegistroGrande(icono: Icons.monitor_weight_outlined, titulo: 'Peso', subtitulo: 'Registrar peso', color: colores.info, alPresionar: () => _abrirFormulario(context, 'peso'))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _BotonRegistroGrande(icono: Icons.sick_outlined, titulo: 'Sintomas', subtitulo: 'Como te sientes?', color: colores.warning, alPresionar: () => _abrirFormulario(context, 'sintomas'))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _abrirFormulario(BuildContext context, String tipo) async {
    final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaFormularioSeguimiento(tipoInicial: tipo)));
    if (res == true) {
      onRecargar(); // Si guardo algo, recargamos el resumen
    }
  }
}

class _PestanaHistorial extends StatelessWidget {
  final List<RegistroSeguimiento> registros;
  const _PestanaHistorial({required this.registros});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    
    if (registros.isEmpty) {
      return Center(child: Text('Aun no tienes registros', style: TextStyle(color: colores.textSecondary)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: registros.length,
      itemBuilder: (context, i) {
        final registro = registros[i];
        final color = InfoTipoSeguimiento.colorPara(registro.tipo);
        final icono = InfoTipoSeguimiento.iconoPara(registro.tipo);
        final estado = RangosMedicion.evaluarRegistro(tipo: registro.tipo, valor: registro.valor);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: colores.surface, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(icono, color: color, size: 20)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(registro.nombreMostrar, style: TextStyle(fontWeight: FontWeight.w600, color: colores.textPrimary)),
                        const SizedBox(width: 8),
                        if (estado != EstadoMedicion.desconocido && registro.tipo != 'checkin')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: estado == EstadoMedicion.normal ? colores.success.withValues(alpha: 0.1) : colores.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(estado.etiqueta, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: estado == EstadoMedicion.normal ? colores.success : colores.warning)),
                          ),
                      ],
                    ),
                    Text('${registro.fechaFormateada} - ${registro.horaFormateada}', style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                  ],
                ),
              ),
              Text(registro.valor, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colores.textPrimary)),
            ],
          ),
        );
      },
    );
  }
}

class _EstadisticaProgreso extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;
  const _EstadisticaProgreso({required this.valor, required this.etiqueta, required this.icono});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Column(
      children: [
        Icon(icono, color: colores.primary, size: 20),
        const SizedBox(height: 4),
        Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colores.textPrimary)),
        Text(etiqueta, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: colores.textSecondary)),
      ],
    );
  }
}

class _BotonEstadoAnimo extends StatelessWidget {
  final String emoji;
  final String etiqueta;
  final VoidCallback alPresionar;
  const _BotonEstadoAnimo({required this.emoji, required this.etiqueta, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: colores.border), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(etiqueta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colores.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _BotonRegistroGrande extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback alPresionar;
  const _BotonRegistroGrande({required this.icono, required this.titulo, required this.subtitulo, required this.color, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Material(
      color: colores.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: alPresionar,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: colores.shadowSoft, border: Border.all(color: colores.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle), child: Icon(icono, color: color, size: 24)),
              const SizedBox(height: AppSpacing.md),
              Text(titulo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colores.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitulo, style: TextStyle(fontSize: 12, color: colores.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipPeriodo extends StatelessWidget {
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback alPresionar;
  const _ChipPeriodo({required this.etiqueta, required this.seleccionado, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: alPresionar,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: seleccionado ? colores.primary : colores.surface, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: seleccionado ? colores.primary : colores.border)),
          alignment: Alignment.center,
          child: Text(etiqueta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: seleccionado ? Colors.white : colores.textSecondary)),
        ),
      ),
    );
  }
}

class _RadioIndicador extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final String valorGrupo;
  final ValueChanged<String?> alCambiar;
  const _RadioIndicador({required this.etiqueta, required this.valor, required this.valorGrupo, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final seleccionado = valor == valorGrupo;
    return Expanded(
      child: GestureDetector(
        onTap: () => alCambiar(valor),
        child: Row(
          children: [
            Icon(seleccionado ? Icons.radio_button_checked : Icons.radio_button_unchecked, size: 18, color: seleccionado ? colores.primary : colores.textTertiary),
            const SizedBox(width: 4),
            Text(etiqueta, style: TextStyle(fontSize: 12, color: seleccionado ? colores.textPrimary : colores.textSecondary)),
          ],
        ),
      ),
    );
  }
}