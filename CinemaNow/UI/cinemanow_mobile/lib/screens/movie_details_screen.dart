import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cinemanow_mobile/models/movie.dart';
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

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _fetchFullMovieDetails();
  }

  Future<void> _fetchFullMovieDetails() async {
    try {
      final movieProvider = context.read<MovieProvider>();
      final fullMovie = await movieProvider.getMovieById(_movie.id!);
      setState(() {
        _movie = fullMovie;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching movie details: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                '6.9/10',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Booking',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
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
