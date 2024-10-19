import 'package:cinemanow_desktop/providers/actor_provider.dart';
import 'package:cinemanow_desktop/providers/genre_provider.dart';
import 'package:cinemanow_desktop/providers/hall_provider.dart';
import 'package:cinemanow_desktop/providers/movie_provider.dart';
import 'package:cinemanow_desktop/providers/screening_provider.dart';
import 'package:cinemanow_desktop/providers/user_provider.dart';
import 'package:cinemanow_desktop/providers/view_mode_provider.dart';
import 'package:cinemanow_desktop/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => HallProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),
        ChangeNotifierProvider(create: (_) => ActorProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScreeningProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF1C1C1E),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[900],
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFF4A4A4A),
          cursorColor: Color(0xFF4A4A4A),
        ),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1C1C1E),
          secondary: Colors.grey[700]!,
          surface: const Color(0xFF2C2C2E),
          background: const Color(0xFF1C1C1E),
          error: Colors.red,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF323232),
          contentTextStyle: const TextStyle(
            color: Colors.white,
          ),
          actionTextColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
