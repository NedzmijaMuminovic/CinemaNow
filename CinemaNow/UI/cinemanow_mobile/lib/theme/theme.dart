import 'package:flutter/material.dart';

ThemeData buildDarkTheme(BuildContext context) {
  return ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.grey[900],
    dialogBackgroundColor: Colors.grey[900],
    textTheme: const TextTheme(),
    colorScheme: ColorScheme.dark(
      primary: Colors.grey[700]!,
      onPrimary: Colors.white,
      secondary: Colors.grey[600]!,
      surface: Colors.grey[800]!,
      background: Colors.grey[900]!,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.grey[900],
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: Colors.grey[900],
      hourMinuteColor: Colors.grey[800],
      dialBackgroundColor: Colors.grey[800],
      dialHandColor: Colors.grey[600],
    ),
  );
}
