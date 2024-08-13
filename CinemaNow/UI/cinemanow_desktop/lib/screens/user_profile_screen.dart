import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:cinemanow_desktop/screens/login_screen.dart';
import 'package:cinemanow_desktop/utilities/validator.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_desktop/providers/user_provider.dart';
import 'package:cinemanow_desktop/models/user.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _passwordConfirmationController;
  final ValueNotifier<bool> _isEditingName = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingSurname = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingEmail = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingUsername = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingPassword = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isImageSelected = ValueNotifier<bool>(false);
  File? _selectedImage;
  String? _imageBase64;
  String? _nameError;
  String? _surnameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _passwordConfirmationError;

  void _validateName(String text) {
    setState(() {
      _nameError = Validator.validateName(text);
    });
  }

  void _validateSurname(String text) {
    setState(() {
      _surnameError = Validator.validateSurname(text);
    });
  }

  void _validateEmail(String text) {
    setState(() {
      _emailError = Validator.validateEmail(text);
    });
  }

  void _validateUsername(String text) {
    setState(() {
      _usernameError = Validator.validateUsername(text);
    });
  }

  void _validatePassword(String text) {
    setState(() {
      _passwordError = Validator.validatePassword(text);
    });
  }

  void _validatePasswordConfirmation(String text) {
    setState(() {
      _passwordConfirmationError = Validator.validatePasswordConfirmation(
        _passwordController.text,
        text,
      );
    });
  }

  Future<User?> _getUserData(BuildContext context) async {
    if (AuthProvider.userId != null) {
      final userProvider = UserProvider();
      return await userProvider.getUserById(AuthProvider.userId!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageBase64 = base64Encode(_selectedImage!.readAsBytesSync());
        _isImageSelected.value = true;
      });
    }
  }

  Future<void> _saveImage() async {
    if (_selectedImage != null) {
      await _updateUser(context);
      _isImageSelected.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmationController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: FutureBuilder<User?>(
        future: _getUserData(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          }

          final user = snapshot.data!;
          _nameController.text = user.name!;
          _surnameController.text = user.surname!;
          _emailController.text = user.email!;
          _usernameController.text = user.username!;
          if (_selectedImage == null) {
            _imageBase64 = user.imageBase64 ?? '';
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 100,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (user.imageBase64 != null
                                        ? MemoryImage(
                                            base64Decode(user.imageBase64!))
                                        : const AssetImage(
                                            'assets/images/default.jpg'))
                                    as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isImageSelected,
                          builder: (context, isImageSelected, child) {
                            return GestureDetector(
                              onTap: isImageSelected ? _saveImage : _pickImage,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    isImageSelected ? Icons.save : Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Hi, ${user.name}!\n',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const TextSpan(
                          text: 'Welcome!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildEditableProfileOption(
                    icon: Icons.person,
                    controller: _nameController,
                    isEditingNotifier: _isEditingName,
                    onEditToggle: () {
                      _isEditingName.value = !_isEditingName.value;
                    },
                    onSave: () async {
                      _isEditingName.value = false;
                      await _updateUser(context);
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.person,
                    controller: _surnameController,
                    isEditingNotifier: _isEditingSurname,
                    onEditToggle: () {
                      _isEditingSurname.value = !_isEditingSurname.value;
                    },
                    onSave: () async {
                      _isEditingSurname.value = false;
                      await _updateUser(context);
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.email,
                    controller: _emailController,
                    isEditingNotifier: _isEditingEmail,
                    onEditToggle: () {
                      _isEditingEmail.value = !_isEditingEmail.value;
                    },
                    onSave: () async {
                      _isEditingEmail.value = false;
                      await _updateUser(context);
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.account_circle,
                    controller: _usernameController,
                    isEditingNotifier: _isEditingUsername,
                    onEditToggle: () {
                      _isEditingUsername.value = !_isEditingUsername.value;
                    },
                    onSave: () async {
                      _isEditingUsername.value = false;
                      await _updateUser(context);
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.lock,
                    controller: _passwordController,
                    confirmationController: _passwordConfirmationController,
                    isEditingNotifier: _isEditingPassword,
                    onEditToggle: () {
                      _isEditingPassword.value = !_isEditingPassword.value;
                    },
                    onSave: () async {
                      _isEditingPassword.value = false;
                      await _updateUser(context);
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableProfileOption({
    required IconData icon,
    required TextEditingController controller,
    TextEditingController? confirmationController,
    required ValueNotifier<bool> isEditingNotifier,
    required VoidCallback onEditToggle,
    required Future<void> Function() onSave,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: isEditingNotifier,
        builder: (context, isEditing, child) {
          return Container(
            width: 500,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.red),
                const SizedBox(width: 20),
                Expanded(
                  child: isEditing
                      ? (icon == Icons.lock
                          ? Column(
                              children: [
                                TextField(
                                  controller: controller,
                                  obscureText: true,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                    hintText: 'Enter new password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                  ),
                                  cursorColor: Colors.red,
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: confirmationController,
                                  obscureText: true,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    border: const UnderlineInputBorder(),
                                    focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 2.0),
                                    ),
                                    hintText: 'Confirm new password',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                  ),
                                  cursorColor: Colors.red,
                                ),
                              ],
                            )
                          : TextField(
                              controller: controller,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: const InputDecoration(
                                border: UnderlineInputBorder(),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 2.0),
                                ),
                              ),
                            ))
                      : (icon == Icons.lock
                          ? const Text(
                              '********',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          : Text(
                              controller.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )),
                ),
                IconButton(
                  icon: Icon(isEditing ? Icons.save : Icons.edit,
                      color: Colors.white),
                  onPressed: isEditing ? onSave : onEditToggle,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateUser(BuildContext context) async {
    final userProvider = UserProvider();
    if (AuthProvider.userId != null) {
      try {
        if (_passwordController.text.isNotEmpty) {
          if (_passwordController.text !=
              _passwordConfirmationController.text) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Passwords do not match.'),
              ),
            );
            return;
          }
        }

        await userProvider.updateUser(
          AuthProvider.userId!,
          _nameController.text,
          _surnameController.text,
          _emailController.text,
          _usernameController.text,
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
          _passwordConfirmationController.text.isNotEmpty
              ? _passwordConfirmationController.text
              : null,
          _imageBase64,
          [2],
        );

        if (_usernameController.text != AuthProvider.username ||
            _passwordController.text.isNotEmpty) {
          AuthProvider.username = _usernameController.text;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated. Please log in again.'),
            ),
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            AuthProvider.userId = null;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          });
          return;
        }

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile updated successfully')),
        );
      } on Exception catch (e) {
        if (e.toString().contains('Unauthorized')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unauthorized access. Please log in again.'),
            ),
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            AuthProvider.userId = null;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}
