class Medicamento {
  final String id;
  final String nombre;
  final String dosis;
  final String viaAdministracion;
  final String frecuencia;
  final List<String> horarios;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final EstadoMedicamento estado;
  final Set<String> tomasHoy;
  final Set<String> historialTomas;
  final Set<String> historialOmitidas;
  final String? notas;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    this.viaAdministracion = 'Oral',
    required this.frecuencia,
    required this.horarios,
    required this.fechaInicio,
    required this.fechaFin,
    this.estado = EstadoMedicamento.activo,
    Set<String>? tomasHoy,
    Set<String>? historialTomas,
    Set<String>? historialOmitidas,
    this.notas,
  })  : tomasHoy = tomasHoy ?? {},
        historialTomas = historialTomas ?? {},
        historialOmitidas = historialOmitidas ?? {};

  String get rangoFormateado {
    return '${_fmt(fechaInicio)} - ${_fmt(fechaFin)}';
  }

  static String _fmt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Medicamento copyWith({
    Set<String>? tomasHoy,
    Set<String>? historialTomas,
    Set<String>? historialOmitidas,
    EstadoMedicamento? estado,
  }) {
    return Medicamento(
      id: id,
      nombre: nombre,
      dosis: dosis,
      viaAdministracion: viaAdministracion,
      frecuencia: frecuencia,
      horarios: horarios,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      estado: estado ?? this.estado,
      tomasHoy: tomasHoy ?? this.tomasHoy,
      historialTomas: historialTomas ?? this.historialTomas,
      historialOmitidas: historialOmitidas ?? this.historialOmitidas,
      notas: notas,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'viaAdministracion': viaAdministracion,
        'frecuencia': frecuencia,
        'horarios': horarios,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'estado': estado.name,
        'tomasHoy': tomasHoy.toList(),
        'historialTomas': historialTomas.toList(),
        'historialOmitidas': historialOmitidas.toList(),
        'notas': notas,
      };

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    return Medicamento(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      dosis: json['dosis'] as String,
      viaAdministracion: json['viaAdministracion'] as String? ?? 'Oral',
      frecuencia: json['frecuencia'] as String,
      horarios: (json['horarios'] as List).map((e) => e as String).toList(),
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      estado: EstadoMedicamento.values.firstWhere(
        (s) => s.name == json['estado'],
        orElse: () => EstadoMedicamento.activo,
      ),
      tomasHoy: (json['tomasHoy'] as List?)?.cast<String>().toSet() ?? {},
      historialTomas: (json['historialTomas'] as List?)?.cast<String>().toSet() ?? {},
      historialOmitidas: (json['historialOmitidas'] as List?)?.cast<String>().toSet() ?? {},
      notas: json['notas'] as String?,
    );
  }
}

enum EstadoMedicamento { activo, suspendido, finalizado }

extension EtiquetaEstadoMedicamento on EstadoMedicamento {
  String get etiqueta {
    switch (this) {
      case EstadoMedicamento.activo: return 'Activo';
      case EstadoMedicamento.suspendido: return 'Suspendido';
      case EstadoMedicamento.finalizado: return 'Finalizado';
    }
  }
}