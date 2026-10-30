class Receta {
  final String id;
  final String nombrePaciente;
  final String nombreMedico;
  final DateTime fecha;
  final List<ItemReceta> items;
  final String? notas;

  const Receta({
    required this.id,
    required this.nombrePaciente,
    required this.nombreMedico,
    required this.fecha,
    required this.items,
    this.notas,
  });

  String get idFormateado => '#${id.padLeft(6, '0')}';

  String get fechaFormateada {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  // Mantenemos toJson por si el RepositorioApp lo sigue usando para guardar local
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombrePaciente': nombrePaciente,
        'nombreMedico': nombreMedico,
        'fecha': fecha.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'notas': notas,
      };

  factory Receta.fromJson(Map<String, dynamic> json) {
    String pac = 'Paciente';
    if (json['paciente'] != null && json['paciente']['usuario'] != null) {
      pac = json['paciente']['usuario']['nombre'];
    } else if (json['nombrePaciente'] != null) {
      pac = json['nombrePaciente'];
    }
    
    String med = 'Medico';
    if (json['medico'] != null && json['medico']['usuario'] != null) {
      med = json['medico']['usuario']['nombre'];
    } else if (json['nombreMedico'] != null) {
      med = json['nombreMedico'];
    }

    return Receta(
      id: json['id'].toString(),
      nombrePaciente: pac,
      nombreMedico: med,
      fecha: json['fechaReceta'] != null 
          ? DateTime.parse(json['fechaReceta'] as String) 
          : (json['fecha'] != null ? DateTime.parse(json['fecha'] as String) : DateTime.now()),
      items: (json['detalles'] as List? ?? json['items'] as List? ?? [])
          .map((d) => ItemReceta.fromJson(d))
          .toList(),
      notas: json['notas'] as String?,
    );
  }
}

class ItemReceta {
  final String nombreMedicamento;
  final String dosis;
  final String frecuencia;
  final String duracion;

  const ItemReceta({
    required this.nombreMedicamento,
    required this.dosis,
    required this.frecuencia,
    required this.duracion,
  });

  Map<String, dynamic> toJson() => {
        'nombreMedicamento': nombreMedicamento,
        'dosis': dosis,
        'frecuencia': frecuencia,
        'duracion': duracion,
      };

  factory ItemReceta.fromJson(Map<String, dynamic> json) {
    return ItemReceta(
      nombreMedicamento: json['nombreMedicamento'] ?? '',
      dosis: json['dosis'] ?? '',
      frecuencia: json['frecuencia'] ?? '',
      duracion: json['duracion'] ?? '',
    );
  }
}