/// Estado de una medición según su valor.
enum EstadoMedicion { bajo, normal, elevado, alto, desconocido }

extension InfoEstadoMedicion on EstadoMedicion {
  String get etiqueta {
    switch (this) {
      case EstadoMedicion.bajo:
        return 'Bajo';
      case EstadoMedicion.normal:
        return 'Normal';
      case EstadoMedicion.elevado:
        return 'Elevado';
      case EstadoMedicion.alto:
        return 'Alto';
      case EstadoMedicion.desconocido:
        return '';
    }
  }

  bool get esNormal => this == EstadoMedicion.normal;
}

/// Rangos de referencia para las mediciones de Mi Oasis.
class RangosMedicion {
  /// Glucosa en mg/dL (ayuno/postprandial aproximado).
  static EstadoMedicion evaluarGlucosa(double valor) {
    if (valor < 70) return EstadoMedicion.bajo;
    if (valor <= 140) return EstadoMedicion.normal;
    if (valor <= 180) return EstadoMedicion.elevado;
    return EstadoMedicion.alto;
  }

  /// Presión sistólica en mmHg.
  static EstadoMedicion evaluarSistolica(double valor) {
    if (valor < 90) return EstadoMedicion.bajo;
    if (valor < 120) return EstadoMedicion.normal;
    if (valor <= 140) return EstadoMedicion.elevado;
    return EstadoMedicion.alto;
  }

  /// Presión diastólica en mmHg.
  static EstadoMedicion evaluarDiastolica(double valor) {
    if (valor < 60) return EstadoMedicion.bajo;
    if (valor <= 80) return EstadoMedicion.normal;
    if (valor <= 90) return EstadoMedicion.elevado;
    return EstadoMedicion.alto;
  }

  /// Frecuencia cardíaca en bpm.
  static EstadoMedicion evaluarFrecuenciaCardiaca(double valor) {
    if (valor < 60) return EstadoMedicion.bajo;
    if (valor <= 100) return EstadoMedicion.normal;
    return EstadoMedicion.elevado;
  }

  /// Saturación de oxígeno en %.
  static EstadoMedicion evaluarOxigeno(double valor) {
    if (valor < 90) return EstadoMedicion.alto; // Crítico
    if (valor < 95) return EstadoMedicion.elevado;
    return EstadoMedicion.normal;
  }

  /// Frecuencia respiratoria en rpm.
  static EstadoMedicion evaluarFrecuenciaRespiratoria(double valor) {
    if (valor < 12) return EstadoMedicion.bajo;
    if (valor <= 20) return EstadoMedicion.normal;
    return EstadoMedicion.elevado;
  }

  /// Evalúa un registro según su tipo.
  static EstadoMedicion evaluarRegistro({
    required String tipo,
    required String valor,
  }) {
    switch (tipo) {
      case 'glucosa':
        final n = double.tryParse(valor);
        if (n == null) return EstadoMedicion.desconocido;
        return evaluarGlucosa(n);

      case 'presion':
        final partes = valor.split('/');
        if (partes.length != 2) return EstadoMedicion.desconocido;
        final sys = double.tryParse(partes[0]);
        final dia = double.tryParse(partes[1]);
        if (sys == null || dia == null) return EstadoMedicion.desconocido;
        return _peor(evaluarSistolica(sys), evaluarDiastolica(dia));

      case 'frecuencia':
        final n = double.tryParse(valor);
        if (n == null) return EstadoMedicion.desconocido;
        return evaluarFrecuenciaCardiaca(n);

      case 'saturacion':
        final n = double.tryParse(valor);
        if (n == null) return EstadoMedicion.desconocido;
        return evaluarOxigeno(n);

      case 'respiratoria':
        final n = double.tryParse(valor);
        if (n == null) return EstadoMedicion.desconocido;
        return evaluarFrecuenciaRespiratoria(n);

      default:
        return EstadoMedicion.desconocido;
    }
  }

  static EstadoMedicion _peor(EstadoMedicion a, EstadoMedicion b) {
    int rango(EstadoMedicion s) {
      switch (s) {
        case EstadoMedicion.normal: return 0;
        case EstadoMedicion.bajo: return 1;
        case EstadoMedicion.elevado: return 2;
        case EstadoMedicion.alto: return 3;
        case EstadoMedicion.desconocido: return 0;
      }
    }
    return rango(a) >= rango(b) ? a : b;
  }

  /// Texto de referencia que se muestra bajo un campo.
  static String textoReferencia(String tipo) {
    switch (tipo) {
      case 'glucosa':
        return 'Tu rango configurado: 70-140 mg/dL';
      case 'presion':
        return 'Normal: <120/80 mmHg';
      case 'frecuencia':
        return 'Normal: 60-100 bpm';
      case 'saturacion':
        return 'Normal: 95-100 %';
      case 'respiratoria':
        return 'Normal: 12-20 rpm';
      case 'peso':
        return 'Registra tu peso actual';
      default:
        return '';
    }
  }
}