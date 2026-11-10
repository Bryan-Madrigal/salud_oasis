import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para cargar la imagen
import 'package:pdf/pdf.dart'; // Para crear el PDF
import 'package:pdf/widgets.dart' as pw; // Widgets del PDF
import 'package:printing/printing.dart'; // Para imprimir/compartir
import 'modelos/receta.dart';

class PantallaDetalleReceta extends StatelessWidget {
  final Receta receta;

  const PantallaDetalleReceta({super.key, required this.receta});

  // ====== FUNCION PARA GENERAR EL PDF ======
  Future<void> _generarPDF() async {
    final pdf = pw.Document();

    // Cargar la imagen del logo desde los assets
    final ByteData bytes = await rootBundle.load('assets/receta.png');
    final Uint8List logoImage = bytes.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // --- ENCABEZADO ---
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Image(pw.MemoryImage(logoImage), height: 80),
                pw.SizedBox(height: 10),
                pw.Text('Dr. ${receta.nombreMedico}', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text('Medico Familiar', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                pw.SizedBox(height: 4),
                pw.Text('Cedula de Profesional 2174322-E\nC. Pablo Valdez, La Perla\n44360 Guadalajara, Jal. Mexico', 
                  textAlign: pw.TextAlign.center, 
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)
                ),
              ]
            ),
            pw.SizedBox(height: 30),

            // --- INFORMACION DEL PACIENTE ---
            pw.Text('Informacion del paciente', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Nombre completo', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text(receta.nombrePaciente, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Fecha', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text(receta.fechaFormateada, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
              ]
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Edad', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('${receta.edad ?? "--"} anos', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Peso', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('${receta.peso ?? "--"} kg', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
                pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Altura', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                  pw.Text('${receta.altura ?? "--"} m', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
              ]
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- DIAGNOSTICO ---
            pw.Text('Diagnostico', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text(receta.diagnostico ?? 'No registrado', style: const pw.TextStyle(fontSize: 14)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- MEDICAMENTOS ---
            pw.Text('RX - Medicamentos', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...receta.items.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  color: PdfColors.grey50,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Medicamento $index', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                    pw.SizedBox(height: 2),
                    pw.Text('${item.nombreMedicamento} ${item.dosis}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Dosis: ${item.dosis}', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Via: ${item.viaAdministracion ?? "Oral"}', style: const pw.TextStyle(fontSize: 12)),
                      ]
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Frecuencia: ${item.frecuencia}', style: const pw.TextStyle(fontSize: 12)),
                        pw.Text('Duracion: ${item.duracion}', style: const pw.TextStyle(fontSize: 12)),
                      ]
                    ),
                    if (item.cantidad != null && item.cantidad!.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text('Cantidad: ${item.cantidad}', style: const pw.TextStyle(fontSize: 12)),
                    ]
                  ]
                )
              );
            }).toList(),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),

            // --- INDICACIONES ---
            pw.Text('Indicaciones adicionales', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
              child: pw.Text(receta.notas ?? 'Sin indicaciones adicionales.', style: const pw.TextStyle(fontSize: 12)),
            ),

            pw.SizedBox(height: 50),

            // --- FIRMA ---
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                children: [
                  pw.Container(width: 200, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 5),
                  pw.Text('Firma del medico', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Nombre y cedula profesional', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ]
              )
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text('Folio de receta - Mi Oasis', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
            )
          ];
        },
      ),
    );

    // Abrir el menú para imprimir o guardar el PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receta_${receta.idFormateado}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Fondo gris tipo escritorio
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Receta ${receta.idFormateado}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Descargar PDF',
            onPressed: () => _generarPDF(), // Genera el PDF
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Imprimir',
            onPressed: () => _generarPDF(), // Genera el PDF
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              color: Colors.white, // La hoja de papel
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(32.0),
            child: _construirDocumentoReceta(),
          ),
        ),
      ),
    );
  }

  // ====== DISEÑO VISUAL EN PANTALLA ======
  Widget _construirDocumentoReceta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ENCABEZADO
        Center(
          child: Column(
            children: [
              Image.asset('assets/receta.png', width: 80, height: 80, errorBuilder: (_,__,___) => const Icon(Icons.medical_services, size: 80)),
              const SizedBox(height: 12),
              Text('Dr. ${receta.nombreMedico}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              const Text('Medico Familiar', style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              const Text('Cedula de Profesional 2174322-E\nC. Pablo Valdez, La Perla\n44360 Guadalajara, Jal. Mexico', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // PACIENTE
        const Text('Informacion del paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _buildInfo('Nombre completo', receta.nombrePaciente),
        Row(
          children: [
            Expanded(child: _buildInfo('Edad', '${receta.edad ?? "--"} años')),
            Expanded(child: _buildInfo('Fecha', receta.fechaFormateada)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildInfo('Peso', '${receta.peso ?? "--"} kg')),
            Expanded(child: _buildInfo('Altura', '${receta.altura ?? "--"} m')),
          ],
        ),
        
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 24),

        // DIAGNOSTICO
        const Text('Diagnostico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        _buildInfo('Diagnostico medico', receta.diagnostico ?? 'No registrado'),
        
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 24),

        // MEDICAMENTOS
        const Text('RX - Medicamentos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        for (int i = 0; i < receta.items.length; i++) _buildCardMedicamento(receta.items[i], i),

        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 24),

        // INDICACIONES
        const Text('Indicaciones adicionales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(receta.notas ?? 'Sin indicaciones adicionales.', style: const TextStyle(fontSize: 14)),
        ),

        const SizedBox(height: 48),
        
        // FIRMA
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            children: [
              const SizedBox(
                width: 200,
                child: Divider(color: Colors.black, thickness: 1),
              ),
              const SizedBox(height: 8),
              const Text('Firma del medico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Text('Nombre y cedula profesional', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // FOOTER
        const Center(
          child: Text(
            'Folio de receta - Mi Oasis',
            style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildCardMedicamento(ItemReceta item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medicamento ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('${item.nombreMedicamento} ${item.dosis}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          const Divider(height: 24, color: Color(0xFFCBD5E1)),
          Row(
            children: [
              Expanded(child: _buildInfo('Dosis', item.dosis)),
              Expanded(child: _buildInfo('Via', item.viaAdministracion ?? 'Oral')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildInfo('Frecuencia', item.frecuencia)),
              Expanded(child: _buildInfo('Duracion', item.duracion)),
            ],
          ),
          if (item.cantidad != null && item.cantidad!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Cantidad: ${item.cantidad}', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            )
        ],
      ),
    );
  }
}