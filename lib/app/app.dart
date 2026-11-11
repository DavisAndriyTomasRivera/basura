import 'package:flutter/material.dart';
import 'main_navigation_shell.dart';
import 'theme/app_theme.dart';

class BasuraApp extends StatelessWidget {
  const BasuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basura — Smart Waste Classification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}
