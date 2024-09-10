import 'package:flutter/material.dart';

ThemeData buildDarkTheme(BuildContext context) {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.grey[900],
    dialogBackgroundColor: Colors.grey[900],
    textTheme: const TextTheme(),
    colorScheme: const ColorScheme.dark(
      primary: Colors.red,
      onPrimary: Colors.white,
    ),
  );
}
