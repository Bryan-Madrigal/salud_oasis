import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import '../recetas/pantalla_formulario_receta.dart';
import '../recetas/pantalla_detalle_receta.dart'; // <-- IMPORTANTE: Importación agregada
import '../recetas/modelos/receta.dart'; 
import '../seguimiento/modelos/registro_seguimiento.dart';
import '../seguimiento/widgets/grafica_evolucion.dart';
import 'pantalla_editar_expediente.dart';

class PantallaDetallePaciente extends StatefulWidget {
  final String nombrePaciente;
  final int? pacienteId;

  const PantallaDetallePaciente({super.key, required this.nombrePaciente, this.pacienteId});

  @override
  State<PantallaDetallePaciente> createState() => _EstadoPantallaDetallePaciente();
}

class _EstadoPantallaDetallePaciente extends State<PantallaDetallePaciente> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  dynamic _pacienteInfo;
  List<RegistroSeguimiento> _seguimiento = [];
  List<Receta> _recetas = [];
  bool _cargando = true;
  String _indicadorGrafica = 'glucosa';

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
      final res = await Future.wait([http.get(urlPaciente), http.get(urlSeguimiento), http.get(urlRecetas)]);
      if (res[0].statusCode == 200) _pacienteInfo = jsonDecode(res[0].body);
      if (res[1].statusCode == 200) {
        final data = jsonDecode(res[1].body) as List;
        _seguimiento = data.map((j) => RegistroSeguimiento.fromJson(j)).toList();
      }
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
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Expediente',
            onPressed: () async {
              if (_pacienteInfo == null) return;
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaEditarExpediente(pacienteId: widget.pacienteId ?? 1, pacienteData: _pacienteInfo)));
              if (result == true) _cargarTodo();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colores.primary,
          labelColor: colores.primary,
          unselectedLabelColor: colores.textSecondary,
          tabs: const [Tab(text: 'Expediente'), Tab(text: 'Seguimiento'), Tab(text: 'Recetas')],
        ),
      ),
      body: _cargando ? const Center(child: CircularProgressIndicator()) : TabBarView(
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
    if (_pacienteInfo == null) return const Center(child: Text('Sin datos'));

    final esAncho = MediaQuery.of(context).size.width > 800;
    
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

    Widget columnaIzquierda = Column(
      children: [
        TarjetaPerfilPacientePublica(nombre: widget.nombrePaciente, edad: edad, sexo: sexo, sangre: sangre),
        const SizedBox(height: 20),
        TarjetaSignosVitalesPublica(glucosa: glucosa, presion: presion, peso: peso, temperatura: temperatura, frecuencia: frecuencia),
      ],
    );

    Widget columnaDerecha = TarjetaAntecedentesPublica(
      enfermedades: enfermedades,
      alergias: alergias,
      puedeEditar: true, // EL MEDICO SI PUEDE EDITAR
      onEditar: () async {
        if (_pacienteInfo == null) return;
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaEditarExpediente(pacienteId: widget.pacienteId ?? 1, pacienteData: _pacienteInfo)));
        if (result == true) _cargarTodo();
      },
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: esAncho
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: columnaIzquierda),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: columnaDerecha),
              ],
            )
          : Column(
              children: [
                columnaIzquierda,
                const SizedBox(height: 20),
                columnaDerecha,
              ],
            ),
    );
  }

  Widget _construirSeguimiento(BuildContext context) {
    final colores = context.colors;
    if (_seguimiento.isEmpty) return Center(child: Text('Sin registros de seguimiento', style: TextStyle(color: colores.textSecondary)));

    // SOLO SE MUESTRA LA GRÁFICA (Se eliminó el historial de registros)
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Evolucion del paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ChipIndicador(etiqueta: 'Glucosa', valor: 'glucosa', grupo: _indicadorGrafica, alCambiar: (v) => setState(() => _indicadorGrafica = v)),
                  _ChipIndicador(etiqueta: 'Presion', valor: 'presion', grupo: _indicadorGrafica, alCambiar: (v) => setState(() => _indicadorGrafica = v)),
                  _ChipIndicador(etiqueta: 'Peso', valor: 'peso', grupo: _indicadorGrafica, alCambiar: (v) => setState(() => _indicadorGrafica = v)),
                ],
              ),
              const SizedBox(height: 16),
              GraficaEvolucion(registros: _seguimiento, tipo: _indicadorGrafica),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirRecetas(BuildContext context) {
    final colores = context.colors;

    // 1. ORDENAR LAS RECETAS DE LA MÁS RECIENTE A LA MÁS ANTIGUA
    // (Asumiendo que el ID es numérico y autoincremental en tu backend)
    final recetasOrdenadas = List<Receta>.from(_recetas)
      ..sort((a, b) => b.id.compareTo(a.id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SizedBox(
            width: double.infinity, height: 50,
            child: FilledButton.icon(
              onPressed: () async {
                final resultado = await Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaFormularioReceta(pacienteId: widget.pacienteId ?? 1, nombrePacienteInicial: widget.nombrePaciente)));
                if (resultado == true) _cargarTodo(); 
              },
              icon: const Icon(Icons.add), label: const Text('Nueva receta / medicamento'),
            ),
          ),
        ),
        Expanded(
          child: recetasOrdenadas.isEmpty 
            ? Center(child: Text('Sin recetas para este paciente', style: TextStyle(color: colores.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                itemCount: recetasOrdenadas.length,
                itemBuilder: (context, i) {
                  final r = recetasOrdenadas[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    clipBehavior: Clip.antiAlias, // Para que el efecto de clic respete los bordes
                    child: ListTile(
                      // 2. HACER CLIC PARA VER EL DETALLE
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PantallaDetalleReceta(
                              receta: r, // Pásale el objeto completo
                            ),
                          ),
                        );
                      },
                      leading: Icon(Icons.receipt_long, color: colores.primary),
                      title: Text('Receta ${r.idFormateado}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${r.fechaFormateada} - ${r.items.length} medicamentos'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey), // Flechita
                    ),
                  );
                },
              ),
        )
      ],
    );
  }
}

class _ChipIndicador extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final String grupo;
  final Function(String) alCambiar;
  const _ChipIndicador({required this.etiqueta, required this.valor, required this.grupo, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    final seleccionado = valor == grupo;
    return GestureDetector(
      onTap: () => alCambiar(valor),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFFE0F2FE) : Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: seleccionado ? const Color(0xFF0EA5E9) : const Color(0xFFE2E8F0))
        ),
        child: Text(etiqueta, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: seleccionado ? const Color(0xFF0EA5E9) : Colors.grey.shade600)),
      ),
    );
  }
}

// ==========================================
// WIDGETS PUBLICOS (Para medico y paciente)
// ==========================================

class TarjetaPerfilPacientePublica extends StatelessWidget {
  final String nombre;
  final String edad;
  final String sexo;
  final String sangre;

  const TarjetaPerfilPacientePublica({super.key, required this.nombre, required this.edad, required this.sexo, required this.sangre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFE0F2FE),
            child: Text(
              nombre.substring(0, 1).toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('$edad años  |  $sexo', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Text('Sangre: $sangre', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaSignosVitalesPublica extends StatelessWidget {
  final RegistroSeguimiento? glucosa;
  final RegistroSeguimiento? presion;
  final RegistroSeguimiento? peso;
  final RegistroSeguimiento? temperatura;
  final RegistroSeguimiento? frecuencia;

  const TarjetaSignosVitalesPublica({super.key, this.glucosa, this.presion, this.peso, this.temperatura, this.frecuencia});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SIGNOS VITALES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
              Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF64748B)),
            ],
          ),
          const Divider(height: 24),
          
          _itemVital(Icons.water_drop, 'GLUCOSA', glucosa?.valor ?? '--', glucosa?.unidad ?? 'mg/dL', Colors.purple),
          _itemVital(Icons.monitor_weight, 'PESO', peso?.valor ?? '--', peso?.unidad ?? 'Kg', Colors.blue),
          _itemVital(Icons.thermostat, 'TEMPERATURA', temperatura?.valor ?? '--', temperatura?.unidad ?? '°C', Colors.teal),
          _itemVital(Icons.favorite, 'PRESIÓN ARTERIAL', presion?.valor ?? '--', presion?.unidad ?? 'mmHg', Colors.red),
          _itemVital(Icons.monitor_heart, 'FREC. CARDIACA', frecuencia?.valor ?? '--', frecuencia?.unidad ?? 'Fc', Colors.pink),
        ],
      ),
    );
  }

  Widget _itemVital(IconData icono, String label, String valor, String unidad, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icono, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: Text(unidad, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}

class TarjetaAntecedentesPublica extends StatelessWidget {
  final List<String> enfermedades;
  final List<String> alergias;
  final VoidCallback onEditar;
  final bool puedeEditar;

  const TarjetaAntecedentesPublica({
    super.key, 
    required this.enfermedades, 
    required this.alergias, 
    required this.onEditar,
    this.puedeEditar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ANTECEDENTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
          const SizedBox(height: 20),

          const Text('ANTECEDENTES PATOLÓGICOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          if (enfermedades.isEmpty)
            const Text('Sin enfermedades registradas', style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))
          else
            ...enfermedades.map((e) => _itemAntecedente(e, 'Diagnóstico registrado')),

          const SizedBox(height: 24),

          const Text('ALERGIAS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444), letterSpacing: 0.5)),
          const SizedBox(height: 12),
          if (alergias.isEmpty)
            const Text('Sin alergias registradas', style: TextStyle(fontSize: 13, color: Color(0xFF64748B)))
          else
            ...alergias.map((a) => _itemAntecedente(a, 'Alergia detectada', esAlergia: true)),

          if (puedeEditar) ...[
            const SizedBox(height: 32),
            _botonAgregar('AGREGAR ANTECEDENTES NO PATOLÓGICOS', onEditar),
            const SizedBox(height: 12),
            _botonAgregar('AGREGAR GINECO-OBSTÉTRICOS', onEditar),
            const SizedBox(height: 12),
            _botonAgregar('AGREGAR ALERGIAS', onEditar),
          ],
        ],
      ),
    );
  }

  Widget _itemAntecedente(String titulo, String subtitulo, {bool esAlergia = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ),
          const SizedBox(width: 8),
          Icon(
            esAlergia ? Icons.warning_amber_rounded : Icons.check,
            color: esAlergia ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(subtitulo, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ),
        ],
      ),
    );
  }

  Widget _botonAgregar(String texto, VoidCallback alPresionar) {
    return GestureDetector(
      onTap: alPresionar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10B981), style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.add, size: 14, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            Text(texto, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
          ],
        ),
      ),
    );
  }
}