import 'package:flutter/material.dart';
import 'nucleo/tema/tema_app.dart';
import 'nucleo/tema/controlador_tema.dart';
import 'modulos/splash/pantalla_splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ControladorTema.instancia.inicializar();
  runApp(const AplicacionMiSaludOasis());
}

class AplicacionMiSaludOasis extends StatelessWidget {
  const AplicacionMiSaludOasis({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ControladorTema.instancia,
      builder: (context, _) {
        return MaterialApp(
          title: 'Mi Salud Oasis',
          debugShowCheckedModeBanner: false,
          theme: TemaApp.claro,
          darkTheme: TemaApp.oscuro,
          themeMode: ControladorTema.instancia.esOscuro
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const PantallaSplash(), // <-- Aquí estaba el error si faltaba esta coma
        );
      },
    );
  }
}