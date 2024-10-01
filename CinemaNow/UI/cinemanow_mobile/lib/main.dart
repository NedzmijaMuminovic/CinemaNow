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
import 'package:provider/provider.dart';

void main() {
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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
