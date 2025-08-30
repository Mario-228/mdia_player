import 'package:flutter/material.dart';

abstract class Themes {
  static final ThemeData lightThemeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffac4b78)),
    brightness: Brightness.light,
  );

  static final ThemeData darkThemeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffac4b78)),
    brightness: Brightness.dark,
  );
}
