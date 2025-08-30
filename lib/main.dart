import 'package:flutter/material.dart';
import 'package:mdia_player/core/utils/functions/request_permissions.dart';
import 'package:mdia_player/core/utils/themes/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Player',
      theme: Themes.lightThemeData,
      darkTheme: Themes.darkThemeData,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      home: const MyApp(),
    );
  }
}
