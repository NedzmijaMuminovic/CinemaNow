import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinemanow_desktop/providers/report_provider.dart';
import 'package:cinemanow_desktop/utilities/report_generator.dart';

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
  final ReportGenerator _reportGenerator = ReportGenerator();

  @override
  void initState() {
    super.initState();
    fetchUserCount();
    fetchTotalIncome();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
        ),
        child: Center(
          child: userCount == null || totalIncome == null
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoCard(
                      'App Users',
                      userCount == -1 ? 'Error fetching data' : '$userCount',
                      Icons.people,
                    ),
                    const SizedBox(height: 20),
                    _buildInfoCard(
                      'Cinema Income',
                      totalIncome == -1
                          ? 'Error fetching data'
                          : '\$${totalIncome!.toStringAsFixed(2)}',
                      Icons.attach_money,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await fetchUserCount();
                        await fetchTotalIncome();

                        _reportGenerator.generateReportPdf(
                            userCount ?? 0, totalIncome ?? 0);
                      },
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
                            horizontal: 20, vertical: 15),
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
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
