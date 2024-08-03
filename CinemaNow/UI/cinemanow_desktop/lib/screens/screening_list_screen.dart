import 'package:cinemanow_desktop/models/screening.dart';
import 'package:cinemanow_desktop/models/search_result.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/widgets/date_picker.dart';
import 'package:cinemanow_desktop/screens/add_screening_screen.dart';
import 'package:cinemanow_desktop/widgets/screening_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  _ScreeningListScreenState createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen> {
  late ScreeningProvider provider;
  SearchResult<Screening>? result;
  final TextEditingController _ftsEditingController = TextEditingController();
  DateTime? _selectedDate;
  bool _noScreeningsAvailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchScreenings();
  }

  @override
  void initState() {
    super.initState();
    _fetchScreenings();
  }

  Future<void> _fetchScreenings({String? fts, DateTime? date}) async {
    try {
      final provider = context.read<ScreeningProvider>();
      result = await provider.getScreenings(fts: fts, date: date);
      setState(() {
        _noScreeningsAvailable = result?.result.isEmpty ?? true;
      });
    } catch (e) {
      // Handle error
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
                    controller: _ftsEditingController,
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
          child: DatePicker(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            await _fetchScreenings(
              fts: _ftsEditingController.text,
              date: _selectedDate,
            );
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddScreeningScreen(
                  onScreeningAdded: () {
                    _fetchScreenings();
                  },
                ),
              ),
            );
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
            'Add',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    if (_noScreeningsAvailable) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'No Screenings Available',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date or search term.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth > 800) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1,
            ),
            itemCount: result?.result.length,
            itemBuilder: (context, index) {
              String? imageUrl = result?.result[index].movie?.imageBase64;
              return ScreeningCard(
                imageUrl: imageUrl != null
                    ? 'data:image/jpeg;base64,$imageUrl'
                    : 'assets/images/default.jpg',
                title: result?.result[index].movie?.title ?? 'Unknown Title',
                date: result?.result[index].dateTime != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(result!.result[index].dateTime!)
                    : 'Unknown Date',
                time: result?.result[index].dateTime != null
                    ? DateFormat('HH:mm')
                        .format(result!.result[index].dateTime!)
                    : 'Unknown Time',
                hall: result?.result[index].hall?.name ?? 'Unknown Hall',
                viewMode:
                    result?.result[index].viewMode?.name ?? 'Unknown View Mode',
                price: result?.result[index].price != null
                    ? result!.result[index].price.toString()
                    : 'Unknown Price',
                screeningId: result?.result[index].id ?? 0,
                onDelete: _fetchScreenings,
              );
            },
          );
        },
      ),
    );
  }
}
