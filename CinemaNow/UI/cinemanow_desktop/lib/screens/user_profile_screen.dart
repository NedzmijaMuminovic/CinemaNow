import 'dart:convert';
import 'dart:io';

import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:cinemanow_desktop/providers/role_provider.dart';
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

  final ValueNotifier<String?> _nameError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _surnameError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _emailError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _usernameError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _passwordConfirmationError =
      ValueNotifier<String?>(null);

  final ValueNotifier<bool> _isEditingName = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingSurname = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingEmail = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingUsername = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isEditingPassword = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isImageSelected = ValueNotifier<bool>(false);
  bool _isRemovingImage = false;

  File? _selectedImage;
  String? _imageBase64;
  String? originalName;
  String? originalSurname;
  String? originalEmail;
  String? originalUsername;
  String _originalPassword = '';
  final ValueNotifier<String?> _originalImageBase64 =
      ValueNotifier<String?>(null);
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  Widget _buildEditableProfileOption({
    required IconData icon,
    required TextEditingController controller,
    TextEditingController? confirmationController,
    required ValueNotifier<bool> isEditingNotifier,
    required ValueNotifier<String?> errorNotifier,
    ValueNotifier<String?>? confirmationErrorNotifier,
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
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.red),
                    const SizedBox(width: 20),
                    Expanded(
                      child: isEditing
                          ? (icon == Icons.lock
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(
                                      controller: controller,
                                      isPassword: true,
                                      hint: 'Enter new password',
                                      errorNotifier: errorNotifier,
                                    ),
                                    if (confirmationController != null)
                                      _buildTextField(
                                        controller: confirmationController,
                                        isPassword: true,
                                        hint: 'Confirm new password',
                                        errorNotifier:
                                            confirmationErrorNotifier ??
                                                errorNotifier,
                                      ),
                                  ],
                                )
                              : _buildTextField(
                                  controller: controller,
                                  errorNotifier: errorNotifier,
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
                    if (isEditing) ...[
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        onPressed: () {
                          isEditingNotifier.value = false;
                          errorNotifier.value = null;
                          if (confirmationErrorNotifier != null) {
                            confirmationErrorNotifier.value = null;
                          }
                          if (icon == Icons.lock) {
                            controller.text = '';
                            if (confirmationController != null) {
                              confirmationController.text = '';
                            }
                          } else {
                            controller.text = _getOriginalValue(icon);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.save, color: Colors.white),
                        onPressed: () async {
                          final errors = _validateProfileFields();
                          if (errors.isEmpty) {
                            await onSave();
                          } else {
                            if (icon == Icons.lock) {
                              controller.text = '';
                              if (confirmationController != null) {
                                confirmationController.text = '';
                              }
                            } else {
                              controller.text = _getOriginalValue(icon);
                            }
                          }
                        },
                      ),
                    ] else
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: onEditToggle,
                      ),
                  ],
                ),
                ValueListenableBuilder<String?>(
                  valueListenable: errorNotifier,
                  builder: (context, error, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: error != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                error,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                ),
                if (confirmationErrorNotifier != null)
                  ValueListenableBuilder<String?>(
                    valueListenable: confirmationErrorNotifier,
                    builder: (context, error, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: error != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  error,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueNotifier<String?> errorNotifier,
    bool isPassword = false,
    String? hint,
  }) {
    return TextSelectionTheme(
      data: const TextSelectionThemeData(
        selectionColor: Colors.red,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        cursorColor: Colors.red,
        onChanged: (value) {
          if (errorNotifier.value != null) {
            errorNotifier.value = null;
          }
        },
      ),
    );
  }

  List<String> _validateProfileFields() {
    final errors = <String>[];

    _nameError.value = null;
    _surnameError.value = null;
    _emailError.value = null;
    _usernameError.value = null;
    _passwordError.value = null;
    _passwordConfirmationError.value = null;

    final nameError = Validator.validateName(_nameController.text);
    if (nameError != null) {
      _nameError.value = nameError;
      errors.add(nameError);
    }

    final surnameError = Validator.validateSurname(_surnameController.text);
    if (surnameError != null) {
      _surnameError.value = surnameError;
      errors.add(surnameError);
    }

    final emailError = Validator.validateEmail(_emailController.text);
    if (emailError != null) {
      _emailError.value = emailError;
      errors.add(emailError);
    }

    final usernameError = Validator.validateUsername(_usernameController.text);
    if (usernameError != null) {
      _usernameError.value = usernameError;
      errors.add(usernameError);
    }

    if (_isEditingPassword.value && _passwordController.text.isNotEmpty) {
      final passwordError =
          Validator.validatePassword(_passwordController.text);
      if (passwordError != null) {
        _passwordError.value = passwordError;
        errors.add(passwordError);
      }

      final confirmError = Validator.validatePasswordConfirmation(
        _passwordController.text,
        _passwordConfirmationController.text,
      );
      if (confirmError != null) {
        _passwordConfirmationError.value = confirmError;
        errors.add(confirmError);
      }
    }

    return errors;
  }

  void _showDeactivateConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Confirm Account Deactivation',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to deactivate your account? This action cannot be undone.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Deactivate',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deactivateAccount();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deactivateAccount() async {
    try {
      if (AuthProvider.userId == null) return;

      final userProvider = UserProvider();
      await userProvider.deleteUser(AuthProvider.userId!);

      _scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Deactivation successful. Your account has been permanently deleted.'),
        ),
      );

      Future.delayed(const Duration(milliseconds: 300), () {
        AuthProvider.userId = null;
        AuthProvider.username = null;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to deactivate account: ${e.toString()}'),
        ),
      );
    }
  }

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
                AuthProvider.userId = null;
                AuthProvider.username = null;

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
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

  void _showRemoveImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Remove Profile Picture',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to remove your profile picture?',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeProfilePicture();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeProfilePicture() async {
    try {
      setState(() {
        _isRemovingImage = true;
      });

      if (AuthProvider.userId == null) return;

      final roleIds = await _getRoleIds(context);
      if (roleIds == null) return;

      final userProvider = UserProvider();
      await userProvider.updateUser(
        AuthProvider.userId!,
        _nameController.text,
        _surnameController.text,
        _emailController.text,
        _usernameController.text,
        null,
        null,
        '',
        roleIds,
      );

      setState(() {
        _imageBase64 = '';
        _selectedImage = null;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture removed successfully!'),
        ),
      );
    } catch (e) {
      _handleUpdateError(context, e);
    } finally {
      setState(() {
        _isRemovingImage = false;
      });
    }
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
                            : (_imageBase64 != null && _imageBase64!.isNotEmpty
                                ? MemoryImage(base64Decode(_imageBase64!))
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
                                if (_imageBase64 != null &&
                                    _imageBase64!.isNotEmpty &&
                                    !isImageSelected)
                                  GestureDetector(
                                    onTap: () =>
                                        _showRemoveImageDialog(context),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[700],
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
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
                                const SizedBox(
                                    width:
                                        80),
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
                    errorNotifier: _nameError,
                    onEditToggle: () {
                      _isEditingName.value = !_isEditingName.value;
                      _nameError.value = null;
                    },
                    onSave: () async {
                      await _updateUser(context);
                      _isEditingName.value = false;
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.person_outline,
                    controller: _surnameController,
                    isEditingNotifier: _isEditingSurname,
                    errorNotifier: _surnameError,
                    onEditToggle: () {
                      _isEditingSurname.value = !_isEditingSurname.value;
                      _surnameError.value = null;
                    },
                    onSave: () async {
                      await _updateUser(context);
                      _isEditingSurname.value = false;
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.email,
                    controller: _emailController,
                    isEditingNotifier: _isEditingEmail,
                    errorNotifier: _emailError,
                    onEditToggle: () {
                      _isEditingEmail.value = !_isEditingEmail.value;
                      _emailError.value = null;
                    },
                    onSave: () async {
                      await _updateUser(context);
                      _isEditingEmail.value = false;
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.account_circle,
                    controller: _usernameController,
                    isEditingNotifier: _isEditingUsername,
                    errorNotifier: _usernameError,
                    onEditToggle: () {
                      _isEditingUsername.value = !_isEditingUsername.value;
                      _usernameError.value = null;
                    },
                    onSave: () async {
                      await _updateUser(context);
                      _isEditingUsername.value = false;
                    },
                  ),
                  _buildEditableProfileOption(
                    icon: Icons.lock,
                    controller: _passwordController,
                    confirmationController: _passwordConfirmationController,
                    isEditingNotifier: _isEditingPassword,
                    errorNotifier: _passwordError,
                    confirmationErrorNotifier: _passwordConfirmationError,
                    onEditToggle: () {
                      _isEditingPassword.value = !_isEditingPassword.value;
                      _passwordError.value = null;
                      _passwordConfirmationError.value = null;
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
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeactivateConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Deactivate Account',
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

  @override
  void dispose() {
    _nameError.dispose();
    _surnameError.dispose();
    _emailError.dispose();
    _usernameError.dispose();
    _passwordError.dispose();
    _passwordConfirmationError.dispose();

    super.dispose();
  }

  String _getOriginalValue(IconData icon) {
    switch (icon) {
      case Icons.person:
        return originalName ?? '';
      case Icons.person_outline:
        return originalSurname ?? '';
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
      final errors = _validateProfileFields();
      if (errors.isNotEmpty) {
        return;
      }

      if (_isEditingPassword.value) {
        if (_passwordController.text.isEmpty &&
            _passwordConfirmationController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Password fields are empty. Please fill out both fields.')),
          );
          return;
        } else if (_passwordController.text.isEmpty &&
            _passwordConfirmationController.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Password field is empty. Please fill out both fields.')),
          );
          return;
        } else if (_passwordController.text.isNotEmpty &&
            _passwordConfirmationController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please confirm your password.')),
          );
          return;
        }
      }

      final roleIds = await _getRoleIds(context);
      if (roleIds == null) return;

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

      if (_usernameController.text != AuthProvider.username ||
          _passwordController.text.isNotEmpty) {
        _handleLogoutAndRedirect(context);
      } else {
        _handleSuccessfulUpdate(context);
      }
    } catch (e) {
      _handleUpdateError(context, e);
    }
  }

  void _handleSuccessfulUpdate(BuildContext context) {
    originalName = _nameController.text;
    originalSurname = _surnameController.text;
    originalEmail = _emailController.text;
    originalUsername = _usernameController.text;

    _isEditingName.value = false;
    _isEditingSurname.value = false;
    _isEditingEmail.value = false;
    _isEditingUsername.value = false;
    _isEditingPassword.value = false;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  void _handleLogoutAndRedirect(BuildContext context) {
    AuthProvider.username = _usernameController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully! Please log in again.'),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      AuthProvider.userId = null;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  Future<List<int>?> _getRoleIds(BuildContext context) async {
    final roleProvider = RoleProvider();
    final role = await roleProvider.fetchRoleByName("Admin");
    if (role.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role not found.')),
      );
      return null;
    }
    return [role.id!];
  }

  void _handleUpdateError(BuildContext context, dynamic error) {
    if (error.toString().contains('Unauthorized')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unauthorized access. Please log in again.'),
        ),
      );
      _handleLogoutAndRedirect(context);
    } else {
      final errorMessage =
          error.toString().replaceFirst('Exception:', '').trim();

      if (errorMessage.contains('Username is already taken')) {
        _usernameController.text = originalUsername!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}
