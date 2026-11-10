import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/tema/tema_app.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LOGO AQUI
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(
                'Unete a Mi Salud Oasis',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colores.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Crea tu cuenta para comenzar',
                textAlign: TextAlign.center,
                style: TextStyle(color: colores.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),

              TextField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electronico',
                  prefixIcon: Icon(Icons.email_outlined),
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
                    icon: Icon(_ocultarContrasena
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _ocultarContrasena = !_ocultarContrasena);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _confirmarContrasenaController,
                obscureText: _ocultarConfirmacion,
                decoration: InputDecoration(
                  labelText: 'Confirmar contrasena',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarConfirmacion
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() => _ocultarConfirmacion = !_ocultarConfirmacion);
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _cargando ? null : _registrar,
                  child: _cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ya tienes cuenta? Inicia sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;
    final confirmacion = _confirmarContrasenaController.text;

    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      _mostrarMensaje('Por favor completa todos los campos');
      return;
    }
    if (contrasena.length < 6) {
      _mostrarMensaje('La contrasena debe tener al menos 6 caracteres');
      return;
    }
    if (contrasena != confirmacion) {
      _mostrarMensaje('Las contrasenas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    final url = Uri.parse('http://localhost:8080/api/auth/registro');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "correo": correo,
          "contrasena": contrasena,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _mostrarMensaje('Registro exitoso! Ya puedes iniciar sesion');
        Navigator.pop(context); 
      } else {
        final errorData = jsonDecode(response.body);
        _mostrarMensaje(errorData['error'] ?? 'Error al registrarse');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexion. Revisa si el servidor esta encendido.');
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
}