import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

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
                  TextField(
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
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
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
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Implement registration logic here
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
