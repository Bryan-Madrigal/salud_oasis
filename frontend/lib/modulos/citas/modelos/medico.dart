class Medico {
  final String nombre;
  final String especialidad;
  final String consultorio;
  final double calificacion;

  const Medico({
    required this.nombre,
    required this.especialidad,
    required this.consultorio,
    this.calificacion = 4.8,
  });

  String get iniciales {
    final partes = nombre
        .replaceAll('Dr. ', '')
        .replaceAll('Dra. ', '')
        .trim()
        .split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0].substring(0, 1).toUpperCase();
  }
}

class Especialidad {
  final String id;
  final String nombre;
  final String nombreIcono;

  const Especialidad({
    required this.id,
    required this.nombre,
    required this.nombreIcono,
  });
}