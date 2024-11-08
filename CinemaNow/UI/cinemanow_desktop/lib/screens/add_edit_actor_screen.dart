import 'package:cinemanow_desktop/providers/actor_provider.dart';
import 'package:cinemanow_desktop/utilities/validator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditActorScreen extends StatefulWidget {
  final int? actorId;
  final VoidCallback? onActorAdded;
  final VoidCallback? onActorUpdated;

  const AddEditActorScreen({
    super.key,
    this.actorId,
    this.onActorAdded,
    this.onActorUpdated,
  });

  @override
  _AddEditActorScreenState createState() => _AddEditActorScreenState();
}

class _AddEditActorScreenState extends State<AddEditActorScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  String? _nameError;
  String? _surnameError;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  String? _imageBase64;
  bool _isFormSubmitted = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_clearNameError);
    _surnameController.addListener(_clearSurnameError);

    if (widget.actorId != null) {
      _isEditing = true;
      _fetchActorDetails();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearNameError() {
    if (_isFormSubmitted) {
      setState(() {
        _nameError = _nameController.text.isEmpty
            ? 'Please fill in this field.'
            : Validator.validateName(_nameController.text);
      });
    }
  }

  void _clearSurnameError() {
    if (_isFormSubmitted) {
      setState(() {
        _surnameError = _surnameController.text.isEmpty
            ? 'Please fill in this field.'
            : Validator.validateSurname(_surnameController.text);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  Future<void> _fetchActorDetails() async {
    final actorProvider = Provider.of<ActorProvider>(context, listen: false);

    final actor = await actorProvider.getActorById(widget.actorId!);

    setState(() {
      _nameController.text = actor.name ?? '';
      _surnameController.text = actor.surname ?? '';
      _imageBase64 = actor.imageBase64 ?? '';

      _isLoading = false;
    });
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

  Future<void> _submitActor() async {
    setState(() {
      _isFormSubmitted = true;
      _nameError = _nameController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateName(_nameController.text);
      _surnameError = _surnameController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateSurname(_surnameController.text);
    });

    if (_nameError != null || _surnameError != null) {
      return;
    }

    try {
      final actorProvider = Provider.of<ActorProvider>(context, listen: false);

      if (_isEditing) {
        if (widget.actorId == null) {
          throw Exception('Actor ID is null');
        }
        await actorProvider.updateActor(
          widget.actorId!,
          _nameController.text,
          _surnameController.text,
          _imageBase64,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actor successfully updated!'),
          ),
        );
        widget.onActorUpdated?.call();
      } else {
        await actorProvider.addActor(
          _nameController.text,
          _surnameController.text,
          _imageBase64,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actor successfully added!'),
          ),
        );
        widget.onActorAdded?.call();
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Failed to edit actor: $e'
              : 'Failed to add actor: $e'),
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
                        _isEditing ? 'Edit Actor' : 'Add a New Actor',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildInputField(
                        context,
                        'Name',
                        'Enter name',
                        Icons.person,
                        controller: _nameController,
                        errorMessage: _nameError,
                      ),
                      buildInputField(
                        context,
                        'Surname',
                        'Enter surname',
                        Icons.person_outline,
                        controller: _surnameController,
                        errorMessage: _surnameError,
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
                      const SizedBox(height: 20),
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
                              onPressed: _submitActor,
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
