import 'package:flutter/material.dart';
import '../../nucleo/datos/preferencias_onboarding.dart'; // Ruta corregida
import '../../nucleo/tema/tema_app.dart'; // Ruta corregida
import '../autenticacion/pantalla_login.dart'; // Ruta corregida

class PantallaBienvenida extends StatefulWidget {
  const PantallaBienvenida({super.key});

  @override
  State<PantallaBienvenida> createState() => _EstadoPantallaBienvenida();
}

class _EstadoPantallaBienvenida extends State<PantallaBienvenida> {
  final _controladorPaginas = PageController();
  int _paginaActual = 0;

  static const _paginas = [
    _PaginaBienvenida(
      icono: Icons.local_hospital,
      titulo: 'Bienvenido a Mi Salud Oasis',
      descripcion:
          'Tu refugio diario de salud.\nAquí llevarás el control de tus enfermedades crónicas.',
      color: Color(0xFF2A7A6C),
    ),
    _PaginaBienvenida(
      icono: Icons.show_chart,
      titulo: 'Monitorea tu salud',
      descripcion:
          'Registra tu glucosa, presión, peso y frecuencia cardíaca desde la comodidad de tu casa.',
      color: Color(0xFF3D8EE0),
    ),
    _PaginaBienvenida(
      icono: Icons.medical_services_outlined,
      titulo: 'Tu médico te acompaña',
      descripcion:
          'Tu doctor ve tu evolución en tiempo real y ajusta tu tratamiento cuando lo necesitas.',
      color: Color(0xFF3BAA7E),
    ),
    _PaginaBienvenida(
      icono: Icons.folder_shared_outlined,
      titulo: 'Todo en un solo lugar',
      descripcion:
          'Recetas, citas, medicamentos y recordatorios organizados para ti.',
      color: Color(0xFFE08A2A),
    ),
  ];

  @override
  void dispose() {
    _controladorPaginas.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_paginaActual < _paginas.length - 1) {
      _controladorPaginas.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finalizar();
    }
  }

  Future<void> _finalizar() async {
    // Asumiendo que renombraste el método en PreferenciasOnboarding
    await PreferenciasOnboarding.instancia.marcarComoVisto(); 
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const PantallaLogin(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final esUltima = _paginaActual == _paginas.length - 1;

    return Scaffold(
      backgroundColor: colores.background,
      body: SafeArea(
        child: Column(
          children: [
            // Saltar
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _finalizar,
                  child: Text(
                    'Saltar',
                    style: TextStyle(
                      color: colores.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Páginas deslizables
            Expanded(
              child: PageView.builder(
                controller: _controladorPaginas,
                onPageChanged: (i) => setState(() => _paginaActual = i),
                itemCount: _paginas.length,
                itemBuilder: (context, i) {
                  return _ContenidoPagina(pagina: _paginas[i]);
                },
              ),
            ),

            // Indicador de puntos
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _paginas.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    width: i == _paginaActual ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _paginaActual
                          ? colores.primary
                          : colores.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ),
              ),
            ),

            // Botón principal
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _siguiente,
                  icon: Icon(
                    esUltima ? Icons.check : Icons.arrow_forward,
                  ),
                  label: Text(
                    esUltima ? 'Comenzar' : 'Siguiente',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginaBienvenida {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;

  const _PaginaBienvenida({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
  });
}

class _ContenidoPagina extends StatelessWidget {
  final _PaginaBienvenida pagina;

  const _ContenidoPagina({required this.pagina});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono grande en círculo
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  pagina.color.withValues(alpha: 0.18),
                  pagina.color.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: pagina.color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              pagina.icono,
              size: 80,
              color: pagina.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          Text(
            pagina.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colores.textPrimary,
              letterSpacing: -0.3,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            pagina.descripcion,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: colores.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}