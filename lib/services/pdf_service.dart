import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generarRecibo({
    required String nombrePaciente,
    required double costoTotal,
    required double totalPagado,
    required double adeudo,
    required List<Map<String, dynamic>> pagos,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Estado de Cuenta - Consultorio Dental",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Paciente: $nombrePaciente"),
            pw.Divider(),
            pw.Text("Resumen Financiero:"),
            pw.Bullet(
              text:
                  "Costo Total del Tratamiento: \$${costoTotal.toStringAsFixed(2)}",
            ),
            pw.Bullet(
              text:
                  "Total Pagado a la Fecha: \$${totalPagado.toStringAsFixed(2)}",
            ),
            pw.Text(
              "Adeudo Pendiente: \$${adeudo.toStringAsFixed(2)}",
              style: pw.TextStyle(
                color: PdfColors.red,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Historial de Pagos:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Fecha', 'Monto'],
              data: pagos.map((p) => [p['fecha'], "\$${p['monto']}"]).toList(),
            ),
          ],
        ),
      ),
    );

    // Abre el menú nativo para imprimir o compartir por WhatsApp
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
