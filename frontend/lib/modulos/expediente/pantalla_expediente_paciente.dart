import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../nucleo/datos/repositorio_app.dart';
import '../../nucleo/tema/tema_app.dart';

class PantallaExpedientePaciente extends StatefulWidget {
  const PantallaExpedientePaciente({super.key});

  @override
  State<PantallaExpedientePaciente> createState() => _EstadoPantallaExpedientePaciente();
}

class _EstadoPantallaExpedientePaciente extends State<PantallaExpedientePaciente> {
  Map<String, dynamic>? _paciente;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPaciente();
  }

  Future<void> _cargarPaciente() async {
    final url = Uri.parse('http://localhost:8080/api/pacientes/${RepositorioApp.instancia.idPacienteActual}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() => _paciente = jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Error al cargar paciente: $e");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_paciente == null) {
      return Center(
        child: Text(
          'Sin datos del paciente',
          style: TextStyle(color: colores.textSecondary),
        ),
      );
    }

    final usuario = _paciente!['usuario'];
    final nombre = usuario != null ? usuario['nombre'] : 'Paciente';
    final edad = _paciente!['edad'] ?? 'No registrada';
    final sexo = _paciente!['sexo'] ?? 'No registrado';
    final tipoSangre = _paciente!['tipoSangre'] ?? 'No registrado';
    final enfermedades = List<String>.from(_paciente!['enfermedades'] ?? []);
    final alergias = List<String>.from(_paciente!['alergias'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi expediente',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colores.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Informacion clinica registrada por tu medico',
            style: TextStyle(color: colores.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          _Seccion(
            icono: Icons.badge_outlined,
            titulo: 'Datos personales',
            children: [
              _Campo(etiqueta: 'Nombre', valor: nombre),
              _Campo(etiqueta: 'Edad', valor: '$edad anos'),
              _Campo(etiqueta: 'Sexo', valor: sexo),
              _Campo(etiqueta: 'Tipo de sangre', valor: tipoSangre),
            ],
          ),
          _Seccion(
            icono: Icons.monitor_heart_outlined,
            titulo: 'Enfermedades cronicas',
            children: enfermedades.isEmpty
                ? [
                    Text(
                      'Sin enfermedades registradas',
                      style: TextStyle(color: colores.textSecondary),
                    ),
                  ]
                : enfermedades
                    .map((enfermedad) => _Etiqueta(texto: enfermedad))
                    .toList(),
          ),
          _Seccion(
            icono: Icons.warning_amber_outlined,
            titulo: 'Alergias',
            children: alergias.isEmpty
                ? [
                    Text(
                      'Sin alergias registradas',
                      style: TextStyle(color: colores.textSecondary),
                    ),
                  ]
                : alergias
                    .map((alergia) =>
                        _Etiqueta(texto: alergia, color: colores.danger))
                    .toList(),
          ),
          _Seccion(
            icono: Icons.history_outlined,
            titulo: 'Ultima consulta',
            children: const [
              _Campo(etiqueta: 'Fecha', valor: 'Pendiente de registrar'),
              _Campo(etiqueta: 'Medico', valor: 'Pendiente de registrar'),
              _Campo(
                etiqueta: 'Observaciones',
                valor: 'Esta seccion se conectara en el futuro.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colores.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: colores.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colores.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colores.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Campo({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 12,
              color: colores.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: TextStyle(
              color: colores.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color? color;

  const _Etiqueta({required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    final colores = context.colors;
    final colorBase = color ?? colores.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorBase.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        texto,
        style: TextStyle(color: colorBase, fontWeight: FontWeight.w600),
      ),
    );
  }
}