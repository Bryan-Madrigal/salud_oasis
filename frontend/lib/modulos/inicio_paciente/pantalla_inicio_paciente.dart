import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import '../expediente/pantalla_expediente_paciente.dart';
import '../seguimiento/pantalla_seguimiento.dart';
import '../seguimiento/modelos/registro_seguimiento.dart';
import '../citas/pantalla_citas_paciente.dart';
import '../medicamentos/pantalla_medicamentos.dart';
import '../recetas/pantalla_recetas_paciente.dart';
// CORRECCIÓN 1: Importamos la pantalla del PACIENTE (ya estaba bien, pero nos aseguramos)
import '../notificaciones/pantalla_notificaciones_paciente.dart';
import '../configuracion/pantalla_configuracion.dart';
import '../autenticacion/pantalla_login.dart';

class PantallaInicioPaciente extends StatefulWidget {
  const PantallaInicioPaciente({super.key});

  @override
  State<PantallaInicioPaciente> createState() => _EstadoPantallaInicioPaciente();
}

class _EstadoPantallaInicioPaciente extends State<PantallaInicioPaciente> {
  int _indiceSeleccionado = 0;

  static const _titulos = [
    'Mi Salud Oasis', 'Mi expediente', 'Mi seguimiento', 'Mis medicamentos', 'Mis recetas', 'Mis citas',
  ];

  static const _itemsNavegacion = [
    _ItemNavegacion(icono: Icons.home_outlined, iconoSeleccionado: Icons.home, etiqueta: 'Inicio'),
    _ItemNavegacion(icono: Icons.description_outlined, iconoSeleccionado: Icons.description, etiqueta: 'Expediente'),
    _ItemNavegacion(icono: Icons.show_chart_outlined, iconoSeleccionado: Icons.show_chart, etiqueta: 'Seguimiento'),
    _ItemNavegacion(icono: Icons.medication_outlined, iconoSeleccionado: Icons.medication, etiqueta: 'Medicamentos'),
    _ItemNavegacion(icono: Icons.receipt_long_outlined, iconoSeleccionado: Icons.receipt_long, etiqueta: 'Recetas'),
    _ItemNavegacion(icono: Icons.calendar_month_outlined, iconoSeleccionado: Icons.calendar_month, etiqueta: 'Citas'),
  ];

  static const _pestanasMovil = [0, 2, 3, 5];

  bool _esAncho(BuildContext context) => MediaQuery.of(context).size.width >= 700;

  void _abrirNotificaciones() {
    // CORRECCIÓN 2: Llamamos a la clase del PACIENTE
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaNotificacionesPaciente()));
  }

  void _abrirConfiguracion() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PantallaConfiguracion(
        nombreUsuario: RepositorioApp.instancia.nombrePacienteActual,
        rolUsuario: 'Paciente',
      ),
    ));
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('Seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesion')),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = _esAncho(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: ancho ? null : _construirMenuLateral(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: ancho ? null : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset('assets/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(
              'Mi Salud Oasis',
              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF0F172A)),
            onPressed: _abrirNotificaciones,
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _indiceSeleccionado,
          children: [
            _PestanaInicioPacienteNuevo(
              onCambiarPestana: (index) => setState(() => _indiceSeleccionado = index),
            ),
            const PantallaExpedientePaciente(),
            const PantallaSeguimiento(),
            const PantallaMedicamentos(),
            const PantallaRecetasPaciente(),
            const PantallaCitasPaciente(),
          ],
        ),
      ),
      bottomNavigationBar: ancho ? _construirNavegacionAncha() : _construirNavegacionMovil(),
    );
  }

  Widget _construirNavegacionAncha() {
    return NavigationBar(
      selectedIndex: _indiceSeleccionado,
      onDestinationSelected: (i) => setState(() => _indiceSeleccionado = i),
      destinations: [
        for (final item in _itemsNavegacion)
          NavigationDestination(icon: Icon(item.icono), selectedIcon: Icon(item.iconoSeleccionado), label: item.etiqueta),
      ],
    );
  }

  Widget _construirNavegacionMovil() {
    final indiceVisible = _pestanasMovil.indexOf(_indiceSeleccionado);
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: Colors.blue.shade100,
      selectedIndex: indiceVisible >= 0 ? indiceVisible : 0,
      onDestinationSelected: (i) => setState(() => _indiceSeleccionado = _pestanasMovil[i]),
      destinations: [
        for (final idx in _pestanasMovil)
          NavigationDestination(
            icon: Icon(_itemsNavegacion[idx].icono), 
            selectedIcon: Icon(_itemsNavegacion[idx].iconoSeleccionado, color: Colors.blue.shade700), 
            label: _itemsNavegacion[idx].etiqueta
          ),
      ],
    );
  }

  Widget _construirMenuLateral(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5)),
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(RepositorioApp.instancia.nombrePacienteActual, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
                  const SizedBox(height: 2),
                  Text('Paciente', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < _itemsNavegacion.length; i++)
              _ItemMenuLateral(
                icono: _itemsNavegacion[i].icono, etiqueta: _titulos[i], seleccionado: _indiceSeleccionado == i,
                alPresionar: () { setState(() => _indiceSeleccionado = i); Navigator.pop(context); },
              ),
            const Divider(),
            _ItemMenuLateral(icono: Icons.notifications_outlined, etiqueta: 'Notificaciones', alPresionar: () { Navigator.pop(context); _abrirNotificaciones(); }),
            _ItemMenuLateral(icono: Icons.settings_outlined, etiqueta: 'Configuracion', alPresionar: () { Navigator.pop(context); _abrirConfiguracion(); }),
            _ItemMenuLateral(icono: Icons.logout, etiqueta: 'Cerrar sesion', destructivo: true, alPresionar: () { Navigator.pop(context); _cerrarSesion(); }),
          ],
        ),
      ),
    );
  }
}

class _ItemNavegacion {
  final IconData icono;
  final IconData iconoSeleccionado;
  final String etiqueta;
  const _ItemNavegacion({required this.icono, required this.iconoSeleccionado, required this.etiqueta});
}

class _ItemMenuLateral extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool seleccionado;
  final bool destructivo;
  final VoidCallback alPresionar;

  const _ItemMenuLateral({required this.icono, required this.etiqueta, required this.alPresionar, this.seleccionado = false, this.destructivo = false});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final colorTexto = destructivo ? colores.danger : seleccionado ? colores.primary : colores.textPrimary;
    return ListTile(
      leading: Icon(icono, color: colorTexto),
      title: Text(etiqueta, style: TextStyle(color: colorTexto, fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500)),
      selected: seleccionado,
      selectedTileColor: colores.primary.withValues(alpha: 0.08),
      onTap: alPresionar,
    );
  }
}

// ============ NUEVO DASHBOARD DEL PACIENTE ============
class _PestanaInicioPacienteNuevo extends StatefulWidget {
  final Function(int) onCambiarPestana;

  const _PestanaInicioPacienteNuevo({required this.onCambiarPestana});

  @override
  State<_PestanaInicioPacienteNuevo> createState() => _EstadoPestanaInicioPacienteNuevo();
}

class _EstadoPestanaInicioPacienteNuevo extends State<_PestanaInicioPacienteNuevo> {
  List<RegistroSeguimiento> _seguimiento = [];
  List<dynamic> _citas = [];
  List<dynamic> _medicamentos = [];
  dynamic _pacienteData;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final id = RepositorioApp.instancia.idPacienteActual;
    final urlSeguimiento = Uri.parse('http://localhost:8080/api/seguimiento/paciente/$id');
    final urlCitas = Uri.parse('http://localhost:8080/api/citas/paciente/$id');
    final urlMedicamentos = Uri.parse('http://localhost:8080/api/medicamentos/paciente/$id');
    final urlPaciente = Uri.parse('http://localhost:8080/api/pacientes/$id');

    try {
      final res = await Future.wait([
        http.get(urlSeguimiento),
        http.get(urlCitas),
        http.get(urlMedicamentos),
        http.get(urlPaciente),
      ]);

      if (res[0].statusCode == 200) {
        final data = jsonDecode(res[0].body) as List;
        _seguimiento = data.map((j) => RegistroSeguimiento.fromJson(j)).toList();
      }
      if (res[1].statusCode == 200) _citas = jsonDecode(res[1].body);
      if (res[2].statusCode == 200) _medicamentos = jsonDecode(res[2].body);
      if (res[3].statusCode == 200) _pacienteData = jsonDecode(res[3].body);
    } catch (e) {
      debugPrint("Error al cargar dashboard: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _avatarPath() {
    if (_pacienteData != null) {
      final sexo = _pacienteData['sexo']?.toString().toLowerCase() ?? '';
      if (sexo.contains('femenino')) return 'assets/avatar_mujer.png';
    }
    return 'assets/avatar_hombre.png';
  }

  RegistroSeguimiento? _ultimoDeTipo(String tipo) {
    try {
      return _seguimiento.firstWhere((r) => r.tipo == tipo);
    } catch (_) {
      return null;
    }
  }

  dynamic _proximaCita() {
    final ahora = DateTime.now();
    try {
      return _citas.firstWhere((c) {
        if (c['estado'] != 'confirmada' || c['fechaHoraConfirmada'] == null) return false;
        return DateTime.parse(c['fechaHoraConfirmada']).isAfter(ahora);
      });
    } catch (_) {
      return null;
    }
  }

  int _medicamentosPendientesHoy() {
    int pendientes = 0;
    final hoy = DateTime.now();
    final fechaHoyStr = "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";

    for (final med in _medicamentos) {
      if (med['estado'] != 'activo') continue;
      final horarios = med['horarios'] as List;
      final historial = med['historialTomas'] as List;

      for (final h in horarios) {
        final horaStr = h['horaDia'];
        final yaTomada = historial.any((hist) => 
          hist['fechaProgramada'] == fechaHoyStr && 
          hist['horaProgramada'] == horaStr && 
          hist['estado'] == 'tomada'
        );
        if (!yaTomada) pendientes++;
      }
    }
    return pendientes;
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    final glucosa = _ultimoDeTipo('glucosa');
    final presion = _ultimoDeTipo('presion');
    final peso = _ultimoDeTipo('peso');
    final temperatura = _ultimoDeTipo('temperatura');
    final cita = _proximaCita();
    final medsPendientes = _medicamentosPendientesHoy();

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA DE BIENVENIDA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Hola, ${RepositorioApp.instancia.nombrePacienteActual.split(' ').first}!', 
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nos alegra tenerte de vuelta.', 
                          style: TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w600)
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Revisa tu salud y manten al dia tu tratamiento.', 
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B))
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 90,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                      image: DecorationImage(
                        image: AssetImage(_avatarPath()),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Image.asset(
                      _avatarPath(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. RESUMEN DE SALUD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tu resumen de salud', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                TextButton(
                  onPressed: () => widget.onCambiarPestana(2),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0,0)),
                  child: const Text('Ver seguimiento ->', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Cuadricula 2x2
            Row(
              children: [
                Expanded(child: _TarjetaMetricaGrid(titulo: 'Glucosa', valor: glucosa != null ? '${glucosa.valor} ${glucosa.unidad}' : '--', icono: Icons.water_drop_outlined, colorIcono: Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _TarjetaMetricaGrid(titulo: 'Presión arterial', valor: presion != null ? '${presion.valor} ${presion.unidad}' : '--', icono: Icons.favorite_border, colorIcono: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _TarjetaMetricaGrid(titulo: 'Peso', valor: peso != null ? '${peso.valor} ${peso.unidad}' : '--', icono: Icons.monitor_weight_outlined, colorIcono: Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _TarjetaMetricaGrid(titulo: 'Temperatura', valor: temperatura != null ? '${temperatura.valor} ${temperatura.unidad}' : '--', icono: Icons.thermostat_outlined, colorIcono: Colors.orange)),
              ],
            ),
            const SizedBox(height: 32),

            // 3. LO QUE TIENES PARA HOY
            const Text('Lo que tienes para hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            _TarjetaAccionHoy(
              icono: Icons.medication,
              colorIcono: Colors.blue,
              titulo: 'Medicamentos',
              subtitulo: 'Tienes tomas programadas para hoy.',
              badgeTexto: medsPendientes > 0 ? '$medsPendientes pendientes' : 'Completado',
              colorBadge: medsPendientes > 0 ? Colors.orange : Colors.green,
              textoBoton: 'Consultar tratamiento',
              alPresionar: () => widget.onCambiarPestana(3),
            ),
            const SizedBox(height: 12),

            if (cita != null)
              _TarjetaAccionHoy(
                icono: Icons.calendar_month,
                colorIcono: Colors.green,
                titulo: 'Próxima cita',
                subtitulo: 'Consulta medica con ${cita['medico']?['usuario']?['nombre'] ?? 'Medico'}.',
                badgeTexto: 'Programada',
                colorBadge: Colors.blue,
                textoBoton: 'Ver detalles',
                alPresionar: () => widget.onCambiarPestana(5),
              )
            else
              _TarjetaAccionHoy(
                icono: Icons.calendar_month,
                colorIcono: Colors.grey,
                titulo: 'Próxima cita',
                subtitulo: 'No tienes citas programadas por el momento.',
                badgeTexto: 'Sin citas',
                colorBadge: Colors.grey,
                textoBoton: 'Agendar cita',
                alPresionar: () => widget.onCambiarPestana(5),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ================= WIDGETS AUXILIARES =================

class _TarjetaMetricaGrid extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color colorIcono;

  const _TarjetaMetricaGrid({required this.titulo, required this.valor, required this.icono, required this.colorIcono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorIcono, size: 24),
          const SizedBox(height: 12),
          Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
            child: const Text('Último registro', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          )
        ],
      ),
    );
  }
}

class _TarjetaAccionHoy extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final String titulo;
  final String subtitulo;
  final String badgeTexto;
  final Color colorBadge;
  final String textoBoton;
  final VoidCallback alPresionar;

  const _TarjetaAccionHoy({
    required this.icono, required this.colorIcono, required this.titulo, required this.subtitulo,
    required this.badgeTexto, required this.colorBadge, required this.textoBoton, required this.alPresionar
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icono, color: colorIcono, size: 20),
                  const SizedBox(width: 8),
                  Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: colorBadge.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(badgeTexto, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorBadge)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitulo, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          TextButton(
            onPressed: alPresionar,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text('$textoBoton ->', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
          )
        ],
      ),
    );
  }
}