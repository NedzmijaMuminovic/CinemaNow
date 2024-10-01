import 'dart:convert';

import 'package:cinemanow_mobile/models/movie.dart';
import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/models/search_result.dart';
import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';
import 'package:cinemanow_mobile/screens/movie_details_screen.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:cinemanow_mobile/widgets/date_picker.dart';
import 'package:cinemanow_mobile/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MovieScreeningListScreen extends StatefulWidget {
  const MovieScreeningListScreen({super.key});

  @override
  _MovieScreeningListScreenState createState() =>
      _MovieScreeningListScreenState();
}

class _MovieScreeningListScreenState extends State<MovieScreeningListScreen>
    with SingleTickerProviderStateMixin {
  late ScreeningProvider provider;
  SearchResult<Screening>? result;
  final TextEditingController _ftsEditingController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  Map<Movie, List<Screening>> _groupedScreenings = {};

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
      final movieProvider = context.read<MovieProvider>();
      final screeningProvider = context.read<ScreeningProvider>();

      final SearchResult<Movie> searchResult =
          await movieProvider.getMovies(fts: fts);
      final List<Movie> movies = searchResult.result;

      final Map<Movie, List<Screening>> screeningsByMovie = {};

      for (var movie in movies) {
        final List<Screening> screenings =
            await screeningProvider.getScreeningsByMovieId(
          movie.id!,
          date: date,
        );

        if (screenings.isNotEmpty) {
          screeningsByMovie[movie] = screenings;
        }
      }

      setState(() {
        _groupedScreenings = screeningsByMovie;
      });
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
    return Expanded(
      child: _groupedScreenings.isEmpty
          ? const Center(
              child: NoScreeningsView(
              title: 'No Screenings Available',
              message: 'Try selecting a different date or search term.',
              icon: Icons.movie,
            ))
          : ListView.builder(
              itemCount: _groupedScreenings.keys.length,
              itemBuilder: (context, index) {
                final movie = _groupedScreenings.keys.elementAt(index);
                final screenings = _groupedScreenings[movie]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 20.0),
                  child: _buildMovieCard(movie, screenings),
                );
              },
            ),
    );
  }

  Widget _buildMovieCard(Movie movie, List<Screening> screenings) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MovieDetailsScreen(movie: movie),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.grey[850],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: movie.imageBase64 != null
                    ? Image.memory(
                        base64Decode(movie.imageBase64!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      )
                    : Image.asset(
                        'assets/images/default.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'Unknown Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.duration ?? 0} min',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.movie, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (movie.genres ?? [])
                              .map((genre) => genre.name)
                              .join(', '),
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ExpansionTile(
              title: const Text(
                'View Screenings',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconColor: Colors.red,
              collapsedIconColor: Colors.red,
              children: screenings
                  .map((screening) => _buildScreeningTile(screening))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningTile(Screening screening) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(screening.dateTime!),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(screening.dateTime!),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${screening.hall?.name ?? 'Unknown Hall'} - ${screening.viewMode?.name ?? 'Unknown View Mode'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red[700],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '\$${formatNumber(screening.price)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
