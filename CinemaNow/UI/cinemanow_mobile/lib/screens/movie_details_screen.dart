import 'package:cinemanow_mobile/models/screening.dart';
import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';
import 'package:cinemanow_mobile/screens/movie_ratings_screen.dart';
import 'package:cinemanow_mobile/screens/screening_booking_screen.dart';
import 'package:cinemanow_mobile/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cinemanow_mobile/models/movie.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Movie _movie;
  bool _isLoading = true;
  List<Screening> _screenings = [];
  List<Movie> _recommendations = [];
  List<Movie> _filteredRecommendations = [];

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_movie.id != null) {
      try {
        final movieProvider = context.read<MovieProvider>();
        final screeningProvider = context.read<ScreeningProvider>();

        final results = await Future.wait([
          movieProvider.getById(_movie.id!),
          screeningProvider.getScreeningsByMovieId(_movie.id!),
          movieProvider.getRecommendations(_movie.id!),
        ]);

        if (mounted) {
          final List<Movie> recommendations = results[2] as List<Movie>;

          _filteredRecommendations =
              await _filterRecommendationsWithActiveScreenings(
            recommendations,
            screeningProvider,
          );

          setState(() {
            _movie = results[0] as Movie;
            _screenings = results[1] as List<Screening>;
            _recommendations = recommendations;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading movie details: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie ID is null. Cannot load details.')),
      );
    }
  }

  Future<List<Movie>> _filterRecommendationsWithActiveScreenings(
    List<Movie> recommendations,
    ScreeningProvider screeningProvider,
  ) async {
    List<Movie> filteredMovies = [];

    for (var movie in recommendations) {
      if (movie.id != null) {
        final screenings =
            await screeningProvider.getScreeningsByMovieId(movie.id!);
        if (screenings.any((screening) => screening.stateMachine == 'active')) {
          filteredMovies.add(movie);
        }
      }
    }

    return filteredMovies;
  }

  Future<void> _fetchFullMovieDetails() async {
    try {
      final movieProvider = context.read<MovieProvider>();
      final fullMovie = await movieProvider.getById(_movie.id!);
      setState(() {
        _movie = fullMovie;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildRecommendationsSection() {
    if (_filteredRecommendations.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: const Text(
          'No recommendations available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'More like this',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filteredRecommendations.length,
            itemBuilder: (context, index) {
              final movie = _filteredRecommendations[index];
              return GestureDetector(
                onTap: () async {
                  if (movie.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsScreen(movie: movie),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Selected movie does not have a valid ID.')),
                    );
                  }
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: movie.imageBase64 != null
                            ? Image.memory(
                                base64Decode(movie.imageBase64!),
                                height: 160,
                                width: 130,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/default.jpg',
                                height: 160,
                                width: 130,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showScreeningSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: _screenings.length,
            itemBuilder: (context, index) {
              final screening = _screenings[index];
              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.movie,
                    color: Colors.red,
                    size: 40,
                  ),
                  title: Text(
                    DateFormat('MMM d, yyyy HH:mm').format(screening.dateTime!),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hall: ${screening.hall?.name ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'View Mode: ${screening.viewMode?.name ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Price: \$${screening.price?.toStringAsFixed(2) ?? 'N/A'}',
                        style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: Colors.red,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreeningBookingScreen(
                          movieId: _movie.id!,
                          screeningId: screening.id!,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(
          color: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.red,
            ))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      _buildMovieImage(),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: GestureDetector(
                          onTap: () async {
                            final hasChanges =
                                await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieRatingsScreen(movieId: _movie.id!),
                              ),
                            );
                            if (hasChanges == true) {
                              _fetchFullMovieDetails();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  _movie.averageRating != null
                                      ? '${_movie.averageRating!.toStringAsFixed(1)}/5'
                                      : 'N/A',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _movie.title ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children:
                              _movie.genres != null && _movie.genres!.isNotEmpty
                                  ? _movie.genres!
                                      .map((genre) => Chip(
                                            label: Text(
                                              genre.name ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.grey[800],
                                          ))
                                      .toList()
                                  : [
                                      const Text(
                                        'No genres available',
                                      ),
                                    ],
                        ),
                        const SizedBox(height: 16),
                        if (_movie.actors != null &&
                            _movie.actors!.isNotEmpty) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 90),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _movie.actors!.length,
                              itemBuilder: (context, index) {
                                final actor = _movie.actors![index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            actor.imageBase64 != null
                                                ? MemoryImage(base64Decode(
                                                    actor.imageBase64!))
                                                : null,
                                        backgroundColor: Colors.grey[800],
                                        child: actor.imageBase64 == null
                                            ? const Icon(Icons.person,
                                                color: Colors.white)
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${actor.name ?? ''} ${actor.surname ?? ''}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ] else ...[
                          const Text('No actors available',
                              style: TextStyle(color: Colors.white)),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          _movie.synopsis ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        _buildRecommendationsSection(),
                        const SizedBox(height: 24),
                        Center(
                          child: buildButton(
                            text: 'Booking',
                            onPressed: _showScreeningSelection,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMovieImage() {
    if (_movie.imageBase64 != null && _movie.imageBase64!.isNotEmpty) {
      return Image.memory(
        base64Decode(_movie.imageBase64!),
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/default.jpg',
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
      );
    }
  }
}
