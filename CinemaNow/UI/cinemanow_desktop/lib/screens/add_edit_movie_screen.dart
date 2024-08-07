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
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  String? _imageBase64;

  @override
  void initState() {
    super.initState();
    if (widget.movieId != null) {
      _isEditing = true;
      _fetchMovieDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
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
      _isLoading = false;
    });
  }

  Future<void> _submitMovie() async {
    if (_titleController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _synopsisController.text.isEmpty) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Duration must be a positive number.'),
          ),
        );
        return;
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
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movie successfully updated!'),
          ),
        );
        widget.onMovieUpdated?.call();
      } else {
        final movieId = await movieProvider.addMovie(
          _titleController.text,
          duration,
          _synopsisController.text,
          _imageBase64,
        );

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
                      buildInputField(
                        context,
                        'Duration',
                        'Enter duration in minutes',
                        Icons.timer,
                        controller: _durationController,
                      ),
                      buildInputField(
                        context,
                        'Synopsis',
                        'Enter synopsis',
                        Icons.description,
                        controller: _synopsisController,
                      ),
                      buildInputField(
                        context,
                        'Image',
                        'Select image',
                        Icons.image,
                        readOnly: true,
                        onTap: _pickImage,
                      ),
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 20),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              _selectedImage!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
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
}
