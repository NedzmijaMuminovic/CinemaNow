import 'package:cinemanow_desktop/providers/registration_provider.dart';
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

  void _validateName(String text) {
    final nameRegExp = RegExp(r'^[A-Z][a-zA-Z]*$');
    setState(() {
      _nameError = nameRegExp.hasMatch(text)
          ? null
          : 'Name must start with a capital letter and contain only letters.';
    });
  }

  void _validateSurname(String text) {
    final surnameRegExp = RegExp(r'^[A-Z][a-zA-Z]*$');
    setState(() {
      _surnameError = surnameRegExp.hasMatch(text)
          ? null
          : 'Surname must start with a capital letter and contain only letters.';
    });
  }

  void _validateEmail(String text) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    setState(() {
      _emailError =
          emailRegExp.hasMatch(text) ? null : 'Enter a valid email address.';
    });
  }

  void _validateUsername(String text) {
    final usernameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,}$');
    setState(() {
      _usernameError = usernameRegExp.hasMatch(text)
          ? null
          : 'Username must be at least 3 characters long and contain only letters, numbers, or underscores.';
    });
  }

  void _validatePassword(String text) {
    final passwordRegExp =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    setState(() {
      _passwordError = passwordRegExp.hasMatch(text)
          ? null
          : 'Password must be at least 8 characters long and include at least one letter, one number, and one special character.';
    });
  }

  void _validatePasswordConfirmation(String text) {
    setState(() {
      _passwordConfirmationError =
          text == _passwordController.text ? null : 'Passwords do not match.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    width: 200,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Name',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.white70),
                        ),
                        onChanged: _validateName,
                      ),
                      if (_nameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _nameError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _surnameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Surname',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.white70),
                        ),
                        onChanged: _validateSurname,
                      ),
                      if (_surnameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _surnameError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Email',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.white70),
                        ),
                        onChanged: _validateEmail,
                      ),
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _emailError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Username',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.account_circle,
                              color: Colors.white70),
                        ),
                        onChanged: _validateUsername,
                      ),
                      if (_usernameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _usernameError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Password',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white70),
                        ),
                        onChanged: _validatePassword,
                      ),
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _passwordError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordConfirmationController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF2C2C2E),
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.white70),
                        ),
                        onChanged: _validatePasswordConfirmation,
                      ),
                      if (_passwordConfirmationError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _passwordConfirmationError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty ||
                          _surnameController.text.isEmpty ||
                          _emailController.text.isEmpty ||
                          _usernameController.text.isEmpty ||
                          _passwordController.text.isEmpty ||
                          _passwordConfirmationController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: const Text("Error",
                                style: TextStyle(color: Colors.white)),
                            content: const Text("Please fill in all fields.",
                                style: TextStyle(color: Colors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK",
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      final success = await _registrationProvider.registerUser(
                        name: _nameController.text,
                        surname: _surnameController.text,
                        email: _emailController.text,
                        username: _usernameController.text,
                        password: _passwordController.text,
                        passwordConfirmation:
                            _passwordConfirmationController.text,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registration successful')),
                        );
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  const SizedBox(height: 10.0),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
