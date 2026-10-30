import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';

class PantallaMedicamentos extends StatefulWidget {
  const PantallaMedicamentos({super.key});

  @override
  State<PantallaMedicamentos> createState() => _EstadoPantallaMedicamentos();
}

class _EstadoPantallaMedicamentos extends State<PantallaMedicamentos> with SingleTickerProviderStateMixin {
  late TabController _controladorPestanas;
  List<dynamic> _medicamentos = [];
  bool _cargando = true;
  DateTime _diaSeleccionado = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controladorPestanas = TabController(length: 3, vsync: this);
    _cargarMedicamentos();
  }

  Future<void> _cargarMedicamentos() async {
    final url = Uri.parse('http://localhost:8080/api/medicamentos/paciente/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _medicamentos = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error al cargar medicamentos: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _registrarToma(int medicamentoId, String hora) async {
    final fechaStr = "${_diaSeleccionado.year}-${_diaSeleccionado.month.toString().padLeft(2, '0')}-${_diaSeleccionado.day.toString().padLeft(2, '0')}";
    final url = Uri.parse('http://localhost:8080/api/medicamentos/$medicamentoId/tomar');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"fecha": fechaStr, "hora": hora}),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toma guardada')));
        _cargarMedicamentos();
      }
    } catch (e) {
      debugPrint("Error al registrar: $e");
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
        title: const Text('Mis medicamentos'),
        bottom: TabBar(
          controller: _controladorPestanas,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: colores.primary,
          labelColor: colores.primary,
          unselectedLabelColor: colores.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Hoy'),
            Tab(text: 'Tratamientos'),
            Tab(text: 'Historial'),
          ],
        ),
      ),
      body: _cargando 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _controladorPestanas,
            children: [
              _PestanaHoy(
                medicamentos: _medicamentos, 
                diaSeleccionado: _diaSeleccionado,
                onDiaSeleccionado: (dia) => setState(() => _diaSeleccionado = dia),
                onRegistrarToma: _registrarToma,
              ),
              _PestanaTratamientos(medicamentos: _medicamentos),
              _PestanaHistorial(medicamentos: _medicamentos),
            ],
          ),
    );
  }
}

class _PestanaHoy extends StatelessWidget {
  final List<dynamic> medicamentos;
  final DateTime diaSeleccionado;
  final Function(DateTime) onDiaSeleccionado;
  final Function(int, String) onRegistrarToma;

  const _PestanaHoy({
    required this.medicamentos,
    required this.diaSeleccionado,
    required this.onDiaSeleccionado,
    required this.onRegistrarToma,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const _TarjetaAdherenciaCompacta(),
        const SizedBox(height: AppSpacing.xl),

        Text('Tus tomas', style: TextStyle(fontWeight: FontWeight.bold, color: colores.textPrimary)),
        const SizedBox(height: AppSpacing.sm),
        _SelectorDias(diaSeleccionado: diaSeleccionado, onDiaSeleccionado: onDiaSeleccionado),
        const SizedBox(height: AppSpacing.xl),

        Text('Dosis programadas', style: TextStyle(fontWeight: FontWeight.bold, color: colores.textPrimary)),
        const SizedBox(height: AppSpacing.md),
        
        if (medicamentos.isEmpty)
          Text('No hay medicamentos', style: TextStyle(color: colores.textSecondary))
        else
          for (var med in medicamentos)
            for (var horario in med['horarios'])
              // CAMBIO AQUÍ: Nombre de clase sin ñ
              _TarjetaDosisMejorada(
                med: med, 
                hora: horario['horaDia'], 
                diaSeleccionado: diaSeleccionado,
                onRegistrar: () => onRegistrarToma(med['id'], horario['horaDia']),
              ),
      ],
    );
  }
}

// CAMBIO AQUÍ: Clase renombrada
class _TarjetaDosisMejorada extends StatelessWidget {
  final dynamic med;
  final String hora;
  final DateTime diaSeleccionado;
  final VoidCallback onRegistrar;

  const _TarjetaDosisMejorada({required this.med, required this.hora, required this.diaSeleccionado, required this.onRegistrar});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final fechaStr = "${diaSeleccionado.year}-${diaSeleccionado.month.toString().padLeft(2, '0')}-${diaSeleccionado.day.toString().padLeft(2, '0')}";
    
    final historial = med['historialTomas'] as List;
    final yaTomada = historial.any((h) => h['fechaProgramada'] == fechaStr && h['horaProgramada'] == hora && h['estado'] == 'tomada');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: yaTomada ? colores.surface.withValues(alpha: 0.5) : colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: yaTomada ? colores.divider : colores.primary.withValues(alpha: 0.2)),
        boxShadow: yaTomada ? [] : colores.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hora, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colores.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: yaTomada ? colores.success.withValues(alpha: 0.1) : colores.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  yaTomada ? 'Registrada como tomada' : 'Siguiente toma',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: yaTomada ? colores.success : colores.warning),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(med['nombre'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colores.textPrimary)),
          Text('${med['dosis']} - ${med['frecuencia']}', style: TextStyle(fontSize: 13, color: colores.textSecondary)),
          const SizedBox(height: AppSpacing.md),
          
          if (yaTomada)
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.receipt_long, size: 16),
              label: const Text('Ver registro'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            )
          else
            FilledButton.icon(
              onPressed: onRegistrar,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Registrar toma'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
            ),
        ],
      ),
    );
  }
}

class _TarjetaAdherenciaCompacta extends StatelessWidget {
  const _TarjetaAdherenciaCompacta();

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SEMANA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colores.primary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('Buen trabajo!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colores.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tomadas', style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                    Text('25', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.primary)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pendientes', style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                    Text('3', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colores.warning)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Detalle'),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectorDias extends StatelessWidget {
  final DateTime diaSeleccionado;
  final Function(DateTime) onDiaSeleccionado;

  const _SelectorDias({required this.diaSeleccionado, required this.onDiaSeleccionado});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final ahora = DateTime.now();
    final inicioSemana = ahora.subtract(Duration(days: ahora.weekday - 1));
    final dias = List.generate(7, (i) => inicioSemana.add(Duration(days: i)));
    final nombresDias = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final dia = dias[i];
          final esSeleccionado = dia.day == diaSeleccionado.day && dia.month == diaSeleccionado.month;

          return GestureDetector(
            onTap: () => onDiaSeleccionado(dia),
            child: Container(
              width: 56,
              decoration: BoxDecoration(
                color: esSeleccionado ? colores.primary : colores.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: esSeleccionado ? [] : colores.shadowSoft,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(nombresDias[i], style: TextStyle(fontSize: 11, color: esSeleccionado ? Colors.white70 : colores.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${dia.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: esSeleccionado ? Colors.white : colores.textPrimary)),
                  const SizedBox(height: 4),
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: esSeleccionado ? Colors.white : Colors.transparent, shape: BoxShape.circle),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PestanaTratamientos extends StatelessWidget {
  final List<dynamic> medicamentos;
  const _PestanaTratamientos({required this.medicamentos});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final activos = medicamentos.where((m) => m['estado'] == 'activo').toList();
    final inactivos = medicamentos.where((m) => m['estado'] != 'activo').toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Text('Tratamientos activos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colores.textPrimary)),
        const SizedBox(height: AppSpacing.md),
        if (activos.isEmpty)
          Text('Sin tratamientos', style: TextStyle(color: colores.textSecondary))
        else
          for (final med in activos) _TarjetaTratamiento(med: med),

        if (inactivos.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text('Historial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colores.textPrimary)),
          const SizedBox(height: AppSpacing.md),
          for (final med in inactivos) _TarjetaTratamiento(med: med),
        ]
      ],
    );
  }
}

class _TarjetaTratamiento extends StatelessWidget {
  final dynamic med;
  const _TarjetaTratamiento({required this.med});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final estaActivo = med['estado'] == 'activo';
    final horarios = (med['horarios'] as List).map((h) => h['horaDia'].toString()).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: colores.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(Icons.medication_outlined, color: colores.warning),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med['nombre'], style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: colores.textPrimary)),
                    Text('${med['dosis']} - ${med['frecuencia']}', style: TextStyle(fontSize: 13, color: colores.textSecondary)),
                  ],
                ),
              ),
              if (!estaActivo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: colores.textSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(med['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colores.textSecondary)),
                )
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: horarios.map((hora) => Chip(
              label: Text(hora),
              backgroundColor: colores.surfaceAlt,
              labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colores.textPrimary),
              side: BorderSide.none,
            )).toList(),
          )
        ],
      ),
    );
  }
}

class _PestanaHistorial extends StatelessWidget {
  final List<dynamic> medicamentos;
  const _PestanaHistorial({required this.medicamentos});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final eventos = <Map<String, dynamic>>[];

    for (final med in medicamentos) {
      for (final h in med['historialTomas']) {
        eventos.add({'med': med, 'fecha': h['fechaProgramada'], 'hora': h['horaProgramada'], 'estado': h['estado']});
      }
    }

    eventos.sort((a, b) => (b['fecha'] as String).compareTo(a['fecha'] as String));

    if (eventos.isEmpty) {
      return Center(child: Text('No hay registros', style: TextStyle(color: colores.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: eventos.length,
      itemBuilder: (context, i) {
        final datos = eventos[i];
        final esTomada = datos['estado'] == 'tomada';

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colores.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colores.divider),
          ),
          child: Row(
            children: [
              Icon(esTomada ? Icons.check_circle : Icons.cancel, color: esTomada ? colores.success : colores.danger, size: 24),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(datos['med']['nombre'], style: TextStyle(fontWeight: FontWeight.w700, color: colores.textPrimary)),
                    Text('${datos['fecha']} - ${datos['hora']}', style: TextStyle(fontSize: 12, color: colores.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}