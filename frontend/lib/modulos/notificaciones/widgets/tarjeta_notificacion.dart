import 'package:flutter/material.dart';

// Modelo de datos para usar en ambas pantallas
class NotificacionModelo {
  final DateTime fecha;
  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;

  const NotificacionModelo({
    required this.fecha,
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
  });
}

// Función que agrupa las notificaciones por Hoy, Ayer, etc.
Map<String, List<NotificacionModelo>> agruparNotificaciones(List<NotificacionModelo> notificaciones) {
  notificaciones.sort((a, b) => b.fecha.compareTo(a.fecha)); // Ordenar de más reciente a más antigua

  final Map<String, List<NotificacionModelo>> agrupadas = {};
  
  for (var notif in notificaciones) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaDia = DateTime(notif.fecha.year, notif.fecha.month, notif.fecha.day);
    final diferenciaDias = hoy.difference(fechaDia).inDays;

    String titulo;
    if (diferenciaDias == 0) {
      titulo = 'Hoy';
    } else if (diferenciaDias == 1) {
      titulo = 'Ayer';
    } else if (diferenciaDias > 1 && diferenciaDias < 7) {
      const diasSemana = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      titulo = diasSemana[notif.fecha.weekday - 1];
    } else {
      const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      titulo = '${notif.fecha.day} de ${meses[notif.fecha.month - 1]}';
    }

    if (!agrupadas.containsKey(titulo)) {
      agrupadas[titulo] = [];
    }
    agrupadas[titulo]!.add(notif);
  }
  return agrupadas;
}

// Etiqueta gris para separar los días
class EtiquetaSeccion extends StatelessWidget {
  final String texto;
  const EtiquetaSeccion({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B), // Gris azulado
        ),
      ),
    );
  }
}

// El diseño exacto de la tarjeta de tu captura
class TarjetaNotificacion extends StatelessWidget {
  final NotificacionModelo datos;
  const TarjetaNotificacion({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    const colorFondoTarjeta = Color(0xFFF0F9FF);
    const colorBorde = Color(0xFFBAE6FD);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondoTarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBorde, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: datos.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(datos.icono, color: datos.color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datos.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datos.subtitulo,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Puntito azul de "No leída"
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF0EA5E9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}