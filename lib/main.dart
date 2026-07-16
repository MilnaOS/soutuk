import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SoutukApp(),
    ),
  );
}

class SoutukApp extends StatelessWidget {
  const SoutukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soutuk Universal Translator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
