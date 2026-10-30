import 'package:flutter/material.dart';
import '../../nucleo/tema/tema_app.dart';

class PantallaAcercaDe extends StatelessWidget {
  const PantallaAcercaDe({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors; // Asumiendo que tu extensión se llama colors

    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            // Logo + nombre
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colores.primary.withValues(alpha: 0.2),
                          colores.primary.withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colores.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: 48,
                      color: colores.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Mi Salud Oasis',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colores.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tu refugio diario de salud',
                    style: TextStyle(
                      fontSize: 14,
                      color: colores.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colores.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'Versión 0.1.0',
                      style: TextStyle(
                        color: colores.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Misión
            _TarjetaInfo(
              icono: Icons.favorite_outline,
              titulo: 'Nuestra misión',
              cuerpo:
                  'Mi Salud Oasis ayuda a pacientes con enfermedades crónicas a '
                  'monitorear su salud desde casa y mantenerse conectados '
                  'con su médico tratante.',
            ),
            const SizedBox(height: AppSpacing.md),

            // Cómo funciona
            _TarjetaInfo(
              icono: Icons.info_outline,
              titulo: 'Cómo funciona',
              cuerpo:
                  'Registra tus mediciones diarias (glucosa, presión, peso), '
                  'sigue tu tratamiento y comparte tu evolución con tu '
                  'médico en tiempo real.',
            ),
            const SizedBox(height: AppSpacing.xl),

            // Sección legal
            const _EtiquetaSeccion('Legal'),
            _TarjetaContenedora(
              child: Column(
                children: [
                  _EnlaceLista(
                    icono: Icons.privacy_tip_outlined,
                    etiqueta: 'Aviso de privacidad',
                    alPresionar: () => _abrirPrivacidad(context),
                  ),
                  const Divider(height: 1),
                  _EnlaceLista(
                    icono: Icons.description_outlined,
                    etiqueta: 'Términos y condiciones',
                    alPresionar: () => _abrirTerminos(context),
                  ),
                  const Divider(height: 1),
                  _EnlaceLista(
                    icono: Icons.gavel_outlined,
                    etiqueta: 'Aviso médico',
                    alPresionar: () => _abrirAvisoMedico(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Contacto
            const _EtiquetaSeccion('Contacto'),
            _TarjetaContenedora(
              child: Column(
                children: [
                  _EnlaceLista(
                    icono: Icons.email_outlined,
                    etiqueta: 'soporte@misaludoasis.app',
                    alPresionar: () => _mostrarContacto(context, 'soporte@misaludoasis.app'),
                  ),
                  const Divider(height: 1),
                  _EnlaceLista(
                    icono: Icons.language_outlined,
                    etiqueta: 'www.misaludoasis.app',
                    alPresionar: () => _mostrarContacto(context, 'www.misaludoasis.app'),
                  ),
                  const Divider(height: 1),
                  _EnlaceLista(
                    icono: Icons.share_outlined,
                    etiqueta: 'Compartir Mi Salud Oasis',
                    alPresionar: () => _mostrarContacto(context, 'Compartir (próximamente)'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Hecho en México',
                    style: TextStyle(
                      fontSize: 12,
                      color: colores.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '© 2026 Mi Salud Oasis',
                    style: TextStyle(
                      fontSize: 11,
                      color: colores.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _abrirPrivacidad(BuildContext context) {
    _mostrarDialogoDocumento(
      context,
      titulo: 'Aviso de privacidad',
      cuerpo: 'En Mi Salud Oasis protegemos tus datos de salud con estrictos '
          'estándares de seguridad. Tu información clínica solo es '
          'accesible por ti y por los médicos que autorices.\n\n'
          'No compartimos tus datos con terceros sin tu consentimiento '
          'expreso. Puedes solicitar la eliminación de tu cuenta y datos '
          'en cualquier momento desde Configuración.',
    );
  }

  void _abrirTerminos(BuildContext context) {
    _mostrarDialogoDocumento(
      context,
      titulo: 'Términos y condiciones',
      cuerpo: 'El uso de Mi Salud Oasis implica la aceptación de estos términos. '
          'La aplicación es una herramienta de apoyo y NO sustituye la '
          'consulta médica profesional.\n\n'
          'No nos hacemos responsables por decisiones clínicas tomadas '
          'con base únicamente en la información mostrada en la app.',
    );
  }

  void _abrirAvisoMedico(BuildContext context) {
    _mostrarDialogoDocumento(
      context,
      titulo: 'Aviso médico',
      cuerpo: 'La información proporcionada por Mi Salud Oasis tiene fines '
          'informativos y de seguimiento personal.\n\n'
          'NO es un diagnóstico médico. Si tienes síntomas graves o '
          'emergencias, acude de inmediato a servicios de urgencia.\n\n'
          'Siempre consulta a un profesional de la salud antes de tomar '
          'decisiones sobre tu tratamiento.',
    );
  }

  void _mostrarDialogoDocumento(
    BuildContext context, {
    required String titulo,
    required String cuerpo,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: SingleChildScrollView(
          child: Text(
            cuerpo,
            style: const TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarContacto(BuildContext context, String info) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(info)),
    );
  }
}

class _EtiquetaSeccion extends StatelessWidget {
  final String texto;

  const _EtiquetaSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
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

class _TarjetaContenedora extends StatelessWidget {
  final Widget child;

  const _TarjetaContenedora({required this.child});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: child,
    );
  }
}

class _TarjetaInfo extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String cuerpo;

  const _TarjetaInfo({
    required this.icono,
    required this.titulo,
    required this.cuerpo,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colores.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icono, color: colores.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colores.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  cuerpo,
                  style: TextStyle(
                    fontSize: 13,
                    color: colores.textSecondary,
                    height: 1.5,
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

class _EnlaceLista extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback alPresionar;

  const _EnlaceLista({
    required this.icono,
    required this.etiqueta,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return ListTile(
      leading: Icon(icono, color: colores.primary),
      title: Text(
        etiqueta,
        style: TextStyle(
          color: colores.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colores.textTertiary,
        size: 20,
      ),
      onTap: alPresionar, // onTap es una propiedad de Flutter, se queda en inglés
    );
  }
}