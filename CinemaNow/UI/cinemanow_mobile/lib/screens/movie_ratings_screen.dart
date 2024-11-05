import 'package:cinemanow_mobile/providers/auth_provider.dart';
import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/providers/user_provider.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _ratingsFuture = _fetchRatings();
  }

  Future<bool> _checkUserRating() async {
    final userId = AuthProvider.userId;
    if (userId == null) {
      return false;
    }

    final ratingProvider = context.read<RatingProvider>();
    final hasRated = await ratingProvider.hasUserRatedMovie(widget.movieId);
    return hasRated;
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
      final currentUserId = AuthProvider.userId;

      ratings.sort((a, b) {
        if (a.userId == currentUserId) return -1;
        if (b.userId == currentUserId) return 1;
        return b.id!.compareTo(a.id!);
      });

      return ratings;
    } catch (e) {
      return [];
    }
  }

  void _deleteRating(Rating rating) async {
    if (rating.userId != AuthProvider.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own ratings.')),
      );
      return;
    }

    try {
      final ratingProvider = context.read<RatingProvider>();
      await ratingProvider.deleteRating(rating.id!);
      _refreshRatings();
      setState(() {
        _hasChanges = true;
      });
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
          final navigator = Navigator.of(context);
          navigator.pop(_hasChanges);
        },
        child: Scaffold(
          appBar: AppBar(
            title: FutureBuilder<String>(
              future: _fetchMovieTitle(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading...',
                      style: TextStyle(color: Colors.white70));
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error',
                    style: TextStyle(color: Colors.white70),
                  );
                } else {
                  return Text(
                    snapshot.data ?? 'Movie Ratings',
                    style: const TextStyle(color: Colors.white70),
                  );
                }
              },
            ),
            backgroundColor: Colors.grey[850],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(_hasChanges);
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
                  controller: _scrollController,
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
                            backgroundImage: rating.user?.imageBase64 != null &&
                                    rating.user!.imageBase64!.isNotEmpty
                                ? MemoryImage(
                                    base64Decode(rating.user!.imageBase64!))
                                : null,
                            backgroundColor: Colors.grey[700],
                            child: (rating.user?.imageBase64 == null ||
                                    rating.user!.imageBase64!.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 16),
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
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child:
                                          _buildStarRating(rating.value ?? 0),
                                    ),
                                  ],
                                ),
                                if (rating.comment != null &&
                                    rating.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    rating.comment!,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'User didn\'t leave a comment.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                                if (rating.userId == AuthProvider.userId) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.white),
                                          label: const Text(
                                            'Edit',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            _showRatingDialog(
                                              initialRating: rating.value ?? 0,
                                              initialComment:
                                                  rating.comment ?? '',
                                              ratingId: rating.id,
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.white),
                                          label: const Text(
                                            'Delete',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () async {
                                            final confirmed =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Confirm Deletion',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this rating?',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey[900],
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
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
          floatingActionButton: FutureBuilder<bool>(
            future: _checkUserRating(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final bool hasRated = snapshot.data ?? false;

              if (hasRated) {
                return const SizedBox.shrink();
              }

              return FloatingActionButton.extended(
                onPressed: _showRatingDialog,
                icon: const Icon(Icons.star, color: Colors.white),
                label:
                    const Text('Rate', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red,
              );
            },
          ),
        ));
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

  void _showRatingDialog(
      {int initialRating = 0,
      String initialComment = '',
      int? ratingId}) async {
    int rating = initialRating;
    String comment = initialComment;
    TextEditingController commentController =
        TextEditingController(text: initialComment);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double starSize = (screenWidth < 360) ? 30 : 40;
        double dialogPadding = (screenWidth < 360) ? 8.0 : 24.0;

        return StatefulBuilder(builder: (context, setState) {
          if (commentController.text.isEmpty && initialComment.isNotEmpty) {
            commentController.text = initialComment;
          }
          return AlertDialog(
            backgroundColor: Colors.grey[850],
            title: Text(
              ratingId != null ? 'Edit your rating' : 'Rate this movie',
              style: const TextStyle(color: Colors.white),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: dialogPadding, vertical: 20),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: BoxConstraints(
                              minWidth: starSize, minHeight: starSize),
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.red,
                            size: 40,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment (optional)',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    cursorColor: Colors.red,
                    controller: commentController,
                    onChanged: (value) {
                      comment = value;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: rating > 0 ? Colors.white : Colors.grey,
                    backgroundColor: rating > 0 ? Colors.red : Colors.grey[700],
                  ),
                  onPressed: rating > 0
                      ? () async {
                          final ratingProvider = context.read<RatingProvider>();
                          final userProvider = context.read<UserProvider>();
                          final userId = AuthProvider.userId;
                          final user = await userProvider.getUserById(userId!);
                          final updatedRating = Rating(
                            id: ratingId,
                            movieId: widget.movieId,
                            userId: AuthProvider.userId,
                            value: rating,
                            comment: comment.isNotEmpty ? comment : null,
                            user: user,
                          );

                          try {
                            if (ratingId != null) {
                              await ratingProvider.updateRating(
                                  ratingId, updatedRating);
                            } else {
                              await ratingProvider.addRating(updatedRating);
                            }

                            Navigator.of(context).pop();
                            _refreshRatings();
                            _refreshUserRatingStatus();
                            setState(() {
                              _hasChanges = true;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ratingId != null
                                    ? 'You have successfully updated the rating!'
                                    : 'You have successfully added the rating!'),
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: rating > 0 ? Colors.white : Colors.grey[400],
                    ),
                  )),
            ],
          );
        });
      },
    );
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

  void _refreshUserRatingStatus() {
    setState(() {
      _checkUserRating();
    });
  }
}
