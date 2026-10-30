/// Estado de una cita.
enum EstadoCita { pendiente, confirmada, completada, cancelada }

extension EtiquetaEstadoCita on EstadoCita {
  String get etiqueta {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.completada:
        return 'Atendida';
      case EstadoCita.cancelada:
        return 'Cancelada';
    }
  }
}

enum HorarioPreferido { manana, tarde, cualquiera }

extension EtiquetaHorarioPreferido on HorarioPreferido {
  String get etiqueta {
    switch (this) {
      case HorarioPreferido.manana:
        return 'Mañana';
      case HorarioPreferido.tarde:
        return 'Tarde';
      case HorarioPreferido.cualquiera:
        return 'Cualquier horario';
    }
  }

  String get rango {
    switch (this) {
      case HorarioPreferido.manana:
        return '08:00 - 12:00';
      case HorarioPreferido.tarde:
        return '14:00 - 19:00';
      case HorarioPreferido.cualquiera:
        return 'Todo el día';
    }
  }
}

class Cita {
  final String id;
  final String nombrePaciente;
  final String? nombreMedico;

  /// Especialidad solicitada.
  final String especialidad;

  /// Tipo: "Consulta de seguimiento", "Consulta general", "Urgencia", etc.
  final String tipo;

  final String motivo;
  final DateTime fechaPreferida;
  final HorarioPreferido horarioPreferido;
  final String? notasPaciente;
  final DateTime fechaCreacion;
  final DateTime? fechaHoraConfirmada;
  final int? duracionMinutos;
  final String? notasMedico;
  final EstadoCita estado;

  const Cita({
    required this.id,
    required this.nombrePaciente,
    this.nombreMedico,
    this.especialidad = 'Medicina general',
    required this.tipo,
    required this.motivo,
    required this.fechaPreferida,
    required this.horarioPreferido,
    this.notasPaciente,
    required this.fechaCreacion,
    this.fechaHoraConfirmada,
    this.duracionMinutos,
    this.notasMedico,
    this.estado = EstadoCita.pendiente,
  });

  DateTime get fechaHoraEfectiva => fechaHoraConfirmada ?? fechaPreferida;

  bool get estaPendiente => estado == EstadoCita.pendiente;
  bool get estaConfirmada => estado == EstadoCita.confirmada;
  bool get estaCompletada => estado == EstadoCita.completada;
  bool get estaCancelada => estado == EstadoCita.cancelada;

  String get fechaFormateada {
    final d = fechaHoraEfectiva;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get fechaPreferidaFormateada {
    final d = fechaPreferida;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get horaFormateada {
    final d = fechaHoraConfirmada;
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get fechaCreacionFormateada {
    final d = fechaCreacion;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get mesAbreviado {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return meses[fechaHoraEfectiva.month - 1];
  }

  bool get esHoy {
    final ahora = DateTime.now();
    final d = fechaHoraEfectiva;
    return d.year == ahora.year && d.month == ahora.month && d.day == ahora.day;
  }

  bool get esFutura {
    return fechaHoraEfectiva.isAfter(DateTime.now());
  }

  Cita copyWith({
    String? nombreMedico,
    String? especialidad,
    DateTime? fechaHoraConfirmada,
    int? duracionMinutos,
    String? notasMedico,
    EstadoCita? estado,
  }) {
    return Cita(
      id: id,
      nombrePaciente: nombrePaciente,
      nombreMedico: nombreMedico ?? this.nombreMedico,
      especialidad: especialidad ?? this.especialidad,
      tipo: tipo,
      motivo: motivo,
      fechaPreferida: fechaPreferida,
      horarioPreferido: horarioPreferido,
      notasPaciente: notasPaciente,
      fechaCreacion: fechaCreacion,
      fechaHoraConfirmada: fechaHoraConfirmada ?? this.fechaHoraConfirmada,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      notasMedico: notasMedico ?? this.notasMedico,
      estado: estado ?? this.estado,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombrePaciente': nombrePaciente,
        'nombreMedico': nombreMedico,
        'especialidad': especialidad,
        'tipo': tipo,
        'motivo': motivo,
        'fechaPreferida': fechaPreferida.toIso8601String(),
        'horarioPreferido': horarioPreferido.name,
        'notasPaciente': notasPaciente,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaHoraConfirmada': fechaHoraConfirmada?.toIso8601String(),
        'duracionMinutos': duracionMinutos,
        'notasMedico': notasMedico,
        'estado': estado.name,
      };

  factory Cita.fromJson(Map<String, dynamic> json) {
    // 1. Manejo del nombre del paciente (Soporta datos de Spring Boot y datos locales)
    String nombrePaciente = 'Paciente';
    if (json['paciente'] != null && json['paciente']['usuario'] != null) {
      nombrePaciente = json['paciente']['usuario']['nombre']; // Viene de Spring Boot
    } else if (json['nombrePaciente'] != null) {
      nombrePaciente = json['nombrePaciente']; // Viene del RepositorioApp local
    }

    // 2. Manejo del nombre del médico
    String? nombreMedico;
    if (json['medico'] != null && json['medico']['usuario'] != null) {
      nombreMedico = json['medico']['usuario']['nombre']; // Viene de Spring Boot
    } else if (json['nombreMedico'] != null) {
      nombreMedico = json['nombreMedico']; // Viene del RepositorioApp local
    }

    return Cita(
      id: json['id'].toString(), // Convertimos a String por si Java manda un Long
      nombrePaciente: nombrePaciente,
      nombreMedico: nombreMedico,
      especialidad: json['especialidad'] as String? ?? 'Medicina general',
      tipo: json['tipo'] as String? ?? 'Consulta general',
      motivo: json['motivo'] as String,
      fechaPreferida: DateTime.parse(json['fechaPreferida'] as String),
      horarioPreferido: HorarioPreferido.values.firstWhere(
        (p) => p.name.toLowerCase() == json['horarioPreferido'].toString().toLowerCase(),
        orElse: () => HorarioPreferido.cualquiera,
      ),
      notasPaciente: json['notasPaciente'] as String?,
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'] as String)
          : DateTime.now(),
      fechaHoraConfirmada: json['fechaHoraConfirmada'] != null
          ? DateTime.parse(json['fechaHoraConfirmada'] as String)
          : null,
      duracionMinutos: json['duracionMinutos'] != null 
          ? int.tryParse(json['duracionMinutos'].toString()) 
          : null,
      notasMedico: json['notasMedico'] as String?,
      estado: EstadoCita.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoCita.pendiente,
      ),
    );
  }
}