import 'package:cinemanow_desktop/providers/movie_provider.dart';
import 'package:cinemanow_desktop/screens/add_edit_movie_screen.dart';
import 'package:cinemanow_desktop/widgets/base_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MovieCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String synopsis;
  final int movieId;
  final VoidCallback onDelete;
  final VoidCallback onMovieUpdated;

  const MovieCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.synopsis,
    required this.movieId,
    required this.onDelete,
    required this.onMovieUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      imageUrl: imageUrl,
      content: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Text(
              synopsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditMovieScreen(
                  movieId: movieId,
                  onMovieUpdated: onMovieUpdated,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[700],
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Edit', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final shouldDelete = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'Confirm Deletion',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to delete this movie?',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.grey[900],
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child:
                          const Text('No', style: TextStyle(color: Colors.red)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );

            if (shouldDelete == true) {
              try {
                final provider =
                    Provider.of<MovieProvider>(context, listen: false);
                await provider.deleteMovie(movieId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Movie successfully deleted!')),
                );
                onDelete();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete movie')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          icon: const Icon(Icons.delete, color: Colors.white),
          label: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
