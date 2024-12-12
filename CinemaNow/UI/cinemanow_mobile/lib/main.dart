import 'package:cinemanow_mobile/providers/actor_provider.dart';
import 'package:cinemanow_mobile/providers/genre_provider.dart';
import 'package:cinemanow_mobile/providers/hall_provider.dart';
import 'package:cinemanow_mobile/providers/movie_provider.dart';
import 'package:cinemanow_mobile/providers/rating_provider.dart';
import 'package:cinemanow_mobile/providers/reservation_provider.dart';
import 'package:cinemanow_mobile/providers/screening_provider.dart';
import 'package:cinemanow_mobile/providers/user_provider.dart';
import 'package:cinemanow_mobile/providers/view_mode_provider.dart';
import 'package:cinemanow_mobile/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  String? stripePublishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  if (stripePublishableKey.isEmpty) {
    stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  }

  if (stripePublishableKey.isEmpty) {
    throw Exception(
        'Stripe publishable key is missing from both dart-define and .env file');
  }

  Stripe.publishableKey = stripePublishableKey;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProxyProvider<RatingProvider, MovieProvider>(
          create: (context) => MovieProvider(context.read<RatingProvider>()),
          update: (context, ratingProvider, previousMovieProvider) =>
              MovieProvider(ratingProvider),
        ),
        ChangeNotifierProvider(create: (_) => HallProvider()),
        ChangeNotifierProvider(create: (_) => ViewModeProvider()),
        ChangeNotifierProvider(create: (_) => ActorProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ScreeningProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
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
      debugShowCheckedModeBanner: false,
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
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF323232),
          contentTextStyle: TextStyle(
            color: Colors.white,
          ),
          actionTextColor: Colors.white,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
