import 'package:cinemanow_desktop/providers/role_provider.dart';
import 'package:cinemanow_desktop/providers/user_provider.dart';
import 'package:cinemanow_desktop/utilities/validator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditAdminScreen extends StatefulWidget {
  final int? userId;
  final VoidCallback? onAdminAdded;
  final VoidCallback? onAdminUpdated;

  const AddEditAdminScreen({
    super.key,
    this.userId,
    this.onAdminAdded,
    this.onAdminUpdated,
  });

  @override
  _AddEditAdminScreenState createState() => _AddEditAdminScreenState();
}

class _AddEditAdminScreenState extends State<AddEditAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  String? _nameError;
  String? _surnameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _passwordConfirmationError;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  String? _imageBase64;
  bool _isFormSubmitted = false;
  final bool _isPasswordVisible = false;
  final bool _isPasswordConfirmationVisible = false;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_clearNameError);
    _surnameController.addListener(_clearSurnameError);
    _emailController.addListener(_clearEmailError);
    _usernameController.addListener(_clearUsernameError);
    _passwordController.addListener(_clearPasswordError);
    _passwordConfirmationController
        .addListener(_clearPasswordConfirmationError);

    if (widget.userId != null) {
      _isEditing = true;
      _fetchAdminDetails();
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

  void _clearEmailError() {
    if (_isFormSubmitted) {
      setState(() {
        _emailError = _emailController.text.isEmpty
            ? 'Please fill in this field.'
            : Validator.validateEmail(_emailController.text);
      });
    }
  }

  void _clearUsernameError() {
    if (_isFormSubmitted) {
      setState(() {
        _usernameError = _usernameController.text.isEmpty
            ? 'Please fill in this field.'
            : Validator.validateUsername(_usernameController.text);
      });
    }
  }

  void _clearPasswordError() {
    if (_isFormSubmitted) {
      setState(() {
        final password = _passwordController.text;
        _passwordError = password.isEmpty
            ? 'Please fill in this field.'
            : Validator.validatePassword(password);
      });
    }
  }

  void _clearPasswordConfirmationError() {
    if (_isFormSubmitted) {
      setState(() {
        final password = _passwordController.text;
        final confirmPassword = _passwordConfirmationController.text;
        _passwordConfirmationError = confirmPassword.isEmpty
            ? 'Please fill in this field.'
            : Validator.validatePasswordConfirmation(password, confirmPassword);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAdminDetails() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final admin = await userProvider.getUserById(widget.userId!);

    setState(() {
      _nameController.text = admin.name ?? '';
      _surnameController.text = admin.surname ?? '';
      _imageBase64 = admin.imageBase64 ?? '';

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

  Future<void> _submitAdmin() async {
    setState(() {
      _isFormSubmitted = true;
      _nameError = _nameController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateName(_nameController.text);
      _surnameError = _surnameController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateSurname(_surnameController.text);
      _emailError = _emailController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateEmail(_emailController.text);
      _usernameError = _usernameController.text.isEmpty
          ? 'Please fill in this field.'
          : Validator.validateUsername(_usernameController.text);

      final password = _passwordController.text;
      final confirmPassword = _passwordConfirmationController.text;

      if (password.isEmpty) {
        _passwordError = 'Please fill in this field.';
      } else {
        _passwordError = Validator.validatePassword(password);
      }

      if (confirmPassword.isEmpty) {
        _passwordConfirmationError = 'Please fill in this field.';
      } else {
        _passwordConfirmationError = Validator.validatePasswordConfirmation(
          password,
          confirmPassword,
        );
      }
    });

    if (_nameError != null ||
        _surnameError != null ||
        _emailError != null ||
        _usernameError != null ||
        _passwordError != null ||
        _passwordConfirmationError != null) {
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (await userProvider.isUsernameTaken(
          widget.userId ?? 0, _usernameController.text)) {
        setState(() {
          _usernameError =
              'Username already exists. Please choose another one.';
        });
        return;
      }

      final roleProvider = Provider.of<RoleProvider>(context, listen: false);

      final adminRole = await roleProvider.fetchRoleByName("Admin");

      if (_isEditing) {
        if (widget.userId == null) {
          throw Exception('Admin ID is null');
        }
        await userProvider.updateUser(
          widget.userId!,
          _nameController.text,
          _surnameController.text,
          _emailController.text,
          _usernameController.text,
          _passwordController.text,
          _passwordConfirmationController.text,
          _imageBase64,
          [adminRole.id!],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin successfully updated!'),
          ),
        );
        widget.onAdminUpdated?.call();
      } else {
        await userProvider.insert({
          'name': _nameController.text,
          'surname': _surnameController.text,
          'email': _emailController.text,
          'username': _usernameController.text,
          'password': _passwordController.text,
          'passwordConfirmation': _passwordConfirmationController.text,
          'imageBase64': _imageBase64,
          'roleIds': [adminRole.id],
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin successfully added!'),
          ),
        );
        widget.onAdminAdded?.call();
      }

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Failed to edit admin: $e'
              : 'Failed to add admin: $e'),
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
                        _isEditing ? 'Edit Admin' : 'Add a New Admin',
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
                      buildInputField(
                        context,
                        'Email',
                        'Enter email',
                        Icons.email,
                        controller: _emailController,
                        errorMessage: _emailError,
                      ),
                      buildInputField(
                        context,
                        'Username',
                        'Enter username',
                        Icons.account_circle,
                        controller: _usernameController,
                        errorMessage: _usernameError,
                      ),
                      buildInputField(
                        context,
                        'Password',
                        'Enter password',
                        Icons.lock,
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        errorMessage: _passwordError,
                      ),
                      buildInputField(
                        context,
                        'Password Confirmation',
                        'Confirm password',
                        Icons.lock,
                        controller: _passwordConfirmationController,
                        obscureText: !_isPasswordConfirmationVisible,
                        errorMessage: _passwordConfirmationError,
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
                              onPressed: _submitAdmin,
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
