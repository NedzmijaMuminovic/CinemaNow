import 'package:cinemanow_desktop/models/movie_reservation_seat_count.dart';
import 'package:cinemanow_desktop/models/movie_revenue.dart';
import 'package:cinemanow_desktop/models/top_customer.dart';
import 'package:cinemanow_desktop/utilities/pdf_exporter.dart';
import 'package:cinemanow_desktop/utilities/report_selection.dart';
import 'package:cinemanow_desktop/utilities/utils.dart';
import 'package:flutter/material.dart';
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
  List<MovieRevenue>? movieRevenues;
  List<TopCustomer>? top5Customers;
  final List<Color> sharedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      fetchUserCount(),
      fetchTotalIncome(),
      fetchTop5WatchedMovies(),
      fetchMovieRevenues(),
      fetchTop5Customers(),
    ]);
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

  Future<void> fetchMovieRevenues() async {
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      final revenues = await reportProvider.getRevenueByMovie();
      setState(() {
        movieRevenues = revenues;
      });
    } catch (e) {
      setState(() {
        movieRevenues = [];
      });
    }
  }

  Future<void> fetchTop5Customers() async {
    try {
      final reportProvider =
          Provider.of<ReportProvider>(context, listen: false);
      final customers = await reportProvider.getTop5Customers();
      setState(() {
        top5Customers = customers;
      });
    } catch (e) {
      setState(() {
        top5Customers = [];
      });
    }
  }

  Future<void> _showReportSelectionDialog() async {
    final result = await showDialog<Set<ReportType>>(
      context: context,
      builder: (context) => ReportSelectionDialog(
        onConfirm: (selectedReports) async {
          await _exportSelectedReports(selectedReports);
        },
      ),
    );
  }

  Future<void> _exportSelectedReports(Set<ReportType> selectedReports) async {
    setState(() {
      _isExporting = true;
    });

    setState(() {
      if (selectedReports.contains(ReportType.userCount)) {
        userCount = null;
      }
      if (selectedReports.contains(ReportType.cinemaIncome)) {
        totalIncome = null;
      }
      if (selectedReports.contains(ReportType.movieWatched)) {
        top5Movies = null;
      }
      if (selectedReports.contains(ReportType.movieRevenue)) {
        movieRevenues = null;
      }
      if (selectedReports.contains(ReportType.topCustomers)) {
        top5Customers = null;
      }
    });

    List<Future> futures = [];
    if (selectedReports.contains(ReportType.userCount)) {
      futures.add(fetchUserCount());
    }
    if (selectedReports.contains(ReportType.cinemaIncome)) {
      futures.add(fetchTotalIncome());
    }
    if (selectedReports.contains(ReportType.movieWatched)) {
      futures.add(fetchTop5WatchedMovies());
    }
    if (selectedReports.contains(ReportType.movieRevenue)) {
      futures.add(fetchMovieRevenues());
    }
    if (selectedReports.contains(ReportType.topCustomers)) {
      futures.add(fetchTop5Customers());
    }

    await Future.wait(futures);

    bool canExport = true;
    if (selectedReports.contains(ReportType.userCount) && userCount == null) {
      canExport = false;
    }
    if (selectedReports.contains(ReportType.cinemaIncome) &&
        totalIncome == null) {
      canExport = false;
    }
    if (selectedReports.contains(ReportType.movieWatched) &&
        top5Movies == null) {
      canExport = false;
    }
    if (selectedReports.contains(ReportType.movieRevenue) &&
        movieRevenues == null) {
      canExport = false;
    }
    if (selectedReports.contains(ReportType.topCustomers) &&
        top5Customers == null) {
      canExport = false;
    }

    if (canExport) {
      String result = await PdfExporter.exportToPDF(
        context,
        userCount ?? -1,
        totalIncome ?? -1,
        top5Movies ?? [],
        movieRevenues ?? [],
        top5Customers ?? [],
        sharedColors,
        selectedReports,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == 'success'
                ? 'PDF exported successfully!'
                : 'Failed to export PDF. Please try again.',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    setState(() {
      _isExporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: userCount == null ||
                totalIncome == null ||
                top5Movies == null ||
                movieRevenues == null ||
                top5Customers == null
            ? const CircularProgressIndicator(
                color: Colors.red,
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _isExporting ? null : _showReportSelectionDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isExporting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  Icon(Icons.picture_as_pdf,
                                      color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Export to PDF',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ]),
                    ),
                    const SizedBox(height: 30),
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
                              : '\$${formatNumber(totalIncome)}',
                          Icons.attach_money,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildPieChartWithLegend(),
                    const SizedBox(height: 40),
                    _buildRevenueBarChart(),
                    const SizedBox(height: 40),
                    _buildTop5Customers(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Flexible(
      child: Container(
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

  Widget _buildRevenueBarChart() {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Revenue by Movie',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (((movieRevenues!
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
                        '${movieRevenues![group.x.toInt()].movieTitle}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '\$${formatNumber(rod.toY)}',
                            style: TextStyle(
                              color: sharedColors[
                                  group.x.toInt() % sharedColors.length],
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
                        return const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: RotatedBox(
                            quarterTurns: 1,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
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
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.white24, width: 1),
                    left: BorderSide(color: Colors.white24, width: 1),
                  ),
                ),
                barGroups: _getBarChartGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarChartGroups() {
    return movieRevenues!.asMap().entries.map((entry) {
      final index = entry.key;
      final revenue = entry.value.totalRevenue;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: revenue.toDouble(),
            color: sharedColors[index % sharedColors.length],
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  Widget _buildTop5Customers() {
    if (top5Customers == null || top5Customers!.isEmpty) {
      return const Text(
        'No customer data available',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      );
    }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Top 5 Customers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: top5Customers!.map((customer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800]!,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${customer.name} ${customer.surname}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${formatNumber(customer.totalSpent)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
