import 'package:flutter/material.dart';
import '../../../nucleo/tema/tema_app.dart';

class RegistroSeguimiento {
  final String id;
  final String tipo;
  final String nombreMostrar;
  final String valor;
  final String unidad;
  final DateTime fechaHora;
  final String? observaciones;
  final String? momento;

  const RegistroSeguimiento({
    required this.id,
    required this.tipo,
    required this.nombreMostrar,
    required this.valor,
    required this.unidad,
    required this.fechaHora,
    this.observaciones,
    this.momento,
  });

  String get fechaFormateada {
    final d = fechaHora;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String get horaFormateada {
    final d = fechaHora;
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get valorCompleto => unidad.isEmpty ? valor : '$valor $unidad';

  // 👇 ESTE ERA EL MÉTODO QUE FALTABA 👇
  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'nombreMostrar': nombreMostrar,
        'valor': valor,
        'unidad': unidad,
        'fechaHora': fechaHora.toIso8601String(),
        'observaciones': observaciones,
        'momento': momento,
      };

  factory RegistroSeguimiento.fromJson(Map<String, dynamic> json) {
    return RegistroSeguimiento(
      id: json['id'].toString(),
      tipo: json['tipo'] as String,
      nombreMostrar: json['nombreMostrar'] as String,
      valor: json['valor'] as String,
      unidad: json['unidad'] as String? ?? '',
      fechaHora: json['fechaHora'] != null 
          ? DateTime.parse(json['fechaHora'] as String) 
          : DateTime.now(),
      observaciones: json['observaciones'] as String?,
      momento: json['momento'] as String?,
    );
  }
}

class InfoTipoSeguimiento {
  static IconData iconoPara(String tipo) {
    switch (tipo) {
      case 'glucosa': return Icons.water_drop_outlined;
      case 'presion': return Icons.favorite_border;
      case 'peso': return Icons.monitor_weight_outlined;
      case 'frecuencia': return Icons.monitor_heart_outlined;
      case 'saturacion': return Icons.air_outlined;
      case 'respiratoria': return Icons.waves_outlined;
      case 'sintoma': return Icons.sick_outlined;
      case 'checkin': return Icons.mood_outlined;
      default: return Icons.health_and_safety_outlined;
    }
  }

  static String etiquetaPara(String tipo) {
    switch (tipo) {
      case 'glucosa': return 'Glucosa';
      case 'presion': return 'Presion';
      case 'peso': return 'Peso';
      case 'frecuencia': return 'Frecuencia cardiaca';
      case 'saturacion': return 'Saturacion O2';
      case 'respiratoria': return 'Frec. respiratoria';
      case 'sintoma': return 'Sintomas';
      case 'checkin': return 'Check-in diario';
      default: return 'Otro';
    }
  }

  static Color colorPara(String tipo) {
    switch (tipo) {
      case 'glucosa': return TemaApp.primario; 
      case 'presion': return const Color(0xFFE57373);
      case 'peso': return const Color(0xFF42A5F5);
      case 'frecuencia': return const Color(0xFFF57C00);
      case 'saturacion': return const Color(0xFF26A69A);
      case 'respiratoria': return const Color(0xFF9C27B0);
      case 'sintoma': return const Color(0xFFFF7A7A);
      case 'checkin': return const Color(0xFFFFB74D);
      default: return const Color(0xFF9C27B0);
    }
  }
}