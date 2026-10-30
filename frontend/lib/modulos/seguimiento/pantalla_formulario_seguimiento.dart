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
  String? _momento;

  static const _opcionesMomento = [
    'En ayunas',
    'Postprandial (despues de comer)',
    'Antes de dormir',
    'Aleatorio',
  ];

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial ?? 'glucosa';
    
    if (widget.tipoInicial == 'sintomas') {
      _tipo = 'otro';
      _controladorOtroNombre.text = 'Sintomas';
    }
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
      case 'saturacion': return '%';
      case 'respiratoria': return 'rpm';
      default: return '';
    }
  }

  Map<String, String> get _datosHero {
    switch (_tipo) {
      case 'glucosa': return {'titulo': 'Glucosa', 'desc': 'Manten un registro de tus niveles de glucosa para un mejor control.'};
      case 'presion': return {'titulo': 'Presion', 'desc': 'Registra tu presion arterial para monitorear tu salud cardiovascular.'};
      case 'peso': return {'titulo': 'Peso', 'desc': 'Lleva un control de tu peso corporal a lo largo del tiempo.'};
      case 'frecuencia': return {'titulo': 'Frecuencia', 'desc': 'Monitorea tu frecuencia cardiaca en reposo.'};
      case 'saturacion': return {'titulo': 'Saturacion', 'desc': 'Verifica tus niveles de oxigeno en sangre.'};
      case 'respiratoria': return {'titulo': 'Respiratoria', 'desc': 'Registra tu frecuencia respiratoria.'};
      default: return {'titulo': 'Medicion', 'desc': 'Registra tu medicion de salud.'};
    }
  }

  @override
  Widget build(BuildContext context) {
    final esPreseleccionado = widget.tipoInicial != null;
    
    const colorFondo = Color(0xFFF8FAFC);
    const colorHeroBg = Color(0xFFE0F2FE);
    const colorTextoOscuro = Color(0xFF0F172A);
    const colorTextoClaro = Color(0xFF64748B);
    const colorPrimario = Color(0xFF0284C7);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorTextoOscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.teal.shade400, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Mi Salud Oasis',
              style: TextStyle(color: colorTextoOscuro, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: colorTextoOscuro),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!esPreseleccionado) ...[
                const Text('Que deseas registrar?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colorTextoOscuro)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chipTipo('glucosa', 'Glucosa', Icons.water_drop_outlined),
                    _chipTipo('presion', 'Presion', Icons.favorite_border),
                    _chipTipo('peso', 'Peso', Icons.monitor_weight_outlined),
                    _chipTipo('frecuencia', 'Frecuencia', Icons.monitor_heart_outlined),
                    _chipTipo('saturacion', 'Sat. O2', Icons.air_outlined),
                    _chipTipo('respiratoria', 'Frec. resp.', Icons.waves_outlined),
                    _chipTipo('otro', 'Otro', Icons.health_and_safety_outlined),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorHeroBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('REGISTRAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: colorPrimario)),
                        Text(_datosHero['titulo']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: Text(_datosHero['desc']!, style: const TextStyle(fontSize: 14, color: colorTextoClaro, height: 1.4)),
                        ),
                      ],
                    ),
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Icon(Icons.water_drop, size: 100, color: Colors.blue.shade300.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TARJETA DE FORMULARIO BLANCA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_tipo == 'presion' ? 'Presion arterial' : 'Nivel de ${_datosHero['titulo']!.toLowerCase()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                    const SizedBox(height: 12),
                    
                    if (_tipo == 'presion') 
                      _construirCamposPresion()
                    else if (_tipo == 'otro')
                      _construirCamposOtros()
                    else
                      _construirInputPrincipal(colorPrimario),

                    const SizedBox(height: 16),
                    
                    // Info Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorHeroBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: colorPrimario),
                          const SizedBox(width: 8),
                          Text(
                            'Tu rango configurado: ${RangosMedicion.textoReferencia(_tipo)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorPrimario),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Momento de la medicion (solo si es glucosa)
                    if (_tipo == 'glucosa') ...[
                      const Text('Momento de la medicion', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _momento,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Selecciona una opcion',
                          hintStyle: const TextStyle(color: colorTextoClaro),
                          prefixIcon: const Icon(Icons.access_time, color: colorTextoClaro),
                          filled: true,
                          fillColor: colorFondo,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorPrimario)),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down, color: colorTextoClaro),
                        items: _opcionesMomento.map((m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
                        onChanged: (v) => setState(() => _momento = v),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Observaciones
                    const Text('Observaciones (opcional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorTextoOscuro)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controladorObservaciones,
                      maxLines: 4,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: 'Ej. Me senti bien...',
                        hintStyle: const TextStyle(color: colorTextoClaro),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.chat_bubble_outline, color: colorTextoClaro),
                        ),
                        filled: true,
                        fillColor: colorFondo,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: colorPrimario)),
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
                  style: FilledButton.styleFrom(
                    backgroundColor: colorPrimario,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _cargando 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(_cargando ? 'Guardando...' : 'Guardar medicion', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 40),

              // Decoracion inferior (olas)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 40, height: 2, color: Colors.grey.shade300),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite, color: Colors.teal.shade200, size: 16),
                    const SizedBox(width: 8),
                    Container(width: 40, height: 2, color: Colors.grey.shade300),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chipTipo(String tipo, String etiqueta, IconData icono) {
    final seleccionado = _tipo == tipo;
    return ChoiceChip(
      selected: seleccionado,
      onSelected: (_) {
        setState(() {
          _tipo = tipo;
          _controladorValor.clear();
          _controladorSistolica.clear();
          _controladorDiastolica.clear();
          _controladorFrecuenciaCardiaca.clear();
          _controladorOtroNombre.clear();
          _momento = null;
        });
      },
      avatar: Icon(icono, size: 18, color: seleccionado ? Colors.white : const Color(0xFF0284C7)),
      label: Text(etiqueta),
      labelStyle: TextStyle(color: seleccionado ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13),
      selectedColor: const Color(0xFF0284C7),
      backgroundColor: Colors.white,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _construirInputPrincipal(Color colorPrimario) {
    return TextField(
      controller: _controladorValor,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: '118',
        hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 24, fontWeight: FontWeight.bold),
        suffixText: _unidad,
        suffixStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, fontSize: 14),
        prefixIcon: const Icon(Icons.water_drop, color: Color(0xFF0284C7)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: colorPrimario)),
      ),
    );
  }

  Widget _construirCamposPresion() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controladorSistolica,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'Sistolica', 
                  hintText: '120', 
                  suffixText: 'mmHg', 
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controladorDiastolica,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'Diastolica', 
                  hintText: '80', 
                  suffixText: 'mmHg',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controladorFrecuenciaCardiaca,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Frecuencia cardiaca (opcional)', 
            hintText: '74', 
            suffixText: 'lpm',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _construirCamposOtros() {
    return Column(
      children: [
        TextField(
          controller: _controladorOtroNombre, 
          decoration: InputDecoration(
            hintText: 'Ej. Temperatura',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          )
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controladorValor, 
          decoration: InputDecoration(
            hintText: 'Ej. 36.5',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          )
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    String valor;
    String nombreMostrar;
    String? extra;

    switch (_tipo) {
      case 'glucosa':
        valor = _controladorValor.text.trim();
        nombreMostrar = 'Glucosa';
        if (valor.isEmpty) { _mostrarError('Ingresa el valor de glucosa'); return; }
        break;
      case 'peso':
        valor = _controladorValor.text.trim();
        nombreMostrar = 'Peso';
        if (valor.isEmpty) { _mostrarError('Ingresa el peso'); return; }
        break;
      case 'frecuencia':
        valor = _controladorValor.text.trim();
        nombreMostrar = 'Frecuencia cardiaca';
        if (valor.isEmpty) { _mostrarError('Ingresa la frecuencia'); return; }
        break;
      case 'saturacion':
        valor = _controladorValor.text.trim();
        nombreMostrar = 'Saturacion O2';
        if (valor.isEmpty) { _mostrarError('Ingresa la saturacion'); return; }
        break;
      case 'respiratoria':
        valor = _controladorValor.text.trim();
        nombreMostrar = 'Frec. respiratoria';
        if (valor.isEmpty) { _mostrarError('Ingresa la frecuencia respiratoria'); return; }
        break;
      case 'presion':
        final sys = _controladorSistolica.text.trim();
        final dia = _controladorDiastolica.text.trim();
        if (sys.isEmpty || dia.isEmpty) { _mostrarError('Ingresa la presion sistolica y diastolica'); return; }
        valor = '$sys/$dia';
        nombreMostrar = 'Presion';
        final hr = _controladorFrecuenciaCardiaca.text.trim();
        if (hr.isNotEmpty) extra = 'Frecuencia cardiaca: $hr lpm';
        break;
      default:
        final nombre = _controladorOtroNombre.text.trim();
        valor = _controladorValor.text.trim();
        if (nombre.isEmpty || valor.isEmpty) { _mostrarError('Completa el nombre y el valor'); return; }
        nombreMostrar = nombre;
        break;
    }

    final notasRaw = _controladorObservaciones.text.trim();
    final partesNotas = <String>[];
    if (_momento != null) partesNotas.add('Momento: $_momento');
    if (extra != null) partesNotas.add(extra);
    if (notasRaw.isNotEmpty) partesNotas.add(notasRaw);
    final observaciones = partesNotas.isEmpty ? null : partesNotas.join(' - ');

    setState(() => _cargando = true);

    final url = Uri.parse('http://localhost:8080/api/seguimiento');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pacienteId": RepositorioApp.instancia.idPacienteActual,
          "tipo": _tipo,
          "nombreMostrar": nombreMostrar,
          "valor": valor,
          "unidad": _unidad,
          "observaciones": observaciones,
          "momento": _momento,
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        _mostrarError('Error al guardar en el servidor');
      }
    } catch (e) {
      debugPrint("Error: $e");
      _mostrarError('Error de conexion con el servidor');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}