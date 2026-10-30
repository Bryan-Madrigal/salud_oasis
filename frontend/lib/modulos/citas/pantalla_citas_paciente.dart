import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';
import 'pantalla_formulario_cita.dart';
import 'modelos/cita.dart';

class PantallaCitasPaciente extends StatefulWidget {
  const PantallaCitasPaciente({super.key});

  @override
  State<PantallaCitasPaciente> createState() => _EstadoPantallaCitasPaciente();
}

class _EstadoPantallaCitasPaciente extends State<PantallaCitasPaciente> {
  List<Cita> _citas = [];
  bool _cargando = true;
  bool _errorConexion = false; // Para mostrar un botón de reintentar

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() {
      _cargando = true;
      _errorConexion = false;
    });

    // ⚠️ RECUERDA: Si estás en emulador Android cambia 'localhost' por '10.0.2.2'
    final url = Uri.parse('http://localhost:8080/api/citas/paciente/1'); 
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _citas = data.map((json) => Cita.fromJson(json)).toList();
        });
      } else {
        print("Error del servidor: ${response.statusCode} - ${response.body}");
        setState(() => _errorConexion = true);
      }
    } catch (e) {
      print("Error de red: $e");
      setState(() => _errorConexion = true);
    } finally {
      // ¡Pase lo que pase, apagamos el spinner!
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _abrirFormulario(BuildContext context) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PantallaFormularioCita(),
      ),
    );
    
    // Si el formulario devuelve 'true' (se guardó con éxito), recargamos la lista
    if (resultado == true) {
      _cargarCitas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    // 1. Estado de carga
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de error
    if (_errorConexion) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: colores.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Error de conexión con el servidor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colores.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Revisa que el backend esté encendido',
              style: TextStyle(color: colores.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _cargarCitas,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // 3. Filtros de citas
    final pendientes = _citas.where((c) => c.estaPendiente).toList()
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

    final proximas = _citas.where((c) => c.estaConfirmada && c.esFutura).toList()
      ..sort((a, b) => a.fechaHoraEfectiva.compareTo(b.fechaHoraEfectiva));

    final historial = _citas
        .where((c) => c.estaCompletada || c.estaCancelada || (c.estaConfirmada && !c.esFutura))
        .toList()
      ..sort((a, b) => b.fechaHoraEfectiva.compareTo(a.fechaHoraEfectiva));

    // 4. Interfaz normal
    return RefreshIndicator(
      onRefresh: _cargarCitas, // Deslizar hacia abajo para recargar
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis citas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colores.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Solicita y consulta tus citas médicas',
              style: TextStyle(color: colores.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _abrirFormulario(context),
                icon: const Icon(Icons.add),
                label: const Text('Solicitar nueva cita'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (pendientes.isNotEmpty) ...[
              _EtiquetaSeccion(
                texto: 'Solicitudes en revisión',
                cantidad: pendientes.length,
                color: colores.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final cita in pendientes) _TarjetaPendiente(cita: cita),
              const SizedBox(height: AppSpacing.xl),
            ],

            if (proximas.isNotEmpty) ...[
              _EtiquetaSeccion(
                texto: 'Próximas citas',
                cantidad: proximas.length,
                color: colores.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final cita in proximas) _TarjetaConfirmada(cita: cita),
              const SizedBox(height: AppSpacing.xl),
            ],

            if (historial.isNotEmpty) ...[
              _EtiquetaSeccion(
                texto: 'Historial',
                cantidad: historial.length,
                color: colores.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              for (final cita in historial) _TarjetaHistorial(cita: cita),
            ],

            if (pendientes.isEmpty && proximas.isEmpty && historial.isEmpty)
              const _EstadoVacio(
                icono: Icons.event_outlined,
                texto: 'Aún no tienes citas',
                subtitulo: 'Solicita una cita para comenzar',
              ),
          ],
        ),
      ),
    );
  }
}

// ============ WIDGETS DE DISEÑO ============

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;
  final int cantidad;
  final Color color;

  const _EtiquetaSeccion({
    required this.texto,
    required this.cantidad,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Row(
      children: [
        Text(
          texto,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colores.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            '$cantidad',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaPendiente extends StatelessWidget {
  final Cita cita;

  const _TarjetaPendiente({required this.cita});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
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
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colores.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.hourglass_top_outlined,
                  color: colores.warning,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitud en revisión',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colores.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cita.tipo,
                      style: TextStyle(
                        color: colores.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _FilaInfo(
            icono: Icons.calendar_today_outlined,
            etiqueta: 'Fecha preferida',
            valor: '${cita.fechaPreferidaFormateada} · ${cita.horarioPreferido.etiqueta}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _FilaInfo(
            icono: Icons.description_outlined,
            etiqueta: 'Motivo',
            valor: cita.motivo,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colores.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: colores.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Estamos buscando un médico disponible. Te avisaremos cuando sea confirmada.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colores.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaConfirmada extends StatelessWidget {
  final Cita cita;

  const _TarjetaConfirmada({required this.cita});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${cita.fechaFormateada} · ${cita.horaFormateada}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cita.nombreMedico ?? 'Médico asignado',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            cita.motivo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          if (cita.duracionMinutos != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Duración: ${cita.duracionMinutos} min',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
          if (cita.notasMedico != null && cita.notasMedico!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                cita.notasMedico!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaHistorial extends StatelessWidget {
  final Cita cita;

  const _TarjetaHistorial({required this.cita});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final estaCancelada = cita.estaCancelada;
    final colorEstado = estaCancelada ? colores.danger : colores.info;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              estaCancelada ? Icons.cancel_outlined : Icons.check_circle_outline,
              color: colorEstado,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cita.motivo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colores.textPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cita.fechaFormateada} · ${cita.nombreMedico ?? "Sin asignar"}',
                  style: TextStyle(
                    color: colores.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: colorEstado.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              cita.estado.etiqueta,
              style: TextStyle(
                color: colorEstado,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _FilaInfo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 14, color: colores.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$etiqueta: ',
          style: TextStyle(
            fontSize: 13,
            color: colores.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 13,
              color: colores.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String texto;
  final String subtitulo;

  const _EstadoVacio({
    required this.icono,
    required this.texto,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(icono, size: 64, color: colores.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              texto,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colores.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitulo,
              style: TextStyle(color: colores.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}