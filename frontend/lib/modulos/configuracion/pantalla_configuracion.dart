import 'package:flutter/material.dart';
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/datos/preferencias_onboarding.dart';
import '../../nucleo/tema/tema_app.dart';
import '../../nucleo/tema/controlador_tema.dart';
import '../acerca_de/pantalla_acerca_de.dart';
import '../autenticacion/pantalla_login.dart';

class PantallaConfiguracion extends StatefulWidget {
  final String nombreUsuario;
  final String rolUsuario;

  const PantallaConfiguracion({
    super.key,
    this.nombreUsuario = 'Juan Pérez',
    this.rolUsuario = 'Paciente',
  });

  @override
  State<PantallaConfiguracion> createState() => _EstadoPantallaConfiguracion();
}

class _EstadoPantallaConfiguracion extends State<PantallaConfiguracion> {
  bool _notifMedicamentos = true;
  bool _notifCitas = true;
  bool _notifAlertas = true;

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const _EtiquetaSeccion('Mi cuenta'),
            _Tarjeta(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              colores.primary.withValues(alpha: 0.12),
                          child: Text(
                            widget.nombreUsuario.substring(0, 1),
                            style: TextStyle(
                              color: colores.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nombreUsuario,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: colores.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                widget.rolUsuario,
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
                  ),
                  const Divider(height: 1),
                  _AccionLista(
                    icono: Icons.person_outline,
                    etiqueta: 'Editar datos personales',
                    alPresionar: () => _proximamente(context),
                  ),
                  const Divider(height: 1),
                  _AccionLista(
                    icono: Icons.lock_outline,
                    etiqueta: 'Cambiar contraseña',
                    alPresionar: () => _proximamente(context),
                  ),
                ],
              ),
            ),

            const _EtiquetaSeccion('Notificaciones'),
            _Tarjeta(
              child: Column(
                children: [
                  _InterruptorLista(
                    icono: Icons.medication_outlined,
                    etiqueta: 'Recordatorios de medicamentos',
                    valor: _notifMedicamentos,
                    alCambiar: (v) =>
                        setState(() => _notifMedicamentos = v),
                  ),
                  const Divider(height: 1),
                  _InterruptorLista(
                    icono: Icons.calendar_today_outlined,
                    etiqueta: 'Recordatorios de citas',
                    valor: _notifCitas,
                    alCambiar: (v) => setState(() => _notifCitas = v),
                  ),
                  const Divider(height: 1),
                  _InterruptorLista(
                    icono: Icons.warning_amber_outlined,
                    etiqueta: 'Alertas de salud',
                    valor: _notifAlertas,
                    alCambiar: (v) => setState(() => _notifAlertas = v),
                  ),
                ],
              ),
            ),

            const _EtiquetaSeccion('Preferencias'),
            _Tarjeta(
              child: Column(
                children: [
                  _AccionLista(
                    icono: Icons.text_fields,
                    etiqueta: 'Tamaño de letra',
                    valorFinal: 'Normal',
                    alPresionar: () => _proximamente(context),
                  ),
                  const Divider(height: 1),
                  ListenableBuilder(
                    listenable: ControladorTema.instancia,
                    builder: (context, _) {
                      final esOscuro = ControladorTema.instancia.esOscuro;
                      return _InterruptorLista(
                        icono: esOscuro
                            ? Icons.dark_mode
                            : Icons.light_mode_outlined,
                        etiqueta: 'Tema oscuro',
                        valor: esOscuro,
                        alCambiar: (v) =>
                            ControladorTema.instancia.alternar(v),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _AccionLista(
                    icono: Icons.language_outlined,
                    etiqueta: 'Idioma',
                    valorFinal: 'Español',
                    alPresionar: () => _proximamente(context),
                  ),
                ],
              ),
            ),

            const _EtiquetaSeccion('Sesión'),
            _Tarjeta(
              child: Column(
                children: [
                  _AccionLista(
                    icono: Icons.restart_alt,
                    etiqueta: 'Restablecer datos de demo',
                    alPresionar: () => _confirmarRestablecer(context),
                  ),
                  const Divider(height: 1),
                  _AccionLista(
                    icono: Icons.info_outline,
                    etiqueta: 'Acerca de Mi Salud Oasis',
                    alPresionar: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PantallaAcercaDe(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _AccionLista(
                    icono: Icons.logout,
                    etiqueta: 'Cerrar sesión',
                    destructivo: true,
                    alPresionar: () => _confirmarCerrarSesion(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                'Mi Salud Oasis · v0.1.0',
                style: TextStyle(
                  color: colores.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  Future<void> _confirmarRestablecer(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restablecer datos'),
        content: const Text(
          'Esto borrará todos los cambios que hayas hecho y volverá '
          'a los datos iniciales de demo.\n\n¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await RepositorioApp.instancia.restablecerDatosIniciales(); // Asumiendo el nombre traducido
      await PreferenciasOnboarding.instancia.resetear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Datos restablecidos. La bienvenida volverá a mostrarse.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
        (route) => false,
      );
    }
  }
}

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;

  const _EtiquetaSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: context.colors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final Widget child;

  const _Tarjeta({required this.child});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: child,
    );
  }
}

class _AccionLista extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String? valorFinal;
  final bool destructivo;
  final VoidCallback alPresionar;

  const _AccionLista({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
    this.valorFinal,
    this.destructivo = false,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final colorTexto = destructivo ? colores.danger : colores.textPrimary;
    final colorIcono = destructivo ? colores.danger : colores.primary;

    return ListTile(
      leading: Icon(icono, color: colorIcono),
      title: Text(
        etiqueta,
        style: TextStyle(
          color: colorTexto,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valorFinal != null)
            Text(
              valorFinal!,
              style: TextStyle(
                color: colores.textSecondary,
                fontSize: 13,
              ),
            ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right,
            color: colores.textTertiary,
            size: 20,
          ),
        ],
      ),
      onTap: alPresionar,
    );
  }
}

class _InterruptorLista extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool valor;
  final ValueChanged<bool> alCambiar;

  const _InterruptorLista({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icono, color: context.colors.primary),
      title: Text(
        etiqueta,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: valor,
      onChanged: alCambiar,
      activeThumbColor: context.colors.primary,
    );
  }
}