import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cinemanow_mobile/models/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Movie Poster
                if (movie.imageBase64 != null)
                  Image.memory(
                    base64Decode(movie.imageBase64!),
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.cover,
                  ),
                // Rating
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
                  // Movie Title
                  Text(
                    movie.title ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Genres
                  Wrap(
                    spacing: 8,
                    children: movie.genres
                            ?.map((genre) => Chip(
                                  label: Text(genre.name ?? '',
                                      style: const TextStyle(color: Colors.white)),
                                  backgroundColor: Colors.grey[800],
                                ))
                            .toList() ??
                        [],
                  ),
                  const SizedBox(height: 16),
                  // Actors
                  /*SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movie.actors?.length ?? 0,
                      itemBuilder: (context, index) {
                        final actor = movie.actors![index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: actor.imageBase64 != null
                                    ? MemoryImage(
                                        base64Decode(actor.imageBase64!))
                                    : null,
                                child: actor.imageBase64 == null
                                    ? Icon(Icons.person, color: Colors.white)
                                    : null,
                                backgroundColor: Colors.grey[800],
                              ),
                              SizedBox(height: 4),
                              Text(actor.name ?? '',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16),*/
                  // Synopsis
                  Text(
                    movie.synopsis ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  // Booking Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement booking functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Booking',
                          style: TextStyle(color: Colors.white)),
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
}
