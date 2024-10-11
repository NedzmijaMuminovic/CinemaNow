import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportGenerator {
  Future<void> generateReportPdf(int userCount, double totalIncome) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.grey800,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    'App Users',
                    userCount.toString(),
                  ),
                  pw.SizedBox(height: 20),
                  _buildInfoCard(
                    'Cinema Income',
                    '\$${totalIncome.toStringAsFixed(2)}',
                  ),
                  pw.SizedBox(height: 40),
                  pw.Center(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red,
                        borderRadius: pw.BorderRadius.circular(15),
                      ),
                      child: pw.Text(
                        'Report generated on ${DateTime.now().toString().split(' ')[0]}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildInfoCard(String title, String value) {
    return pw.Container(
      width: 300,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey700,
        borderRadius: pw.BorderRadius.circular(15),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 18,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 24,
              color: PdfColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
