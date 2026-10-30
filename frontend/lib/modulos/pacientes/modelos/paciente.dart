import '../../seguimiento/modelos/registro_seguimiento.dart';

class Paciente {
  final String nombre;
  final int edad;
  final String sexo;
  final String tipoSangre;
  final List<String> enfermedades;
  final List<String> alergias;
  final String ultimaVisita;
  final List<RegistroSeguimiento> registros;

  const Paciente({
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.tipoSangre,
    required this.enfermedades,
    required this.alergias,
    required this.ultimaVisita,
    required this.registros,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'edad': edad,
        'sexo': sexo,
        'tipoSangre': tipoSangre,
        'enfermedades': enfermedades,
        'alergias': alergias,
        'ultimaVisita': ultimaVisita,
        'registros': registros.map((r) => r.toJson()).toList(),
      };

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      nombre: json['nombre'] as String,
      edad: json['edad'] as int,
      sexo: json['sexo'] as String,
      tipoSangre: json['tipoSangre'] as String,
      enfermedades:
          (json['enfermedades'] as List).map((e) => e as String).toList(),
      alergias:
          (json['alergias'] as List).map((e) => e as String).toList(),
      ultimaVisita: json['ultimaVisita'] as String,
      registros: (json['registros'] as List)
          .map((e) =>
              RegistroSeguimiento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}