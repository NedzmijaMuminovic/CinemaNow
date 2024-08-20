import 'package:cinemanow_desktop/layouts/master_screen.dart';
import 'package:cinemanow_desktop/models/user.dart';
import 'package:cinemanow_desktop/providers/user_provider.dart';
import 'package:cinemanow_desktop/screens/register_screen.dart';
import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:cinemanow_desktop/screens/screening_list_screen.dart';
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

  void _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog("Username and password cannot be empty.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AuthProvider.username = username;
    AuthProvider.password = password;

    try {
      final user = await _fetchUser(username);
      if (user != null) {
        AuthProvider.setUser(user);
        if (_isAdmin(user)) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MasterScreen(ScreeningListScreen())));
        } else {
          _showErrorDialog("You do not have permission to access this area.");
        }
      }
    } on Exception catch (e) {
      _showErrorDialog(e.toString().contains("Unauthorized")
          ? "Wrong username or password."
          : e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<User?> _fetchUser(String username) async {
    final userProvider = UserProvider();
    final userResponse =
        await userProvider.getUsers(filter: {'username': username});
    return userResponse.result.isNotEmpty ? userResponse.result.first : null;
  }

  bool _isAdmin(User user) {
    final roles = user.roles;
    return roles != null && roles.any((role) => role.name == 'Admin');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Error", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: Stack(children: [
        Center(
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
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.white70),
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
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                    const SizedBox(height: 10.0),
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
                                  builder: (context) => const RegisterScreen(),
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
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
      ]),
    );
  }
}
