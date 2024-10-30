import 'package:cinemanow_desktop/models/actor.dart';
import 'package:cinemanow_desktop/models/genre.dart';
import 'package:cinemanow_desktop/providers/actor_provider.dart';
import 'package:cinemanow_desktop/providers/genre_provider.dart';
import 'package:cinemanow_desktop/widgets/multi_select_section.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/providers/movie_provider.dart';
import 'package:cinemanow_desktop/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditMovieScreen extends StatefulWidget {
  final int? movieId;
  final VoidCallback? onMovieAdded;
  final VoidCallback? onMovieUpdated;

  const AddEditMovieScreen({
    super.key,
    this.movieId,
    this.onMovieAdded,
    this.onMovieUpdated,
  });

  @override
  _AddEditMovieScreenState createState() => _AddEditMovieScreenState();
}

class _AddEditMovieScreenState extends State<AddEditMovieScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  String? _durationErrorMessage;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  String? _imageBase64;
  List<Actor> _allActors = [];
  List<Actor> _selectedActors = [];
  List<Genre> _allGenres = [];
  List<Genre> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    _fetchAllActors();
    _fetchAllGenres();
    if (widget.movieId != null) {
      _isEditing = true;
      _fetchMovieDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAllActors() async {
    final actorProvider = Provider.of<ActorProvider>(context, listen: false);
    try {
      final searchResult = await actorProvider.getActors();
      setState(() {
        _allActors = searchResult.result;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchAllGenres() async {
    final genreProvider = Provider.of<GenreProvider>(context, listen: false);
    try {
      final searchResult = await genreProvider.getGenres();
      setState(() {
        _allGenres = searchResult.result;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageBase64 = base64Encode(_selectedImage!.readAsBytesSync());
      });
    }
  }

  Future<void> _fetchMovieDetails() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    final movie = await movieProvider.getMovieById(widget.movieId!);

    setState(() {
      _titleController.text = movie.title ?? '';
      _durationController.text = movie.duration?.toString() ?? '';
      _synopsisController.text = movie.synopsis ?? '';
      _imageBase64 = movie.imageBase64 ?? '';

      if (movie.actors != null) {
        _selectedActors = movie.actors!.toList();
      }

      if (movie.genres != null) {
        _selectedGenres = movie.genres!.toList();
      }

      _isLoading = false;
    });
  }

  Future<void> _submitMovie() async {
    if (_titleController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _synopsisController.text.isEmpty ||
        _selectedActors.isEmpty ||
        _selectedGenres.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    try {
      final duration = int.tryParse(_durationController.text);

      if (duration == null || duration <= 0) {
        setState(() {
          _durationErrorMessage = 'Duration must be a positive number.';
        });
        return;
      } else {
        setState(() {
          _durationErrorMessage = null;
        });
      }

      final movieProvider = Provider.of<MovieProvider>(context, listen: false);

      if (_isEditing) {
        if (widget.movieId == null) {
          throw Exception('Movie ID is null');
        }
        await movieProvider.updateMovie(
            widget.movieId!,
            _titleController.text,
            duration,
            _synopsisController.text,
            _imageBase64,
            _selectedActors,
            _selectedGenres);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movie successfully updated!'),
          ),
        );
        widget.onMovieUpdated?.call();
      } else {
        await movieProvider.addMovie(
            _titleController.text,
            duration,
            _synopsisController.text,
            _imageBase64,
            _selectedActors,
            _selectedGenres);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movie successfully added!'),
          ),
        );
        widget.onMovieAdded?.call();
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Failed to edit movie: $e'
              : 'Failed to add movie: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing ? 'Edit Movie' : 'Add a New Movie',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildInputField(
                        context,
                        'Title',
                        'Enter title',
                        Icons.movie,
                        controller: _titleController,
                      ),
                      buildInputField(context, 'Duration',
                          'Enter duration in minutes', Icons.timer,
                          controller: _durationController,
                          errorMessage: _durationErrorMessage),
                      buildInputField(
                        context,
                        'Synopsis',
                        'Enter synopsis',
                        Icons.description,
                        controller: _synopsisController,
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: buildInputField(
                          context,
                          'Image',
                          'Select image',
                          Icons.image,
                          readOnly: true,
                          cursor: SystemMouseCursors.click,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildActorSelection(),
                      const SizedBox(height: 10),
                      _buildGenreSelection(),
                      if (_imageBase64 != null && _imageBase64!.isNotEmpty) ...[
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.memory(
                              base64Decode(_imageBase64!),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _imageBase64 = null;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[850],
                            ),
                            child: const Text(
                              'Remove Image',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[850],
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text(
                                'Back',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _submitMovie,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0, vertical: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Save',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActorSelection() {
    return MultiSelectSection<Actor>(
      allItems: _allActors,
      selectedItems: _selectedActors,
      title: 'Select Actors',
      buttonText: 'Choose Actors',
      labelText: 'Actors',
      onConfirm: (selected) {
        setState(() {
          _selectedActors = selected;
        });
      },
      itemLabel: (actor) => '${actor.name} ${actor.surname}',
      onItemTap: (actor) {
        setState(() {
          _selectedActors.remove(actor);
        });
      },
    );
  }

  Widget _buildGenreSelection() {
    return MultiSelectSection<Genre>(
      allItems: _allGenres,
      selectedItems: _selectedGenres,
      title: 'Select Genres',
      buttonText: 'Choose Genres',
      labelText: 'Genres',
      onConfirm: (selected) {
        setState(() {
          _selectedGenres = selected;
        });
      },
      itemLabel: (genre) => '${genre.name}',
      onItemTap: (genre) {
        setState(() {
          _selectedGenres.remove(genre);
        });
      },
    );
  }
}
