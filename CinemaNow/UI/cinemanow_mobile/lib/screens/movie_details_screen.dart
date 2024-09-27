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

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _fetchFullMovieDetails();
    _fetchScreenings();
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

  Future<void> _fetchScreenings() async {
    try {
      final screeningProvider = context.read<ScreeningProvider>();
      final screenings =
          await screeningProvider.getScreeningsByMovieId(_movie.id!);
      setState(() {
        _screenings = screenings;
      });
    } catch (e) {
      // Handle error
    }
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
                          children: _movie.genres
                                  ?.map((genre) => Chip(
                                        label: Text(genre.name ?? '',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        backgroundColor: Colors.grey[800],
                                      ))
                                  .toList() ??
                              [],
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
