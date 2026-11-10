import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/utilidades/rangos_medicion.dart';

class PantallaFormularioSeguimiento extends StatefulWidget {
  final String? tipoInicial; 

  const PantallaFormularioSeguimiento({super.key, this.tipoInicial});

  @override
  State<PantallaFormularioSeguimiento> createState() => _EstadoPantallaFormularioSeguimiento();
}

class _EstadoPantallaFormularioSeguimiento extends State<PantallaFormularioSeguimiento> {
  late String _tipo;
  final _controladorValor = TextEditingController();
  final _controladorSistolica = TextEditingController();
  final _controladorDiastolica = TextEditingController();
  final _controladorFrecuenciaCardiaca = TextEditingController();
  final _controladorOtroNombre = TextEditingController();
  final _controladorObservaciones = TextEditingController();

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial ?? 'glucosa';
  }

  @override
  void dispose() {
    _controladorValor.dispose();
    _controladorSistolica.dispose();
    _controladorDiastolica.dispose();
    _controladorFrecuenciaCardiaca.dispose();
    _controladorOtroNombre.dispose();
    _controladorObservaciones.dispose();
    super.dispose();
  }

  String get _unidad {
    switch (_tipo) {
      case 'glucosa': return 'mg/dL';
      case 'presion': return 'mmHg';
      case 'peso': return 'kg';
      case 'frecuencia': return 'bpm';
      case 'temperatura': return '°C';
      default: return '';
    }
  }

  String get _tituloMedicion {
    switch (_tipo) {
      case 'glucosa': return 'Glucosa';
      case 'presion': return 'Presion';
      case 'peso': return 'Peso';
      case 'frecuencia': return 'Frecuencia Cardiaca';
      case 'temperatura': return 'Temperatura';
      default: return 'Medicion';
    }
  }

  String get _descripcionMedicion {
    switch (_tipo) {
      case 'glucosa': return 'Registra tu nivel y lleva un seguimiento de tu salud.';
      case 'presion': return 'Registra tu presion arterial para monitorear tu salud cardiovascular.';
      case 'peso': return 'Lleva un control de tu peso corporal a lo largo del tiempo.';
      case 'frecuencia': return 'Monitorea tu frecuencia cardiaca en reposo.';
      case 'temperatura': return 'Verifica si tienes fiebre o hipotermia.';
      default: return 'Registra tu medicion de salud.';
    }
  }

  IconData get _iconoMedicion {
    switch (_tipo) {
      case 'glucosa': return Icons.water_drop_outlined;
      case 'presion': return Icons.favorite_border;
      case 'peso': return Icons.monitor_weight_outlined;
      case 'frecuencia': return Icons.monitor_heart_outlined;
      case 'temperatura': return Icons.thermostat_outlined;
      default: return Icons.health_and_safety_outlined;
    }
  }

  Color get _colorPrincipal {
    switch (_tipo) {
      case 'glucosa': return const Color(0xFF0284C7);
      case 'presion': return const Color(0xFFE11D48);
      case 'peso': return const Color(0xFF16A34A);
      case 'frecuencia': return const Color(0xFFD97706);
      case 'temperatura': return const Color(0xFFB91C1C);
      default: return const Color(0xFF64748B);
    }
  }

  Color get _colorFondoHero {
    switch (_tipo) {
      case 'glucosa': return const Color(0xFFE0F2FE);
      case 'presion': return const Color(0xFFFFE4E6);
      case 'peso': return const Color(0xFFDCFCE7);
      case 'frecuencia': return const Color(0xFFFEF3C7);
      case 'temperatura': return const Color(0xFFFEE2E2);
      default: return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorFondo = Color(0xFFF8FAFC);
    const colorTextoOscuro = Color(0xFF0F172A);
    const colorTextoClaro = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorTextoOscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Registrar medicion', style: TextStyle(color: colorTextoOscuro, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Que deseas registrar?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
              const SizedBox(height: 12),
              
              // CUADRICULA 3x2 PERO CON 5 BOTONES
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _BotonTipo(tipo: 'glucosa', etiqueta: 'Glucosa', icono: Icons.water_drop_outlined, actual: _tipo, alCambiar: _cambiarTipo)),
                      const SizedBox(width: 8),
                      Expanded(child: _BotonTipo(tipo: 'presion', etiqueta: 'Presion', icono: Icons.favorite_border, actual: _tipo, alCambiar: _cambiarTipo)),
                      const SizedBox(width: 8),
                      Expanded(child: _BotonTipo(tipo: 'peso', etiqueta: 'Peso', icono: Icons.monitor_weight_outlined, actual: _tipo, alCambiar: _cambiarTipo)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _BotonTipo(tipo: 'frecuencia', etiqueta: 'Frecuencia', icono: Icons.monitor_heart_outlined, actual: _tipo, alCambiar: _cambiarTipo)),
                      const SizedBox(width: 8),
                      Expanded(child: _BotonTipo(tipo: 'temperatura', etiqueta: 'Temperatura', icono: Icons.thermostat_outlined, actual: _tipo, alCambiar: _cambiarTipo)),
                      const SizedBox(width: 8),
                      const Expanded(child: SizedBox()), // Espacio vacio para mantener el tamano
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _colorFondoHero,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NUEVA MEDICION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: _colorPrincipal)),
                        const SizedBox(height: 4),
                        Text(_tituloMedicion, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 220, 
                          child: Text(_descripcionMedicion, style: const TextStyle(fontSize: 14, color: colorTextoClaro, height: 1.4)),
                        ),
                      ],
                    ),
                    Positioned(
                      right: -10, bottom: -10,
                      child: Icon(_iconoMedicion, size: 90, color: _colorPrincipal.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TARJETA DE RESULTADO
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resultado de la medicion', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                    const SizedBox(height: 12),
                    _construirInputUnico(colorTextoClaro),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: _colorFondoHero, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 14, color: _colorPrincipal),
                          const SizedBox(width: 6),
                          Text(RangosMedicion.textoReferencia(_tipo), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _colorPrincipal)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // TARJETA DE NOTAS
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Notas adicionales (opcional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controladorObservaciones,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '¿Como te sentias durante la medicion?',
                        hintStyle: const TextStyle(color: colorTextoClaro, fontSize: 14),
                        filled: true,
                        fillColor: colorFondo,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _colorPrincipal)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // BOTON GUARDAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _cargando ? null : _guardar,
                  style: FilledButton.styleFrom(backgroundColor: _colorPrincipal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  icon: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar medicion', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _cambiarTipo(String tipo) {
    setState(() {
      _tipo = tipo;
      _controladorValor.clear();
      _controladorObservaciones.clear();
    });
  }

  Widget _construirInputUnico(Color colorTextoClaro) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NIVEL DE ${_tituloMedicion.toUpperCase()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorTextoClaro, letterSpacing: 0.5)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controladorValor,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  decoration: const InputDecoration(hintText: 'Ej. 118', hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 24, fontWeight: FontWeight.bold), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 8)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _colorFondoHero, borderRadius: BorderRadius.circular(20)),
                child: Text(_unidad, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _colorPrincipal)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    final valor = _controladorValor.text.trim();
    if (valor.isEmpty) { _mostrarError('Ingresa el valor de la medicion'); return; }

    final notasRaw = _controladorObservaciones.text.trim();
    final observaciones = notasRaw.isEmpty ? null : notasRaw;

    setState(() => _cargando = true);
    final url = Uri.parse('http://localhost:8080/api/seguimiento');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": RepositorioApp.instancia.idPacienteActual,
          "tipo": _tipo,
          "nombreMostrar": _tituloMedicion,
          "valor": valor,
          "unidad": _unidad,
          "observaciones": observaciones,
          "momento": null,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _mostrarError('Error al guardar en el servidor');
      }
    } catch (e) {
      _mostrarError('Error de conexion con el servidor');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}

class _BotonTipo extends StatelessWidget {
  final String tipo;
  final String etiqueta;
  final IconData icono;
  final String actual;
  final Function(String) alCambiar;

  const _BotonTipo({required this.tipo, required this.etiqueta, required this.icono, required this.actual, required this.alCambiar});

  Color get _colorBoton {
    switch (tipo) {
      case 'glucosa': return const Color(0xFF0284C7);
      case 'presion': return const Color(0xFFE11D48);
      case 'peso': return const Color(0xFF16A34A);
      case 'frecuencia': return const Color(0xFFD97706);
      case 'temperatura': return const Color(0xFFB91C1C);
      default: return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seleccionado = tipo == actual;
    return GestureDetector(
      onTap: () => alCambiar(tipo),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: seleccionado ? _colorBoton : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: seleccionado ? _colorBoton : const Color(0xFFE2E8F0)),
          boxShadow: seleccionado ? [BoxShadow(color: _colorBoton.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Icon(icono, color: seleccionado ? Colors.white : _colorBoton, size: 22),
            const SizedBox(height: 6),
            Text(etiqueta, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: seleccionado ? Colors.white : const Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}