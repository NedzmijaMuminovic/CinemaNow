import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  _ScreeningListScreenState createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen> {
  ScreeningProvider provider = ScreeningProvider();
  List<Screening> result = [];
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchScreenings();
  }

  Future<void> _fetchScreenings() async {
    try {
      result = await provider.get();
      setState(() {});
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearch(),
            const SizedBox(height: 16),
            _buildResultView(),
          ],
        ),
      ),
    );
  }

  ThemeData _buildDarkDatePickerTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.grey[900],
      dialogBackgroundColor: Colors.grey[900],
      textTheme: const TextTheme(),
      colorScheme: const ColorScheme.dark(
        primary: Colors.red,
        onPrimary: Colors.white,
      ),
    );
  }

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: _buildDarkDatePickerTheme(context),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null && pickedDate != _selectedDate) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MM/dd/yyyy').format(_selectedDate),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await _fetchScreenings();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(0, 55),
          ),
          child: Text(
            'Search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(0, 55),
          ),
          child: Text(
            'Add a new screening',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 900) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: result.length,
            itemBuilder: (context, index) {
              return ScreeningCard(
                imageUrl: 'assets/images/default.jpg',
                title: result[index].movie?.title ?? 'Unknown Title',
                date: result[index].date != null
                    ? DateFormat('MM/dd/yyyy').format(result[index].date!)
                    : 'Unknown Date',
                time: result[index].time ?? 'Unknown Time',
                hall: result[index].hall ?? 'Unknown Hall',
              );
            },
          );
        },
      ),
    );
  }
}

class ScreeningCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String time;
  final String hall;

  const ScreeningCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
    required this.hall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.asset(
              imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        InfoRow(icon: Icons.calendar_today, text: date),
                        InfoRow(icon: Icons.access_time, text: time),
                        InfoRow(icon: Icons.location_on, text: hall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
