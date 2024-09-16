import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_mobile/models/rating.dart';
import 'package:cinemanow_mobile/providers/rating_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class MovieRatingsScreen extends StatefulWidget {
  final int movieId;

  const MovieRatingsScreen({super.key, required this.movieId});

  @override
  _MovieRatingsScreenState createState() => _MovieRatingsScreenState();
}

class _MovieRatingsScreenState extends State<MovieRatingsScreen> {
  late Future<List<Rating>> _ratingsFuture;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = _fetchRatings();
  }

  Future<String> _fetchMovieTitle() async {
    try {
      final movieProvider = context.read<MovieProvider>();
      final movie = await movieProvider.getById(widget.movieId);
      return movie.title!;
    } catch (e) {
      return 'Movie Ratings';
    }
  }

  Future<List<Rating>> _fetchRatings() async {
    try {
      final ratingProvider = context.read<RatingProvider>();
      final ratings = await ratingProvider.getByMovieId(widget.movieId);
      return ratings;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchMovieTitle(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return Text(snapshot.data ?? 'Movie Ratings');
            }
          },
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<List<Rating>>(
        future: _ratingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.white70,
                    size: 50,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No ratings available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            );
          } else {
            final ratings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: rating.user?.imageBase64 != null
                            ? MemoryImage(
                                base64Decode(rating.user!.imageBase64!))
                            : null,
                        backgroundColor: Colors.grey[700],
                        child: rating.user?.imageBase64 == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${rating.user?.name ?? ''} ${rating.user?.surname ?? ''}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Spacer(),
                                _buildStarRating(rating.value ?? 0),
                              ],
                            ),
                            if (rating.comment != null &&
                                rating.comment!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                rating.comment!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildStarRating(int ratingValue) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < ratingValue ? Icons.star : Icons.star_border,
          color: Colors.red,
          size: 20,
        ),
      ),
    );
  }
}
