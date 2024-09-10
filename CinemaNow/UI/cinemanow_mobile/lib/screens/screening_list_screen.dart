import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';
import 'package:cinemanow_mobile/widgets/date_picker.dart';
import 'package:cinemanow_mobile/widgets/screening_card.dart';
import 'package:cinemanow_mobile/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  _ScreeningListScreenState createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen>
    with SingleTickerProviderStateMixin {
  late ScreeningProvider provider;
  SearchResult<Screening>? result;
  final TextEditingController _ftsEditingController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

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
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<ScreeningProvider>();
      result = await provider.getScreenings(fts: fts, date: date);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSearch(),
                const SizedBox(height: 16),
                _isLoading
                    ? const Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                        color: Colors.red,
                      )))
                    : _buildResultView(),
              ],
            ),
          ),
        ],
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
                  child: TextSelectionTheme(
                    data: const TextSelectionThemeData(
                      selectionColor: Colors.red,
                    ),
                    child: TextField(
                      controller: _ftsEditingController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                      cursorColor: Colors.red,
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
            minimumSize: const Size(0, 50),
          ),
          child: Text(
            'Search',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final List<Screening> filteredScreenings =
        result?.result.where((screening) {
              return screening.stateMachine == 'active';
            }).toList() ??
            [];

    if (filteredScreenings.isEmpty) {
      return _buildNoScreeningsView();
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
            itemCount: filteredScreenings.length,
            itemBuilder: (context, index) {
              final screening = filteredScreenings[index];
              String? imageUrl = screening.movie?.imageBase64;
              return ScreeningCard(
                imageUrl: imageUrl != null
                    ? 'data:image/jpeg;base64,$imageUrl'
                    : 'assets/images/default.jpg',
                title: screening.movie?.title ?? 'Unknown Title',
                date: screening.dateTime != null
                    ? DateFormat('dd/MM/yyyy').format(screening.dateTime!)
                    : 'Unknown Date',
                time: screening.dateTime != null
                    ? DateFormat('HH:mm').format(screening.dateTime!)
                    : 'Unknown Time',
                hall: screening.hall?.name ?? 'Unknown Hall',
                viewMode: screening.viewMode?.name ?? 'Unknown View Mode',
                price: screening.price != null
                    ? formatNumber(screening.price)
                    : 'Unknown Price',
                screeningId: screening.id ?? 0,
                onDelete: _fetchScreenings,
                onScreeningUpdated: _fetchScreenings,
                stateMachine: screening.stateMachine ?? 'unknown',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoScreeningsView() {
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
}
