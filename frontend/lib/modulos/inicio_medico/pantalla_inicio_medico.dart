import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart'; // Asegúrate de que AppSpacing esté aquí
import '../pacientes/pantalla_lista_pacientes.dart';
import '../expediente/pantalla_expedientes_medico.dart';
import '../recetas/pantalla_recetas_medico.dart';
import '../citas/pantalla_citas_medico.dart';
import '../reportes/pantalla_reportes.dart';
import '../notificaciones/pantalla_notificaciones.dart';
import '../configuracion/pantalla_configuracion.dart';
import '../autenticacion/pantalla_login.dart';

class PantallaInicioMedico extends StatefulWidget {
  const PantallaInicioMedico({super.key});

  @override
  State<PantallaInicioMedico> createState() => _EstadoPantallaInicioMedico();
}

class _EstadoPantallaInicioMedico extends State<PantallaInicioMedico> {
  int _indiceSeleccionado = 0;

  static const _titulos = [
    'Inicio', 'Pacientes', 'Expedientes', 'Recetas', 'Citas', 'Reportes',
  ];

  static const _itemsNavegacion = [
    _ItemNavegacion(icono: Icons.home_outlined, iconoSeleccionado: Icons.home, etiqueta: 'Inicio'),
    _ItemNavegacion(icono: Icons.people_outline, iconoSeleccionado: Icons.people, etiqueta: 'Pacientes'),
    _ItemNavegacion(icono: Icons.folder_shared_outlined, iconoSeleccionado: Icons.folder_shared, etiqueta: 'Expedientes'),
    _ItemNavegacion(icono: Icons.receipt_long_outlined, iconoSeleccionado: Icons.receipt_long, etiqueta: 'Recetas'),
    _ItemNavegacion(icono: Icons.calendar_month_outlined, iconoSeleccionado: Icons.calendar_month, etiqueta: 'Citas'),
    _ItemNavegacion(icono: Icons.bar_chart_outlined, iconoSeleccionado: Icons.bar_chart, etiqueta: 'Reportes'),
  ];

  static const _pestanasMovil = [0, 1, 4, 5];

  bool _esAncho(BuildContext context) => MediaQuery.of(context).size.width >= 800;

  void _abrirNotificaciones() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const PantallaNotificaciones()));
  }

  void _abrirConfiguracion() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PantallaConfiguracion(
        nombreUsuario: RepositorioApp.instancia.nombreMedicoActual,
        rolUsuario: 'Medico',
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
      // APP BAR CON EL LOGO EXACTO AL DEL PACIENTE
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
        child: Row(
          children: [
            if (ancho)
              Container(
                width: 250,
                color: Colors.white,
                child: _construirMenuLateral(context, esFijo: true),
              ),
            Expanded(
              child: IndexedStack(
                index: _indiceSeleccionado,
                children: [
                  _PestanaInicioMedico(onCambiarPestana: (index) => setState(() => _indiceSeleccionado = index)),
                  const PantallaListaPacientes(),
                  const PantallaExpedientesMedico(),
                  const PantallaRecetasMedico(),
                  const PantallaCitasMedico(),
                  const PantallaReportes(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ancho ? null : _construirNavegacionMovil(),
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

  // MENÚ LATERAL EXACTAMENTE IGUAL AL DEL PACIENTE (DEGRADADO)
  Widget _construirMenuLateral(BuildContext context, {bool esFijo = false}) {
    Widget contenido = Column(
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
              Text(RepositorioApp.instancia.nombreMedicoActual, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text('Medico', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (int i = 0; i < _itemsNavegacion.length; i++)
          _ItemMenuLateral(
            icono: _itemsNavegacion[i].icono,
            etiqueta: _titulos[i],
            seleccionado: _indiceSeleccionado == i,
            alPresionar: () {
              setState(() => _indiceSeleccionado = i);
              if (!esFijo) Navigator.pop(context);
            },
          ),
        const Divider(),
        _ItemMenuLateral(icono: Icons.notifications_outlined, etiqueta: 'Notificaciones', alPresionar: () { if (!esFijo) Navigator.pop(context); _abrirNotificaciones(); }),
        _ItemMenuLateral(icono: Icons.settings_outlined, etiqueta: 'Configuracion', alPresionar: () { if (!esFijo) Navigator.pop(context); _abrirConfiguracion(); }),
        _ItemMenuLateral(icono: Icons.logout, etiqueta: 'Cerrar sesion', destructivo: true, alPresionar: () { if (!esFijo) Navigator.pop(context); _cerrarSesion(); }),
      ],
    );

    if (esFijo) return contenido;

    return Drawer(
      child: SafeArea(child: contenido),
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

// ==========================================
// PESTAÑA DE INICIO (CON LÓGICA DE AVATAR)
// ==========================================
class _PestanaInicioMedico extends StatefulWidget {
  final Function(int) onCambiarPestana;
  const _PestanaInicioMedico({required this.onCambiarPestana});

  @override
  State<_PestanaInicioMedico> createState() => _EstadoPestanaInicioMedico();
}

class _EstadoPestanaInicioMedico extends State<_PestanaInicioMedico> {
  List<dynamic> _citasReales = [];
  List<dynamic> _pacientesReales = [];
  dynamic _medicoData; // Variable para guardar los datos del médico
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final idMedico = RepositorioApp.instancia.idMedicoActual;
    final urlCitas = Uri.parse('http://localhost:8080/api/citas/medico/$idMedico');
    final urlPacientes = Uri.parse('http://localhost:8080/api/pacientes');
    final urlMedico = Uri.parse('http://localhost:8080/api/medicos/$idMedico'); // Endpoint para el médico

    try {
      final respuestas = await Future.wait([
        http.get(urlCitas), 
        http.get(urlPacientes),
        http.get(urlMedico)
      ]);
      
      if (respuestas[0].statusCode == 200) _citasReales = jsonDecode(respuestas[0].body);
      if (respuestas[1].statusCode == 200) _pacientesReales = jsonDecode(respuestas[1].body);
      if (respuestas[2].statusCode == 200) _medicoData = jsonDecode(respuestas[2].body);
      
      setState(() {});
    } catch (e) {
      debugPrint("Error al cargar datos del medico: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // LÓGICA EXACTA DEL PACIENTE ADAPTADA AL MÉDICO
  String _avatarPath() {
    if (_medicoData != null) {
      final sexo = _medicoData['sexo']?.toString().toLowerCase() ?? '';
      if (sexo.contains('femenino') || sexo.contains('mujer')) {
        return 'assets/avatar_doctora.png';
      }
    }
    return 'assets/avatar_medico.png';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    final ahora = DateTime.now();
    
    final citasHoy = _citasReales.where((c) {
      if (c['estado'] != 'confirmada' || c['fechaHoraConfirmada'] == null) return false;
      final fecha = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
      return fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day;
    }).toList()
      ..sort((a, b) => DateTime.parse(a['fechaHoraConfirmada']).compareTo(DateTime.parse(b['fechaHoraConfirmada'])));

    final pendientes = _citasReales.where((c) => c['estado'] == 'pendiente').toList();
    final atendidos = citasHoy.length > 5 ? 5 : 2; 

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TARJETA DE BIENVENIDA (IDÉNTICA ESTRUCTURA A LA DEL PACIENTE)
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BIENVENIDO DE NUEVO',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0284C7), letterSpacing: 1.2),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dr. ${RepositorioApp.instancia.nombreMedicoActual}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Médico Familiar',
                              style: TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // CONTENEDOR DE AVATAR TAL CUAL EL DEL PACIENTE
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${citasHoy.length}',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const Text(
                              'Consultas de hoy',
                              style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0284C7), size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. RESUMEN DE ACTIVIDAD
            const Text(
              'Resumen de actividad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _EstadisticaHorizontal(icono: Icons.people_outline, valor: '${_pacientesReales.length}', titulo: 'Pacientes'),
                _EstadisticaHorizontal(icono: Icons.check_circle_outline, valor: '$atendidos', titulo: 'Atendidos'),
                _EstadisticaHorizontal(icono: Icons.access_time, valor: '${pendientes.length}', titulo: 'Pendientes'),
              ],
            ),
            const SizedBox(height: 24),

            // 3. PRÓXIMAS CONSULTAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Próximas consultas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                TextButton(
                  onPressed: () => widget.onCambiarPestana(4), 
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0,0)),
                  child: const Text('Ver todas ->', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (citasHoy.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No hay consultas para hoy', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...citasHoy.take(3).map((cita) => _TarjetaProximaConsulta(cita: cita)),

            const SizedBox(height: 24),

            // 4. FOOTER (Agenda médica)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF0284C7), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agenda médica', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        const Text('Consulta tus próximas citas y organiza tus horarios.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGETS AUXILIARES DEL DASHBOARD
// ==========================================

class _EstadisticaHorizontal extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String titulo;

  const _EstadisticaHorizontal({required this.icono, required this.valor, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, color: const Color(0xFF0284C7), size: 22),
        const SizedBox(height: 8),
        Text(valor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 2),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TarjetaProximaConsulta extends StatelessWidget {
  final dynamic cita;
  const _TarjetaProximaConsulta({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.parse(cita['fechaHoraConfirmada']).toLocal();
    final horaStr = '${fecha.hour > 12 ? fecha.hour - 12 : (fecha.hour == 0 ? 12 : fecha.hour)}:${fecha.minute.toString().padLeft(2, '0')} ${fecha.hour >= 12 ? 'PM' : 'AM'}';
    
    final nombrePaciente = cita['paciente']?['usuario']?['nombre'] ?? 'Paciente';
    final motivo = cita['motivo'] ?? 'Consulta general';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: Color(0xFF64748B), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombrePaciente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(motivo, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              horaStr,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}