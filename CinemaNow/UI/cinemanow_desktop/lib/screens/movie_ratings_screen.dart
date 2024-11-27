import 'package:flutter/material.dart';
import 'package:cinemanow_desktop/models/rating.dart';
import 'package:cinemanow_desktop/providers/rating_provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ratingsFuture = _fetchRatings();
  }

  Future<String> _fetchMovieTitle() async {
    try {
      final ratingProvider = context.read<RatingProvider>();
      final ratings = await ratingProvider.getByMovieId(widget.movieId);
      return ratings.isNotEmpty
          ? ratings.first.movie?.title ?? 'Movie Ratings'
          : 'Movie Ratings';
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

  void _deleteRating(Rating rating) async {
    try {
      final ratingProvider = context.read<RatingProvider>();
      await ratingProvider.deleteRating(rating.id!);
      _refreshRatings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You have successfully deleted the rating!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete rating.')),
      );
    }
  }

  void _refreshRatings() {
    setState(() {
      _ratingsFuture = _fetchRatings();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _fetchMovieTitle(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...',
                  style: TextStyle(color: Colors.white70, fontSize: 22));
            } else {
              return Text(
                snapshot.data ?? 'Movie Ratings',
                style: const TextStyle(color: Colors.white70, fontSize: 22),
              );
            }
          },
        ),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<List<Rating>>(
        future: _ratingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 5,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
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
                    size: 80,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No ratings available',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 24,
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
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                final rating = ratings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: rating.user?.imageBase64 != null &&
                                rating.user!.imageBase64!.isNotEmpty
                            ? MemoryImage(
                                base64Decode(rating.user!.imageBase64!))
                            : null,
                        backgroundColor: Colors.grey[700],
                        child: (rating.user?.imageBase64 == null ||
                                rating.user!.imageBase64!.isEmpty)
                            ? const Icon(Icons.person,
                                color: Colors.white, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${rating.user?.name ?? ''} ${rating.user?.surname ?? ''}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                _buildStarRating(rating.value ?? 0),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    rating.comment?.isNotEmpty == true
                                        ? rating.comment!
                                        : 'User didn\'t leave a comment.',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  iconSize: 30,
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Confirm Deletion',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to delete this rating?',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.grey[900],
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: const Text(
                                                'No',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmed == true) {
                                      _deleteRating(rating);
                                    }
                                  },
                                ),
                              ],
                            ),
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
          size: 25,
        ),
      ),
    );
  }
}
