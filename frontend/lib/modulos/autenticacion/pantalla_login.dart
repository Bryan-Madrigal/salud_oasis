import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';
import 'pantalla_registro.dart';
import '../inicio_paciente/pantalla_inicio_paciente.dart';
import '../inicio_medico/pantalla_inicio_medico.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _EstadoPantallaLogin();
}

class _EstadoPantallaLogin extends State<PantallaLogin> {
  final _nombreController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final correo = _nombreController.text.trim();
    final contrasena = _contrasenaController.text;

    if (correo.isEmpty || contrasena.isEmpty) {
      _mostrarMensaje('Por favor completa todos los campos');
      return;
    }

    setState(() => _cargando = true);

    final url = Uri.parse('http://localhost:8080/api/auth/login'); 

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correo,
          "contrasena": contrasena,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rol = data['rol'];
        final String nombre = data['nombre'];
        
        final int idPerfil = data['idPerfil'] ?? 1; 

        if (rol == 'medico') {
          await RepositorioApp.instancia.establecerSesionMedico(nombre: nombre, id: idPerfil);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PantallaInicioMedico()),
          );
        } else {
          await RepositorioApp.instancia.establecerSesionPaciente(nombre: nombre, id: idPerfil);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PantallaInicioPaciente()),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        _mostrarMensaje(errorData['error'] ?? 'Error al iniciar sesion');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexion. El backend esta encendido?');
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO AQUI
                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Mi Salud Oasis',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colores.textPrimary,
                      letterSpacing: -0.8,
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
                  const SizedBox(height: AppSpacing.xxl),

                  TextField(
                    controller: _nombreController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electronico',
                      hintText: 'Ej. usuario@correo.com',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  TextField(
                    controller: _contrasenaController,
                    obscureText: _ocultarContrasena,
                    decoration: InputDecoration(
                      labelText: 'Contrasena',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(
                              () => _ocultarContrasena = !_ocultarContrasena);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _cargando ? null : _iniciarSesion,
                      child: _cargando 
                          ? const SizedBox(
                              width: 24, 
                              height: 24, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text('Iniciar sesion'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PantallaRegistro(),
                        ),
                      );
                    },
                    child: const Text('No tienes cuenta? Registrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}