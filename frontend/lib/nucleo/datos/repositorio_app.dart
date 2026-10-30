import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modulos/pacientes/modelos/paciente.dart';
import '../../modulos/medicamentos/modelos/medicamento.dart';
import '../../modulos/recetas/modelos/receta.dart';
import '../../modulos/citas/modelos/cita.dart';
import '../../modulos/citas/modelos/medico.dart';
import '../../modulos/seguimiento/modelos/registro_seguimiento.dart';
import '../utilidades/calculadora_adherencia.dart';

class RepositorioApp extends ChangeNotifier {
  RepositorioApp._();
  static final RepositorioApp instancia = RepositorioApp._();

  // ===== Identidad del usuario =====
  String _nombrePacienteActual = 'Raul Admin';
  String _nombreMedicoActual = 'Joel Encinos';
  
  // IDs dinamicos (se actualizan al hacer login)
  int _idPacienteActual = 1;
  int _idMedicoActual = 1;

  String get nombrePacienteActual => _nombrePacienteActual;
  String get nombreMedicoActual => _nombreMedicoActual;
  int get idPacienteActual => _idPacienteActual;
  int get idMedicoActual => _idMedicoActual;

  // ===== Claves de persistencia =====
  static const _kPacientes = 'mi_oasis_pacientes';
  static const _kMedicamentos = 'mi_oasis_medicamentos';
  static const _kRecetasPaciente = 'mi_oasis_recetas_paciente';
  static const _kRecetasMedico = 'mi_oasis_recetas_medico';
  static const _kCitas = 'mi_oasis_citas_v2';
  static const _kSeguimiento = 'mi_oasis_seguimiento';
  static const _kPacienteActual = 'mi_oasis_paciente_actual';
  static const _kMedicoActual = 'mi_oasis_medico_actual';
  static const _kIdPaciente = 'mi_oasis_id_paciente_actual';
  static const _kIdMedico = 'mi_oasis_id_medico_actual';

  // ===== Almacenes internos =====
  final List<Paciente> _pacientes = [];
  final List<Medicamento> _medicamentos = [];
  final List<Receta> _recetasPaciente = [];
  final List<Receta> _recetasMedico = [];
  final List<Cita> _citas = [];
  final List<RegistroSeguimiento> _seguimiento = [];

  SharedPreferences? _prefs;
  bool _inicializado = false;

  // ===== Getters =====
  List<Paciente> get pacientes => List.unmodifiable(_pacientes);
  List<Medicamento> get medicamentos => List.unmodifiable(_medicamentos);
  List<Receta> get recetasPaciente => List.unmodifiable(_recetasPaciente);
  List<Receta> get recetasMedico => List.unmodifiable(_recetasMedico);

  List<Cita> get citas => List.unmodifiable(_citas);

  List<Cita> get citasPaciente => List.unmodifiable(
        _citas.where((c) => c.nombrePaciente == _nombrePacienteActual),
      );

  List<Cita> get citasMedico => List.unmodifiable(_citas);

  List<Cita> get citasPendientes => List.unmodifiable(
        _citas.where((c) => c.estaPendiente),
      );

  List<RegistroSeguimiento> get seguimiento =>
      List.unmodifiable(_seguimiento);

  Paciente? get pacienteActual {
    try {
      return _pacientes.firstWhere((p) => p.nombre == _nombrePacienteActual);
    } catch (_) {
      return null;
    }
  }

  // ===== Catalogo de medicos y especialidades (ENFOQUE CRONICO) =====
  static const List<Especialidad> especialidades = [
    Especialidad(id: 'general', nombre: 'Medicina general', nombreIcono: 'general'),
    Especialidad(id: 'cardio', nombre: 'Cardiologia', nombreIcono: 'cardio'),
    Especialidad(id: 'endo', nombre: 'Endocrinologia', nombreIcono: 'endo'),
    Especialidad(id: 'nefro', nombre: 'Nefrologia', nombreIcono: 'nefro'),
    Especialidad(id: 'neumo', nombre: 'Neumologia', nombreIcono: 'neumo'),
  ];

  static const List<Medico> medicos = [
    Medico(nombre: 'Dr. Lopez', especialidad: 'Medicina general', consultorio: 'Consultorio 1', calificacion: 4.9),
    Medico(nombre: 'Dra. Ramirez', especialidad: 'Cardiologia', consultorio: 'Consultorio 3', calificacion: 4.8),
    Medico(nombre: 'Dr. Garcia', especialidad: 'Endocrinologia', consultorio: 'Consultorio 2', calificacion: 4.7),
    Medico(nombre: 'Dra. Fernandez', especialidad: 'Nefrologia', consultorio: 'Consultorio 5', calificacion: 4.9),
    Medico(nombre: 'Dr. Morales', especialidad: 'Neumologia', consultorio: 'Consultorio 4', calificacion: 4.8),
  ];

  List<Medico> medicosPorEspecialidad(String especialidad) {
    return medicos.where((m) => m.especialidad == especialidad).toList();
  }

  // ===== Inicializacion =====
  Future<void> inicializar() async {
    if (_inicializado) return;
    _inicializado = true;

    _prefs = await SharedPreferences.getInstance();

    final cargado = _cargarDesdePrefs();
    if (!cargado) {
      _crearDatosIniciales();
      await _guardarTodo();
    } else {
      final claveHoy = CalculadoraAdherencia.claveFecha(DateTime.now());
      for (int i = 0; i < _medicamentos.length; i++) {
        final m = _medicamentos[i];
        if (m.historialTomas.isEmpty && m.tomasHoy.isNotEmpty) {
          final nuevoHistorial =
              m.tomasHoy.map((h) => '$claveHoy|$h').toSet();
          _medicamentos[i] = m.copyWith(historialTomas: nuevoHistorial);
        }
      }
      await _guardarMedicamentos();
    }

    notifyListeners();
  }

  // ===== Identidad del usuario =====
  Future<void> establecerSesionPaciente({required String nombre, required int id}) async {
    final limpio = nombre.trim();
    if (limpio.isEmpty) return;

    _nombrePacienteActual = limpio;
    _idPacienteActual = id;

    final existe = _pacientes.any((p) => p.nombre == limpio);
    if (!existe) {
      try {
        final plantilla = _pacientes.firstWhere((p) => p.nombre == 'Raul Admin');
        _pacientes.add(
          Paciente(
            nombre: limpio,
            edad: plantilla.edad,
            sexo: plantilla.sexo,
            tipoSangre: plantilla.tipoSangre,
            enfermedades: plantilla.enfermedades,
            alergias: plantilla.alergias,
            ultimaVisita: plantilla.ultimaVisita,
            registros: const [],
          ),
        );
        await _guardarPacientes();
      } catch (_) {}
    }

    await _prefs?.setString(_kPacienteActual, limpio);
    await _prefs?.setInt(_kIdPaciente, id);
    notifyListeners();
  }

  Future<void> establecerSesionMedico({required String nombre, required int id}) async {
    final limpio = nombre.trim();
    if (limpio.isEmpty) return;
    
    _nombreMedicoActual = limpio;
    _idMedicoActual = id;
    
    await _prefs?.setString(_kMedicoActual, limpio);
    await _prefs?.setInt(_kIdMedico, id);
    notifyListeners();
  }

  // ===== Persistencia =====
  bool _cargarDesdePrefs() {
    final prefs = _prefs;
    if (prefs == null) return false;

    final pacientesRaw = prefs.getString(_kPacientes);
    if (pacientesRaw == null) return false;

    try {
      _pacientes.addAll(
        (jsonDecode(pacientesRaw) as List)
            .map((e) => Paciente.fromJson(e as Map<String, dynamic>)),
      );
      _medicamentos.addAll(
        (jsonDecode(prefs.getString(_kMedicamentos) ?? '[]') as List)
            .map((e) => Medicamento.fromJson(e as Map<String, dynamic>)),
      );
      _recetasPaciente.addAll(
        (jsonDecode(prefs.getString(_kRecetasPaciente) ?? '[]') as List)
            .map((e) => Receta.fromJson(e as Map<String, dynamic>)),
      );
      _recetasMedico.addAll(
        (jsonDecode(prefs.getString(_kRecetasMedico) ?? '[]') as List)
            .map((e) => Receta.fromJson(e as Map<String, dynamic>)),
      );
      _citas.addAll(
        (jsonDecode(prefs.getString(_kCitas) ?? '[]') as List)
            .map((e) => Cita.fromJson(e as Map<String, dynamic>)),
      );
      _seguimiento.addAll(
        (jsonDecode(prefs.getString(_kSeguimiento) ?? '[]') as List)
            .map((e) => RegistroSeguimiento.fromJson(e as Map<String, dynamic>)),
      );

      _nombrePacienteActual = prefs.getString(_kPacienteActual) ?? 'Raul Admin';
      _nombreMedicoActual = prefs.getString(_kMedicoActual) ?? 'Joel Encinos';
      
      _idPacienteActual = prefs.getInt(_kIdPaciente) ?? 1;
      _idMedicoActual = prefs.getInt(_kIdMedico) ?? 1;

      return true;
    } catch (e) {
      debugPrint('Error al cargar desde prefs: $e');
      _limpiarTodo();
      return false;
    }
  }

  void _limpiarTodo() {
    _pacientes.clear();
    _medicamentos.clear();
    _recetasPaciente.clear();
    _recetasMedico.clear();
    _citas.clear();
    _seguimiento.clear();
  }

  Future<void> _guardarTodo() async {
    final prefs = _prefs;
    if (prefs == null) return;

    await prefs.setString(_kPacientes, jsonEncode(_pacientes.map((p) => p.toJson()).toList()));
    await prefs.setString(_kMedicamentos, jsonEncode(_medicamentos.map((m) => m.toJson()).toList()));
    await prefs.setString(_kRecetasPaciente, jsonEncode(_recetasPaciente.map((r) => r.toJson()).toList()));
    await prefs.setString(_kRecetasMedico, jsonEncode(_recetasMedico.map((r) => r.toJson()).toList()));
    await prefs.setString(_kCitas, jsonEncode(_citas.map((c) => c.toJson()).toList()));
    await prefs.setString(_kSeguimiento, jsonEncode(_seguimiento.map((r) => r.toJson()).toList()));
    await prefs.setString(_kPacienteActual, _nombrePacienteActual);
    await prefs.setString(_kMedicoActual, _nombreMedicoActual);
    await prefs.setInt(_kIdPaciente, _idPacienteActual);
    await prefs.setInt(_kIdMedico, _idMedicoActual);
  }

  Future<void> _guardarPacientes() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kPacientes, jsonEncode(_pacientes.map((p) => p.toJson()).toList()));
  }

  Future<void> _guardarMedicamentos() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kMedicamentos, jsonEncode(_medicamentos.map((m) => m.toJson()).toList()));
  }

  Future<void> _guardarRecetasPaciente() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kRecetasPaciente, jsonEncode(_recetasPaciente.map((r) => r.toJson()).toList()));
  }

  Future<void> _guardarRecetasMedico() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kRecetasMedico, jsonEncode(_recetasMedico.map((r) => r.toJson()).toList()));
  }

  Future<void> _guardarCitas() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kCitas, jsonEncode(_citas.map((c) => c.toJson()).toList()));
  }

  Future<void> _guardarSeguimiento() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_kSeguimiento, jsonEncode(_seguimiento.map((r) => r.toJson()).toList()));
  }

  // ===== Mutaciones =====
  void agregarSeguimiento(RegistroSeguimiento registro) {
    _seguimiento.insert(0, registro);

    final idx = _pacientes.indexWhere((p) => p.nombre == _nombrePacienteActual);
    if (idx >= 0) {
      final p = _pacientes[idx];
      _pacientes[idx] = Paciente(
        nombre: p.nombre,
        edad: p.edad,
        sexo: p.sexo,
        tipoSangre: p.tipoSangre,
        enfermedades: p.enfermedades,
        alergias: p.alergias,
        ultimaVisita: p.ultimaVisita,
        registros: [registro, ...p.registros],
      );
    }

    _guardarSeguimiento();
    _guardarPacientes();
    notifyListeners();
  }

  void agregarMedicamento(Medicamento medicamento) {
    _medicamentos.insert(0, medicamento);
    _guardarMedicamentos();
    notifyListeners();
  }

  void marcarToma(String idMedicamento, String hora) {
    final idx = _medicamentos.indexWhere((m) => m.id == idMedicamento);
    if (idx < 0) return;
    
    final m = _medicamentos[idx];
    final claveHoy = CalculadoraAdherencia.claveFecha(DateTime.now());
    final entrada = '$claveHoy|$hora';

    final tomas = Set<String>.from(m.tomasHoy)..add(hora);
    final histTomas = Set<String>.from(m.historialTomas)..add(entrada);
    final histOmitidas = Set<String>.from(m.historialOmitidas)..remove(entrada);

    _medicamentos[idx] = m.copyWith(
      tomasHoy: tomas,
      historialTomas: histTomas,
      historialOmitidas: histOmitidas,
    );
    _guardarMedicamentos();
    notifyListeners();
  }

  void marcarOmitida(String idMedicamento, String hora) {
    final idx = _medicamentos.indexWhere((m) => m.id == idMedicamento);
    if (idx < 0) return;
    
    final m = _medicamentos[idx];
    final claveHoy = CalculadoraAdherencia.claveFecha(DateTime.now());
    final entrada = '$claveHoy|$hora';

    final tomas = Set<String>.from(m.tomasHoy)..remove(hora);
    final histTomas = Set<String>.from(m.historialTomas)..remove(entrada);
    final histOmitidas = Set<String>.from(m.historialOmitidas)..add(entrada);

    _medicamentos[idx] = m.copyWith(
      tomasHoy: tomas,
      historialTomas: histTomas,
      historialOmitidas: histOmitidas,
    );
    _guardarMedicamentos();
    notifyListeners();
  }

  void deshacerToma(String idMedicamento, String hora) {
    final idx = _medicamentos.indexWhere((m) => m.id == idMedicamento);
    if (idx < 0) return;
    
    final m = _medicamentos[idx];
    final claveHoy = CalculadoraAdherencia.claveFecha(DateTime.now());
    final entrada = '$claveHoy|$hora';

    final tomas = Set<String>.from(m.tomasHoy)..remove(hora);
    final histTomas = Set<String>.from(m.historialTomas)..remove(entrada);
    final histOmitidas = Set<String>.from(m.historialOmitidas)..remove(entrada);

    _medicamentos[idx] = m.copyWith(
      tomasHoy: tomas,
      historialTomas: histTomas,
      historialOmitidas: histOmitidas,
    );
    _guardarMedicamentos();
    notifyListeners();
  }

  void agregarReceta(Receta receta) {
    _recetasMedico.insert(0, receta);
    if (receta.nombrePaciente == _nombrePacienteActual) {
      _recetasPaciente.insert(0, receta);
      _guardarRecetasPaciente();
    }
    _guardarRecetasMedico();
    notifyListeners();
  }

  void solicitarCita(Cita cita) {
    _citas.insert(0, cita);
    _guardarCitas();
    notifyListeners();
  }

  void confirmarCita({
    required String idCita,
    required String nombreMedico,
    required DateTime fechaHora,
    required int duracion,
    String? notas,
  }) {
    final idx = _citas.indexWhere((c) => c.id == idCita);
    if (idx < 0) return;

    final actualizada = _citas[idx].copyWith(
      nombreMedico: nombreMedico,
      fechaHoraConfirmada: fechaHora,
      duracionMinutos: duracion,
      notasMedico: notas,
      estado: EstadoCita.confirmada,
    );
    _citas[idx] = actualizada;
    _guardarCitas();
    notifyListeners();
  }

  void cancelarCita(String idCita) {
    final idx = _citas.indexWhere((c) => c.id == idCita);
    if (idx < 0) return;
    _citas[idx] = _citas[idx].copyWith(
      estado: EstadoCita.cancelada,
    );
    _guardarCitas();
    notifyListeners();
  }

  Future<void> restablecerDatosIniciales() async {
    _limpiarTodo();
    _nombrePacienteActual = 'Raul Admin';
    _nombreMedicoActual = 'Joel Encinos';
    _idPacienteActual = 1;
    _idMedicoActual = 1;
    _crearDatosIniciales();
    await _guardarTodo();
    notifyListeners();
  }

  // ===== Datos semilla =====
  void _crearDatosIniciales() {
    _crearPacientesIniciales();
    _crearMedicamentosIniciales();
    _crearRecetasPacienteIniciales();
    _crearRecetasMedicoIniciales();
    _crearCitasIniciales();
    _crearSeguimientoInicial();
  }

  void _crearPacientesIniciales() {
    _pacientes.addAll([
      Paciente(
        nombre: 'Raul Admin',
        edad: 48,
        sexo: 'Masculino',
        tipoSangre: 'O+',
        enfermedades: ['Diabetes tipo 2', 'Hipertension'],
        alergias: ['Penicilina'],
        ultimaVisita: '10/09/2026',
        registros: [
          RegistroSeguimiento(
            id: 'seed_j_1',
            tipo: 'glucosa',
            nombreMostrar: 'Glucosa',
            valor: '118',
            unidad: 'mg/dL',
            fechaHora: DateTime(2026, 9, 5, 8, 30),
          ),
          RegistroSeguimiento(
            id: 'seed_j_2',
            tipo: 'glucosa',
            nombreMostrar: 'Glucosa',
            valor: '132',
            unidad: 'mg/dL',
            fechaHora: DateTime(2026, 9, 7, 8, 30),
          ),
          RegistroSeguimiento(
            id: 'seed_j_3',
            tipo: 'glucosa',
            nombreMostrar: 'Glucosa',
            valor: '126',
            unidad: 'mg/dL',
            fechaHora: DateTime(2026, 9, 10, 8, 15),
          ),
          RegistroSeguimiento(
            id: 'seed_j_4',
            tipo: 'glucosa',
            nombreMostrar: 'Glucosa',
            valor: '118',
            unidad: 'mg/dL',
            fechaHora: DateTime(2026, 9, 11, 8, 30),
          ),
          RegistroSeguimiento(
            id: 'seed_j_5',
            tipo: 'presion',
            nombreMostrar: 'Presion',
            valor: '125/80',
            unidad: 'mmHg',
            fechaHora: DateTime(2026, 9, 5, 8, 35),
          ),
          RegistroSeguimiento(
            id: 'seed_j_6',
            tipo: 'presion',
            nombreMostrar: 'Presion',
            valor: '130/85',
            unidad: 'mmHg',
            fechaHora: DateTime(2026, 9, 8, 8, 40),
          ),
          RegistroSeguimiento(
            id: 'seed_j_7',
            tipo: 'presion',
            nombreMostrar: 'Presion',
            valor: '125/80',
            unidad: 'mmHg',
            fechaHora: DateTime(2026, 9, 11, 8, 35),
          ),
        ],
      ),
    ]);
  }

  void _crearMedicamentosIniciales() {
    final ahora = DateTime.now();
    final claveHoy = CalculadoraAdherencia.claveFecha(ahora);

    Set<String> crearHistorial({
      required List<String> horas,
      required List<int> diasOmitidos,
      List<String> horasHoy = const [],
    }) {
      final historial = <String>{};
      for (int i = 1; i <= 6; i++) {
        if (diasOmitidos.contains(i)) continue;
        final dia = ahora.subtract(Duration(days: i));
        final clave = CalculadoraAdherencia.claveFecha(dia);
        for (final h in horas) {
          historial.add('$clave|$h');
        }
      }
      for (final h in horasHoy) {
        historial.add('$claveHoy|$h');
      }
      return historial;
    }

    final historialMetformina = crearHistorial(
      horas: ['08:00', '20:00'],
      diasOmitidos: [3],
      horasHoy: ['08:00'],
    );
    final historialLosartan = crearHistorial(
      horas: ['08:00'],
      diasOmitidos: [],
      horasHoy: ['08:00'],
    );
    final historialAtorvastatina = crearHistorial(
      horas: ['21:00'],
      diasOmitidos: [],
    );

    Set<String> horasHoyDe(Set<String> historial) {
      return historial
          .where((e) => e.startsWith('$claveHoy|'))
          .map((e) => e.split('|').last)
          .toSet();
    }

    _medicamentos.addAll([
      Medicamento(
        id: '1',
        nombre: 'Metformina',
        dosis: '850 mg',
        viaAdministracion: 'Oral',
        frecuencia: 'Cada 12 horas',
        horarios: ['08:00', '20:00'],
        fechaInicio: DateTime(2026, 9, 1),
        fechaFin: DateTime(2026, 12, 1),
        tomasHoy: horasHoyDe(historialMetformina),
        historialTomas: historialMetformina,
      ),
      Medicamento(
        id: '2',
        nombre: 'Losartan',
        dosis: '50 mg',
        viaAdministracion: 'Oral',
        frecuencia: 'Cada 24 horas',
        horarios: ['08:00'],
        fechaInicio: DateTime(2026, 9, 1),
        fechaFin: DateTime(2026, 12, 1),
        tomasHoy: horasHoyDe(historialLosartan),
        historialTomas: historialLosartan,
      ),
      Medicamento(
        id: '3',
        nombre: 'Atorvastatina',
        dosis: '20 mg',
        viaAdministracion: 'Oral',
        frecuencia: 'Cada 24 horas',
        horarios: ['21:00'],
        fechaInicio: DateTime(2026, 8, 15),
        fechaFin: DateTime(2026, 11, 15),
        tomasHoy: horasHoyDe(historialAtorvastatina),
        historialTomas: historialAtorvastatina,
      ),
    ]);
  }

  void _crearRecetasPacienteIniciales() {
    _recetasPaciente.addAll([
      Receta(
        id: '125',
        nombrePaciente: 'Raul Admin',
        nombreMedico: 'Joel Encinos',
        fecha: DateTime(2026, 9, 11),
        items: const [
          ItemReceta(
            nombreMedicamento: 'Metformina',
            dosis: '850 mg',
            frecuencia: 'Cada 12 horas',
            duracion: '30 dias',
          ),
          ItemReceta(
            nombreMedicamento: 'Losartan',
            dosis: '50 mg',
            frecuencia: 'Cada 24 horas',
            duracion: '30 dias',
          ),
        ],
        notas: 'Tomar con alimentos. No suspender sin consultar.',
      ),
    ]);
  }

  void _crearRecetasMedicoIniciales() {
    _recetasMedico.addAll([
      Receta(
        id: '125',
        nombrePaciente: 'Raul Admin',
        nombreMedico: 'Joel Encinos',
        fecha: DateTime(2026, 9, 11),
        items: const [
          ItemReceta(
            nombreMedicamento: 'Metformina',
            dosis: '850 mg',
            frecuencia: 'Cada 12 horas',
            duracion: '30 dias',
          ),
          ItemReceta(
            nombreMedicamento: 'Losartan',
            dosis: '50 mg',
            frecuencia: 'Cada 24 horas',
            duracion: '30 dias',
          ),
        ],
      ),
    ]);
  }

  void _crearCitasIniciales() {
    // Dejamos las citas iniciales vacias porque ahora las traemos de la BD
  }

  void _crearSeguimientoInicial() {
    final paciente = _pacientes.firstWhere((p) => p.nombre == 'Raul Admin');
    final ordenados = List<RegistroSeguimiento>.from(paciente.registros)
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    _seguimiento.addAll(ordenados);
  }
}