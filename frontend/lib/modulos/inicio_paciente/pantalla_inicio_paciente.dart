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
import '../notificaciones/pantalla_notificaciones.dart';
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
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaNotificaciones()));
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
        title: const Text('Cerrar sesion'),
        content: const Text('Seguro que deseas cerrar sesion?'),
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
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.teal.shade400, size: 24),
            const SizedBox(width: 8),
            Text(
              'Mi Salud Oasis',
              style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.black87),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            onPressed: _abrirNotificaciones,
          ),
          if (ancho) IconButton(icon: const Icon(Icons.settings_outlined), onPressed: _abrirConfiguracion),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _indiceSeleccionado,
          children: const [
            _PestanaInicioPacienteNuevo(),
            PantallaExpedientePaciente(),
            PantallaSeguimiento(),
            PantallaMedicamentos(),
            PantallaRecetasPaciente(),
            PantallaCitasPaciente(),
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
  const _PestanaInicioPacienteNuevo();

  @override
  State<_PestanaInicioPacienteNuevo> createState() => _EstadoPestanaInicioPacienteNuevo();
}

class _EstadoPestanaInicioPacienteNuevo extends State<_PestanaInicioPacienteNuevo> {
  List<RegistroSeguimiento> _seguimiento = [];
  List<dynamic> _citas = [];
  List<dynamic> _medicamentos = [];
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

    try {
      final res = await Future.wait([
        http.get(urlSeguimiento),
        http.get(urlCitas),
        http.get(urlMedicamentos),
      ]);

      if (res[0].statusCode == 200) {
        final data = jsonDecode(res[0].body) as List;
        _seguimiento = data.map((j) => RegistroSeguimiento.fromJson(j)).toList();
      }
      if (res[1].statusCode == 200) _citas = jsonDecode(res[1].body);
      if (res[2].statusCode == 200) _medicamentos = jsonDecode(res[2].body);
    } catch (e) {
      debugPrint("Error al cargar dashboard: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatearFecha(DateTime date) {
    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }

  // Logica para obtener el ultimo registro de un tipo
  RegistroSeguimiento? _ultimoRegistro(String tipo) {
    try {
      return _seguimiento.firstWhere((r) => r.tipo == tipo);
    } catch (_) {
      return null;
    }
  }

  // Logica para proxima cita
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

  // Logica para contar medicamentos pendientes hoy
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

    final glucosa = _ultimoRegistro('glucosa');
    final presion = _ultimoRegistro('presion');
    final peso = _ultimoRegistro('peso');
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
            // 1. HERO CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hola,', style: TextStyle(fontSize: 18, color: Color(0xFF0369A1))),
                      Text(
                        RepositorioApp.instancia.nombrePacienteActual.split(' ').first,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tu salud es lo mas importante.\nEstamos contigo en cada paso.', style: TextStyle(fontSize: 14, color: Color(0xFF475569))),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Color(0xFF0369A1)),
                            const SizedBox(width: 6),
                            Text('Hoy es ${_formatearFecha(DateTime.now())}', style: const TextStyle(fontSize: 12, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    ],
                  ),
                  // Simulacion de ilustracion
                  Positioned(
                    right: -10, bottom: -10,
                    child: Icon(Icons.person, size: 120, color: Colors.blue.shade300.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. RESUMEN DE SALUD
            const Text('Resumen de salud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TarjetaResumen(
                    titulo: 'Glucosa',
                    valor: glucosa != null ? '${glucosa.valor} ${glucosa.unidad}' : '--',
                    icono: Icons.water_drop,
                    colorIcono: Colors.purple,
                    colorFondo: const Color(0xFFF3E8FF),
                    estado: glucosa != null ? 'En rango' : 'Sin datos',
                  ),
                  const SizedBox(width: 12),
                  _TarjetaResumen(
                    titulo: 'Presion arterial',
                    valor: presion != null ? '${presion.valor} ${presion.unidad}' : '--',
                    icono: Icons.favorite,
                    colorIcono: Colors.red,
                    colorFondo: const Color(0xFFFEE2E2),
                    estado: presion != null ? 'Normal' : 'Sin datos',
                  ),
                  const SizedBox(width: 12),
                  _TarjetaResumen(
                    titulo: 'Peso',
                    valor: peso != null ? '${peso.valor} ${peso.unidad}' : '--',
                    icono: Icons.monitor_weight,
                    colorIcono: Colors.green,
                    colorFondo: const Color(0xFFDCFCE7),
                    estado: peso != null ? 'Normal' : 'Sin datos',
                  ),
                  const SizedBox(width: 12),
                  _TarjetaResumen(
                    titulo: 'Actividad',
                    valor: '0 pasos',
                    icono: Icons.directions_run,
                    colorIcono: Colors.blue,
                    colorFondo: const Color(0xFFDBEAFE),
                    estado: 'Hoy',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. PROXIMA CITA
            if (cita != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFFE0F2FE), shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_month, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PROXIMA CITA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(cita['motivo'] ?? 'Consulta general', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Text(cita['medico']?['usuario']?['nombre'] ?? 'Medico asignado', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(cita['fechaHoraConfirmada'].toString().substring(0, 10), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(width: 12),
                              const Icon(Icons.access_time, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(cita['fechaHoraConfirmada'].toString().substring(11, 16), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.blue),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 4. TU TRATAMIENTO
            const Text('Tu tratamiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                    child: const Icon(Icons.medication, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Tienes $medsPendientes medicamentos pendientes hoy', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. TU PROGRESO
            const Text('Tu progreso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Color(0xFFE9D5FF), shape: BoxShape.circle),
                    child: const Icon(Icons.bar_chart, color: Colors.purple),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Evolucion de tus indicadores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('Revisa como van tus resultados', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Ver grafico', style: TextStyle(color: Colors.purple)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String estado;

  const _TarjetaResumen({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colorFondo, shape: BoxShape.circle),
            child: Icon(icono, color: colorIcono, size: 20),
          ),
          const SizedBox(height: 16),
          Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(20)),
            child: Text(estado, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorIcono)),
          )
        ],
      ),
    );
  }
}