import 'package:cinemanow_desktop/models/movie_reservation_seat_count.dart';
import 'package:cinemanow_desktop/models/movie_revenue.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';

class PdfExporter {
  static Future<void> exportToPDF(
    BuildContext context,
    int userCount,
    double totalIncome,
    List<MovieReservationSeatCount> top5Movies,
    List<MovieRevenue> movieRevenues,
    List<Color> sharedColors,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    try {
      final pieChartImage =
          await _capturePieChartImage(context, top5Movies, sharedColors);
      final barChartImage =
          await _captureBarChartImage(context, movieRevenues, sharedColors);
      if (barChartImage == null) {
        print("Bar chart image capture failed");
      }

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('Cinema Report',
                  style: pw.TextStyle(font: font, fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPdfCard(
                      'App Users', userCount == -1 ? 'Error' : '$userCount'),
                  _buildPdfCard(
                    'Cinema Income',
                    totalIncome == -1
                        ? 'Error'
                        : '\$${totalIncome.toStringAsFixed(2)}',
                  ),
                ],
              ),
              pw.SizedBox(height: 50),
              pw.Text('Top 5 Watched Movies',
                  style: pw.TextStyle(font: font, fontSize: 18)),
              pieChartImage != null ? pw.Image(pieChartImage) : pw.Container(),
              pw.SizedBox(height: 20),
              ..._buildLegendPdf(font, top5Movies, sharedColors),
            ],
          ),
        ),
      );

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              children: [
                pw.Text('Revenue by Movie',
                    style: pw.TextStyle(font: font, fontSize: 18)),
                pw.SizedBox(height: 20),
                barChartImage != null
                    ? pw.Image(barChartImage, width: 200, height: 200)
                    : pw.Container(),
                pw.SizedBox(height: 20),
                ..._buildRevenueInfoPdf(font, movieRevenues, sharedColors),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (error) {
      // Handle errors
    }
  }

  static List<pw.Widget> _buildRevenueInfoPdf(pw.Font font,
      List<MovieRevenue> movieRevenues, List<Color> sharedColors) {
    final List<pw.Widget> revenueInfo = [];

    for (var i = 0; i < movieRevenues.length; i++) {
      final movieRevenue = movieRevenues[i];
      final flutterColor = sharedColors[i % sharedColors.length];
      final pdfColor = PdfColor.fromInt(flutterColor.value);

      revenueInfo.add(
        pw.Row(
          children: [
            pw.Container(
              width: 10,
              height: 10,
              color: pdfColor,
            ),
            pw.SizedBox(width: 5),
            pw.Text(movieRevenue.movieTitle, style: pw.TextStyle(font: font)),
            pw.Spacer(),
            pw.Text('\$${movieRevenue.totalRevenue.toStringAsFixed(2)}',
                style: pw.TextStyle(font: font)),
          ],
        ),
      );
      revenueInfo.add(pw.SizedBox(height: 5));
    }
    return revenueInfo;
  }

  static Future<pw.ImageProvider?> _capturePieChartImage(
      BuildContext context,
      List<MovieReservationSeatCount> top5Movies,
      List<Color> sharedColors) async {
    final screenshotController = ScreenshotController();
    final pieChart = PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _getPieChartSections(top5Movies, sharedColors),
      ),
    );

    final bytes = await screenshotController.captureFromWidget(
      MediaQuery(
        data: MediaQueryData.fromView(View.of(context)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: pieChart,
        ),
      ),
    );

    return pw.MemoryImage(bytes);
  }

  static List<pw.Widget> _buildLegendPdf(pw.Font font,
      List<MovieReservationSeatCount> top5Movies, List<Color> sharedColors) {
    final int totalReservations =
        top5Movies.fold(0, (sum, movie) => sum + movie.reservationSeatCount);

    final List<pw.Widget> legend = [];

    for (var i = 0; i < top5Movies.length; i++) {
      final movie = top5Movies[i];
      final flutterColor = sharedColors[i % sharedColors.length];
      final pdfColor = PdfColor.fromInt(flutterColor.value);

      final double percentage =
          (movie.reservationSeatCount / totalReservations) * 100;

      legend.add(
        pw.Row(
          children: [
            pw.Container(
              width: 10,
              height: 10,
              color: pdfColor,
            ),
            pw.SizedBox(width: 5),
            pw.Text(movie.movieTitle, style: pw.TextStyle(font: font)),
            pw.Spacer(),
            pw.Text('${percentage.toStringAsFixed(1)}%',
                style: pw.TextStyle(font: font)),
          ],
        ),
      );
      legend.add(pw.SizedBox(height: 5));
    }
    return legend;
  }

  static List<PieChartSectionData> _getPieChartSections(
      List<MovieReservationSeatCount> top5Movies, List<Color> sharedColors) {
    return top5Movies.asMap().entries.map((entry) {
      final index = entry.key;
      final movie = entry.value;
      return PieChartSectionData(
        color: sharedColors[index % sharedColors.length],
        value: movie.reservationSeatCount.toDouble(),
        title: '',
        radius: 100,
        titleStyle: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  static Future<pw.ImageProvider?> _captureBarChartImage(BuildContext context,
      List<MovieRevenue> movieRevenues, List<Color> sharedColors) async {
    final screenshotController = ScreenshotController();
    final barChart = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (((movieRevenues
                                .map((e) => e.totalRevenue)
                                .reduce((a, b) => a > b ? a : b) *
                            1.2) /
                        50)
                    .ceil() *
                50) -
            50,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey[800]!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${movieRevenues[group.x.toInt()].movieTitle}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '\$${rod.toY.toStringAsFixed(2)}',
                    style: TextStyle(
                      color:
                          sharedColors[group.x.toInt() % sharedColors.length],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  movieRevenues[value.toInt()].movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: _getBarChartGroups(movieRevenues, sharedColors),
      ),
    );

    final bytes = await screenshotController.captureFromWidget(
      MediaQuery(
        data: MediaQueryData.fromView(View.of(context)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: barChart,
        ),
      ),
    );

    return pw.MemoryImage(bytes);
  }

  static List<BarChartGroupData> _getBarChartGroups(
      List<MovieRevenue> movieRevenues, List<Color> sharedColors) {
    return movieRevenues.asMap().entries.map((entry) {
      final index = entry.key;
      final revenue = entry.value.totalRevenue;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: revenue.toDouble(),
            color: sharedColors[index % sharedColors.length],
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  static pw.Widget _buildPdfCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(10),
        color: PdfColors.grey800,
      ),
      child: pw.Column(
        children: [
          pw.Text(title,
              style: const pw.TextStyle(color: PdfColors.white, fontSize: 18)),
          pw.SizedBox(height: 8),
          pw.Text(value,
              style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}
