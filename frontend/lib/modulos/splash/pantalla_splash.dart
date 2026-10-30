import 'package:flutter/material.dart';
import '../../nucleo/datos/repositorio_app.dart';
import '../autenticacion/pantalla_login.dart';

class PantallaSplash extends StatefulWidget {
  const PantallaSplash({super.key});

  @override
  State<PantallaSplash> createState() => _EstadoPantallaSplash();
}

class _EstadoPantallaSplash extends State<PantallaSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controladorAnimacion;
  late final Animation<double> _desvanecimiento;
  late final Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _desvanecimiento = CurvedAnimation(
      parent: _controladorAnimacion, 
      curve: Curves.easeOut,
    );
    _escala = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorAnimacion, 
        curve: Curves.easeOutBack,
      ),
    );
    _controladorAnimacion.forward();
    _iniciar();
  }

  Future<void> _iniciar() async {
    // Inicializamos el repositorio local
    await RepositorioApp.instancia.inicializar();
    
    // Esperamos un momento para que se aprecie la animación
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Vamos directo al Login, sin pasar por la bienvenida
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const PantallaLogin(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Círculo decorativo superior
            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Círculo decorativo inferior
            Positioned(
              bottom: -120,
              left: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Contenido
            Center(
              child: FadeTransition(
                opacity: _desvanecimiento,
                child: ScaleTransition(
                  scale: _escala,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Mi Salud Oasis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu refugio diario de salud',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
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