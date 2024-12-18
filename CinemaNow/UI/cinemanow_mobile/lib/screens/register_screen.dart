import 'package:cinemanow_mobile/providers/registration_provider.dart';
import 'package:cinemanow_mobile/utilities/validator.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  final RegistrationProvider _registrationProvider = RegistrationProvider();

  String? _nameError;
  String? _surnameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _passwordConfirmationError;

  bool _isLoading = false;
  bool _showErrors = false;
  String? _formErrorMessage;

  void _validateName(String text) {
    setState(() {
      _nameError = Validator.validateName(text);

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  void _validateSurname(String text) {
    setState(() {
      _surnameError = Validator.validateSurname(text);

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  void _validateEmail(String text) {
    setState(() {
      _emailError = Validator.validateEmail(text);

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  void _validateUsername(String text) {
    setState(() {
      _usernameError = Validator.validateUsername(text);

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  void _validatePassword(String text) {
    setState(() {
      _passwordError = Validator.validatePassword(text);

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  void _validatePasswordConfirmation(String text) {
    setState(() {
      _passwordConfirmationError = Validator.validatePasswordConfirmation(
        _passwordController.text,
        text,
      );

      if (_nameError == null &&
          _surnameError == null &&
          _emailError == null &&
          _usernameError == null &&
          _passwordError == null &&
          _passwordConfirmationError == null) {
        _formErrorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: SizedBox(
                        width: 400,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 200,
                                width: 200,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextFormField(
                                      controller: _nameController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Name',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(Icons.person,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validateName,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_nameController.text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_nameError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _nameError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 20.0),
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextFormField(
                                      controller: _surnameController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Surname',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(
                                            Icons.person_outline,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validateSurname,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_surnameController.text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_surnameError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _surnameError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 20.0),
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Email',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(Icons.email,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validateEmail,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_emailController.text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_emailError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _emailError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 20.0),
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextField(
                                      controller: _usernameController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Username',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(
                                            Icons.account_circle,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validateUsername,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_usernameController.text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_usernameError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _usernameError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 20.0),
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextField(
                                      controller: _passwordController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Password',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(Icons.lock,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validatePassword,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_passwordController.text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_passwordError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _passwordError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 20.0),
                                  TextSelectionTheme(
                                    data: const TextSelectionThemeData(
                                      selectionColor: Colors.red,
                                    ),
                                    child: TextFormField(
                                      controller:
                                          _passwordConfirmationController,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: const Color(0xFF2C2C2E),
                                        hintText: 'Confirm Password',
                                        hintStyle: const TextStyle(
                                            color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(Icons.lock,
                                            color: Colors.white70),
                                      ),
                                      cursorColor: Colors.red,
                                      onChanged: _validatePasswordConfirmation,
                                    ),
                                  ),
                                  if (_showErrors) ...[
                                    if (_passwordConfirmationController
                                        .text.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Please fill in this field.',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      )
                                    else if (_passwordConfirmationError != null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _passwordConfirmationError!,
                                          style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 12.0),
                                        ),
                                      ),
                                  ],
                                  if (_showErrors && _formErrorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        _formErrorMessage!,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 12.0),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _showErrors = true;
                                  });

                                  if (_nameController.text.isEmpty ||
                                      _surnameController.text.isEmpty ||
                                      _emailController.text.isEmpty ||
                                      _usernameController.text.isEmpty ||
                                      _passwordController.text.isEmpty ||
                                      _passwordConfirmationController
                                          .text.isEmpty) {
                                    return;
                                  }

                                  _validateName(_nameController.text);
                                  _validateSurname(_surnameController.text);
                                  _validateEmail(_emailController.text);
                                  _validateUsername(_usernameController.text);
                                  _validatePassword(_passwordController.text);
                                  _validatePasswordConfirmation(
                                      _passwordConfirmationController.text);

                                  if (_nameError != null ||
                                      _surnameError != null ||
                                      _emailError != null ||
                                      _usernameError != null ||
                                      _passwordError != null ||
                                      _passwordConfirmationError != null) {
                                    _formErrorMessage =
                                        'Please fix the errors in the form.';
                                    return;
                                  }

                                  final userExists = await _registrationProvider
                                      .isUsernameTaken(
                                          _usernameController.text);

                                  if (userExists) {
                                    _usernameError =
                                        "Username already exists. Please choose a different one.";
                                    setState(() {});
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  final success =
                                      await _registrationProvider.registerUser(
                                    name: _nameController.text,
                                    surname: _surnameController.text,
                                    email: _emailController.text,
                                    username: _usernameController.text,
                                    password: _passwordController.text,
                                    passwordConfirmation:
                                        _passwordConfirmationController.text,
                                  );

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Registration successful! Please log in with your username and password.')),
                                    );
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Registration failed, please try again.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD32F2F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                    child: Text(
                                      "Already have an account? ",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                          color: Color(0xFFD32F2F),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
