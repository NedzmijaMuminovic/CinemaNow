import 'package:cinemanow_mobile/layouts/master_screen.dart';
import 'package:cinemanow_mobile/models/user.dart';
import 'package:cinemanow_mobile/screens/register_screen.dart';
import 'package:cinemanow_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _submitted = false;
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(() {
      if (_submitted && _usernameController.text.isEmpty) {
        setState(() {
          _usernameError = 'Please fill in this field.';
        });
      } else {
        setState(() {
          _usernameError = null;
        });
      }
    });

    _passwordController.addListener(() {
      if (_submitted && _passwordController.text.isEmpty) {
        setState(() {
          _passwordError = 'Please fill in this field.';
        });
      } else {
        setState(() {
          _passwordError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    setState(() {
      _submitted = true;
      _usernameError = username.isEmpty ? 'Please fill in this field.' : null;
      _passwordError = password.isEmpty ? 'Please fill in this field.' : null;
    });

    if (_usernameError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = AuthProvider();

      final response = await authProvider.login(username, password);

      if (response == null) {
        setState(() {
          _passwordError = "Wrong username or password.";
        });
      } else {
        AuthProvider.username = username;
        AuthProvider.password = password;
        AuthProvider.setUser(response);

        if (_isUser(response)) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MasterScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          setState(() {
            _passwordError = "You do not have permission to access this area.";
          });
        }
      }
    } on Exception catch (e) {
      _passwordError = e.toString().contains("Unauthorized")
          ? "Wrong username or password."
          : e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isUser(User user) {
    final roles = user.roles;
    return roles != null && roles.any((role) => role.name == 'User');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: 400,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/logo.png',
                            height: 200,
                            width: 200,
                          ),
                          TextSelectionTheme(
                            data: const TextSelectionThemeData(
                              selectionColor: Colors.red,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _usernameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF2C2C2E),
                                    hintText: 'Username',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.person,
                                        color: Colors.white70),
                                    errorText: _usernameError,
                                  ),
                                  cursorColor: Colors.red,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          TextSelectionTheme(
                            data: const TextSelectionThemeData(
                              selectionColor: Colors.red,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFF2C2C2E),
                                    hintText: 'Password',
                                    hintStyle:
                                        const TextStyle(color: Colors.white70),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    prefixIcon: const Icon(Icons.lock,
                                        color: Colors.white70),
                                    errorText: _passwordError,
                                  ),
                                  cursorColor: Colors.red,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD32F2F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Text(
                              'Login',
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
                                  "Don't have an account? ",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Register',
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
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
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
