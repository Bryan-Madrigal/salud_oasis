import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
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
    'Mi Salud Oasis', 'Pacientes', 'Expedientes', 'Recetas', 'Citas', 'Reportes',
  ];

  static const _itemsNavegacion = [
    _ItemNavegacion(icono: Icons.home_outlined, iconoSeleccionado: Icons.home, etiqueta: 'Inicio'),
    _ItemNavegacion(icono: Icons.people_outline, iconoSeleccionado: Icons.people, etiqueta: 'Pacientes'),
    _ItemNavegacion(icono: Icons.folder_shared_outlined, iconoSeleccionado: Icons.folder_shared, etiqueta: 'Exped.'),
    _ItemNavegacion(icono: Icons.receipt_long_outlined, iconoSeleccionado: Icons.receipt_long, etiqueta: 'Recetas'),
    _ItemNavegacion(icono: Icons.calendar_month_outlined, iconoSeleccionado: Icons.calendar_month, etiqueta: 'Citas'),
    _ItemNavegacion(icono: Icons.bar_chart_outlined, iconoSeleccionado: Icons.bar_chart, etiqueta: 'Reportes'),
  ];

  static const _pestanasMovil = [0, 1, 4, 5];

  bool _esAncho(BuildContext context) => MediaQuery.of(context).size.width >= 700;

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
      backgroundColor: const Color(0xFFF8FAFC), // Fondo gris muy claro
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
            _PestanaInicioMedico(),
            PantallaListaPacientes(),
            PantallaExpedientesMedico(),
            PantallaRecetasMedico(),
            PantallaCitasMedico(),
            PantallaReportes(),
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
    final colores = context.colors;
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: colores.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.medical_services_outlined, color: Colors.white, size: 32)),
                  const SizedBox(height: 12),
                  Text(RepositorioApp.instancia.nombreMedicoActual, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Medico', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
      title: Text(etiqueta, style: TextStyle(color: colorTexto, fontWeight: seleccionado ? FontWeight.bold : FontWeight.w500)),
      selected: seleccionado,
      selectedTileColor: colores.primary.withValues(alpha: 0.08),
      onTap: alPresionar,
    );
  }
}

// ============ Pestana de Inicio del medico (NUEVO DISEÑO PREMIUM) ============
class _PestanaInicioMedico extends StatefulWidget {
  const _PestanaInicioMedico();

  @override
  State<_PestanaInicioMedico> createState() => _EstadoPestanaInicioMedico();
}

class _EstadoPestanaInicioMedico extends State<_PestanaInicioMedico> {
  List<dynamic> _citasReales = [];
  List<dynamic> _pacientesReales = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final urlCitas = Uri.parse('http://localhost:8080/api/citas/medico/${RepositorioApp.instancia.idMedicoActual}');
    final urlPacientes = Uri.parse('http://localhost:8080/api/pacientes');

    try {
      final respuestas = await Future.wait([
        http.get(urlCitas),
        http.get(urlPacientes),
      ]);

      if (respuestas[0].statusCode == 200) _citasReales = jsonDecode(respuestas[0].body);
      if (respuestas[1].statusCode == 200) _pacientesReales = jsonDecode(respuestas[1].body);
      setState(() {});
    } catch (e) {
      debugPrint("Error al cargar datos del medico: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _formatearFecha() {
    final meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    final ahora = DateTime.now();
    return '${ahora.day} de ${meses[ahora.month - 1]} de ${ahora.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Calculos de las citas
    final ahora = DateTime.now();
    
    // Citas de hoy (confirmadas)
    final citasHoy = _citasReales.where((c) {
      if (c['estado'] != 'confirmada' || c['fechaHoraConfirmada'] == null) return false;
      final fecha = DateTime.parse(c['fechaHoraConfirmada']).toLocal();
      return fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day;
    }).toList();

    // Solicitudes pendientes
    final pendientes = _citasReales.where((c) => c['estado'] == 'pendiente').length;

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO SECTION (Fondo celeste con ilustracion)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFE0F2FE), // Celeste muy claro
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${RepositorioApp.instancia.nombreMedicoActual}',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu labor tambien hace\nla diferencia.',
                        style: TextStyle(fontSize: 16, color: Colors.blue.shade800, height: 1.3),
                      ),
                    ],
                  ),
                  // Ilustracion del doctor (Simulada con un icono grande)
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(Icons.person_pin, size: 120, color: Colors.blue.shade300.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. RESUMEN DE HOY (Titulo y Fecha)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resumen de hoy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(_formatearFecha(), style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. GRID DE TARJETAS
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Pacientes atendidos',
                          valor: _cargando ? '...' : '${_pacientesReales.length}',
                          icono: Icons.people_outline,
                          colorFondo: const Color(0xFFEFF6FF), // Azul claro
                          colorIcono: const Color(0xFF3B82F6), // Azul fuerte
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Citas de hoy',
                          valor: _cargando ? '...' : '${citasHoy.length}',
                          icono: Icons.calendar_today_outlined,
                          colorFondo: const Color(0xFFECFDF5), // Verde claro
                          colorIcono: const Color(0xFF10B981), // Verde fuerte
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Pendientes por atender',
                          valor: _cargando ? '...' : '$pendientes',
                          icono: Icons.access_time,
                          colorFondo: const Color(0xFFFFFBEB), // Amarillo claro
                          colorIcono: const Color(0xFFF59E0B), // Amarillo fuerte
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Seguimientos pendientes',
                          valor: '0', // Puedes cambiarlo por datos reales despues
                          icono: Icons.warning_amber_rounded,
                          colorFondo: const Color(0xFFFEF2F2), // Rojo claro
                          colorIcono: const Color(0xFFEF4444), // Rojo fuerte
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. LISTA DE CITAS DE HOY
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header de la lista
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFF3B82F6), size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Citas de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Text('Ver todas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14, color: Color(0xFF3B82F6)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        
                        // Items de las citas
                        if (citasHoy.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text('No hay citas programadas para hoy.', style: TextStyle(color: Colors.grey.shade500)),
                          )
                        else
                          for (int i = 0; i < citasHoy.length; i++) ...[
                            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            _FilaCitaHoy(cita: citasHoy[i]),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET: Tarjeta de metrica 2x2
class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorIcono.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorIcono.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, color: colorIcono, size: 22),
              ),
              Icon(Icons.chevron_right, color: colorIcono.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }
}

// WIDGET: Fila de cita (Hora, Avatar, Nombre, Tipo)
class _FilaCitaHoy extends StatelessWidget {
  final dynamic cita;
  const _FilaCitaHoy({required this.cita});

  @override
  Widget build(BuildContext context) {
    final fecha = DateTime.parse(cita['fechaHoraConfirmada']).toLocal();
    final horaStr = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    final nombre = cita['paciente']?['usuario']?['nombre'] ?? 'Paciente';
    final motivo = cita['motivo'] ?? 'Consulta general';

    // Colores aleatorios para los avatares
    final coloresAvatar = [const Color(0xFFE0F2FE), const Color(0xFFECFDF5), const Color(0xFFF3E8FF)];
    final coloresIcono = [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFA855F7)];
    final idx = nombre.length % 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(horaStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
          ),
          CircleAvatar(
            backgroundColor: coloresAvatar[idx],
            radius: 18,
            child: Icon(Icons.person, color: coloresIcono[idx], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                Text(motivo, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}