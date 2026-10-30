import 'package:flutter/material.dart';
import 'dart:convert'; // <-- NUEVO: Para manejar el JSON
import 'package:http/http.dart' as http; // <-- NUEVO: Para hacer peticiones de red
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

  // Eliminamos _rolSeleccionado porque el backend lo calculará
  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false; // <-- NUEVO: Para el indicador de carga

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
              Icon(
                Icons.local_hospital,
                size: 56,
                color: colores.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Únete a Mi Salud Oasis',
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

              // ELIMINADO: El SegmentedButton (Selector de Paciente/Médico)

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
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              TextField(
                controller: _contrasenaController,
                obscureText: _ocultarContrasena,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
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
                  labelText: 'Confirmar contraseña',
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
                  // Desactivamos el botón si está cargando
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
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Agregamos 'Future' y 'async' porque ahora haremos una petición de red
  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final contrasena = _contrasenaController.text;
    final confirmacion = _confirmarContrasenaController.text;

    // Validaciones del frontend (tus validaciones originales)
    if (nombre.isEmpty || correo.isEmpty || contrasena.isEmpty) {
      _mostrarMensaje('Por favor completa todos los campos');
      return;
    }
    if (contrasena.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (contrasena != confirmacion) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    // ⚠️ IMPORTANTE: 
    // En Emulador Android usa 'http://10.0.2.2:8080/api/auth/registro'
    // En Flutter Web usa 'http://localhost:8080/api/auth/registro'
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
        // Registro exitoso
        _mostrarMensaje('¡Registro exitoso! Ya puedes iniciar sesión');
        Navigator.pop(context); // Regresa a la pantalla de Login
      } else {
        // Error del backend (ej. correo duplicado)
        final errorData = jsonDecode(response.body);
        _mostrarMensaje(errorData['error'] ?? 'Error al registrarse');
      }
    } catch (e) {
      _mostrarMensaje('Error de conexión. Revisa si el servidor está encendido.');
      print("Error: $e");
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