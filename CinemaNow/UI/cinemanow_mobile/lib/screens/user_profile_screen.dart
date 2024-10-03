import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_mobile/providers/auth_provider.dart';
import 'package:cinemanow_mobile/providers/role_provider.dart';
import 'package:cinemanow_mobile/screens/login_screen.dart';
import 'package:cinemanow_mobile/utilities/validator.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_mobile/providers/user_provider.dart';
import 'package:cinemanow_mobile/models/user.dart';
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
  String? originalName;
  String? originalSurname;
  String? originalEmail;
  String? originalUsername;
  String _originalPassword = '';
  final ValueNotifier<String?> _originalImageBase64 =
      ValueNotifier<String?>(null);

  Future<User?> _getUserData(BuildContext context) async {
    if (AuthProvider.userId != null) {
      final userProvider = UserProvider();
      return await userProvider.getUserById(AuthProvider.userId!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    _originalImageBase64.value = _imageBase64;

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

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Confirm Logout',
              style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to log out?',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    AuthProvider.userId = null;
    AuthProvider.username = null;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
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
    _originalPassword = '';
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

          originalName = user.name!;
          originalSurname = user.surname!;
          originalEmail = user.email!;
          originalUsername = user.username!;

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
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (user.imageBase64 != null
                                ? MemoryImage(base64Decode(user.imageBase64!))
                                : const AssetImage(
                                    'assets/images/user.png')) as ImageProvider,
                        backgroundColor: Colors.white,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isImageSelected,
                          builder: (context, isImageSelected, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isImageSelected)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                        _imageBase64 =
                                            _originalImageBase64.value;
                                        _isImageSelected.value = false;
                                      });
                                    },
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[700],
                                        child: const Icon(
                                          Icons.cancel,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 80),
                                GestureDetector(
                                  onTap:
                                      isImageSelected ? _saveImage : _pickImage,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        isImageSelected
                                            ? Icons.save
                                            : Icons.edit,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                      if (_isEditingPassword.value) {
                        await _updateUser(context);
                      }
                      _isEditingPassword.value = false;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
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
                                TextSelectionTheme(
                                  data: const TextSelectionThemeData(
                                    selectionColor: Colors.red,
                                  ),
                                  child: TextField(
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
                                ),
                                const SizedBox(height: 10),
                                TextSelectionTheme(
                                  data: const TextSelectionThemeData(
                                    selectionColor: Colors.red,
                                  ),
                                  child: TextField(
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
                                ),
                              ],
                            )
                          : TextSelectionTheme(
                              data: const TextSelectionThemeData(
                                selectionColor: Colors.red,
                              ),
                              child: TextField(
                                controller: controller,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 2.0),
                                  ),
                                ),
                                cursorColor: Colors.red,
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
                if (isEditing)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    onPressed: () {
                      isEditingNotifier.value = false;
                      if (icon == Icons.lock) {
                        _isEditingPassword.value = false;
                        _passwordController.text = '';
                        _passwordConfirmationController.text = '';
                      } else {
                        controller.text = _getOriginalValue(icon);
                      }
                      setState(() {});
                    },
                  ),
                IconButton(
                  icon: Icon(isEditing ? Icons.save : Icons.edit,
                      color: Colors.white),
                  onPressed: () async {
                    if (isEditing) {
                      if (icon == Icons.lock) {
                        _isEditingPassword.value = true;
                      }
                      await onSave();
                    } else {
                      onEditToggle();
                      if (icon == Icons.lock) {
                        _isEditingPassword.value = true;
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getOriginalValue(IconData icon) {
    switch (icon) {
      case Icons.person:
        return originalName ?? '';
      case Icons.email:
        return originalEmail ?? '';
      case Icons.account_circle:
        return originalUsername ?? '';
      default:
        return '';
    }
  }

  Future<void> _updateUser(BuildContext context) async {
    if (AuthProvider.userId == null) return;

    try {
      if (_isEditingPassword.value && !_validatePasswords(context)) {
        return;
      }

      final roleIds = await _getRoleIds(context);
      if (roleIds == null) return;

      final wasSuccessful = await _updateUserProfile(roleIds);

      _isEditingPassword.value = false;

      _handlePostUpdate(context, wasSuccessful);
    } on Exception catch (e) {
      _handleUpdateError(context, e);
    }
  }

  bool _validatePasswords(BuildContext context) {
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;

    if (_isEditingPassword.value) {
      if (password.isEmpty && passwordConfirmation.isEmpty) {
        setState(() {
          _passwordController.text = _originalPassword;
          _passwordConfirmationController.text = _originalPassword;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password fields cannot be empty.')),
        );
        return false;
      }

      if (password.isEmpty || passwordConfirmation.isEmpty) {
        setState(() {
          _passwordController.text = _originalPassword;
          _passwordConfirmationController.text = _originalPassword;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password fields cannot be empty.')),
        );
        return false;
      }

      if (password != passwordConfirmation) {
        setState(() {
          _passwordController.text = _originalPassword;
          _passwordConfirmationController.text = _originalPassword;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return false;
      }
    }

    return true;
  }

  Future<List<int>?> _getRoleIds(BuildContext context) async {
    final roleProvider = RoleProvider();
    final role = await roleProvider.fetchRoleByName("User");
    if (role.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role not found.')),
      );
      return null;
    }
    return [role.id!];
  }

  List<String> _validateProfileFields() {
    final errors = <String>[];

    final nameError = Validator.validateName(_nameController.text);
    if (nameError != null) errors.add(nameError);

    final surnameError = Validator.validateSurname(_surnameController.text);
    if (surnameError != null) errors.add(surnameError);

    final emailError = Validator.validateEmail(_emailController.text);
    if (emailError != null) errors.add(emailError);

    final usernameError = Validator.validateUsername(_usernameController.text);
    if (usernameError != null) errors.add(usernameError);

    if (_passwordController.text.isNotEmpty) {
      final passwordError =
          Validator.validatePassword(_passwordController.text);
      if (passwordError != null) {
        setState(() {
          _passwordController.text = _originalPassword;
          _passwordConfirmationController.text = _originalPassword;
        });
        errors.add(passwordError);
      }

      final passwordConfirmationError = Validator.validatePasswordConfirmation(
        _passwordController.text,
        _passwordConfirmationController.text,
      );
      if (passwordConfirmationError != null) {
        errors.add(passwordConfirmationError);
      }
    }

    return errors;
  }

  Future<bool> _updateUserProfile(List<int> roleIds) async {
    final validationErrors = _validateProfileFields();
    if (validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationErrors.join('\n'))),
      );
      setState(() {
        _nameController.text = originalName!;
        _surnameController.text = originalSurname!;
        _emailController.text = originalEmail!;
        _usernameController.text = originalUsername!;
      });
      return false;
    }

    final userProvider = UserProvider();

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
      roleIds,
    );

    return true;
  }

  void _handlePostUpdate(BuildContext context, bool wasSuccessful) {
    if (!wasSuccessful) return;

    if (_usernameController.text != AuthProvider.username ||
        _passwordController.text.isNotEmpty) {
      AuthProvider.username = _usernameController.text;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Profile updated successfully! Please log in again.')),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        AuthProvider.userId = null;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } else {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _handleUpdateError(BuildContext context, Exception e) {
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
        SnackBar(
            content: Text(e.toString().replaceFirst('Exception:', '').trim())),
      );
      setState(() {
        _usernameController.text = originalUsername!;
      });
    }
  }
}
