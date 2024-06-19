import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  colorScheme: ColorScheme.dark(
    primary: Colors.teal[200]!,
    secondary: Colors.teal[200]!,
  ),
  appBarTheme: const AppBarTheme(
    color: Colors.black,
  ),
);
