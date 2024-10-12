import 'package:cinemanow_desktop/models/movie_reservation_seat_count.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cinemanow_desktop/providers/report_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(),
      child: _ReportsScreenContent(),
    );
  }
}

class _ReportsScreenContent extends StatefulWidget {
  @override
  _ReportsScreenContentState createState() => _ReportsScreenContentState();
}

class _ReportsScreenContentState extends State<_ReportsScreenContent> {
  int? userCount;
  double? totalIncome;
  List<MovieReservationSeatCount>? top5Movies;
  final List<Color> sharedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    fetchUserCount();
    fetchTotalIncome();
    fetchTop5WatchedMovies();
  }

  Future<void> fetchUserCount() async {
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      final count = await reportProvider.getUserCount();
      setState(() {
        userCount = count;
      });
    } catch (e) {
      setState(() {
        userCount = -1;
      });
    }
  }

  Future<void> fetchTotalIncome() async {
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      final income = await reportProvider.getTotalCinemaIncome();
      setState(() {
        totalIncome = income;
      });
    } catch (e) {
      setState(() {
        totalIncome = -1;
      });
    }
  }

  Future<void> fetchTop5WatchedMovies() async {
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      final movies = await reportProvider.getTop5WatchedMovies();
      setState(() {
        top5Movies = movies;
      });
    } catch (e) {
      setState(() {
        top5Movies = [];
      });
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();

    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);

      final int fetchedUserCount = await reportProvider.getUserCount();
      final double fetchedTotalIncome =
          await reportProvider.getTotalCinemaIncome();
      final List<MovieReservationSeatCount> fetchedTop5Movies =
          await reportProvider.getTop5WatchedMovies();

      final pieChartImage = await _capturePieChartImage(fetchedTop5Movies);

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
                  _buildPdfCard('App Users',
                      fetchedUserCount == -1 ? 'Error' : '$fetchedUserCount'),
                  _buildPdfCard(
                      'Cinema Income',
                      fetchedTotalIncome == -1
                          ? 'Error'
                          : '\$${fetchedTotalIncome.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Top 5 Watched Movies',
                  style: pw.TextStyle(font: font, fontSize: 18)),
              pieChartImage != null ? pw.Image(pieChartImage) : pw.Container(),
              pw.SizedBox(height: 20),
              ..._buildLegendPdf(font, fetchedTop5Movies),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save());
    } catch (error) {}
  }

  Future<pw.ImageProvider?> _capturePieChartImage(
      List<MovieReservationSeatCount> top5Movies) async {
    final screenshotController = ScreenshotController();
    final pieChart = PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _getPieChartSections(top5Movies),
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

  List<pw.Widget> _buildLegendPdf(
      pw.Font font, List<MovieReservationSeatCount> top5Movies) {
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

  pw.Widget _buildPdfCard(String title, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: userCount == null || totalIncome == null || top5Movies == null
            ? const CircularProgressIndicator(
                color: Colors.red,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoCard(
                          'App Users',
                          userCount == -1
                              ? 'Error fetching data'
                              : '$userCount',
                          Icons.people,
                        ),
                        const SizedBox(width: 20),
                        _buildInfoCard(
                          'Cinema Income',
                          totalIncome == -1
                              ? 'Error fetching data'
                              : '\$${totalIncome!.toStringAsFixed(2)}',
                          Icons.attach_money,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildPieChartWithLegend(),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _exportToPDF,
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label: const Text(
                        'Export to PDF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartWithLegend() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[850]!.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Top 5 Watched Movies',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _getPieChartSections(top5Movies!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildLegend(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
      List<MovieReservationSeatCount> top5Movies) {
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

  Widget _buildLegend() {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: top5Movies!.asMap().entries.map((entry) {
        final index = entry.key;
        final movie = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  movie.movieTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${((movie.reservationSeatCount / top5Movies!.fold(0, (sum, item) => sum + item.reservationSeatCount)) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
