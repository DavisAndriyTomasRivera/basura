import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import 'main_navigation_shell.dart';
import 'theme/app_theme.dart';

class BasuraApp extends StatefulWidget {
  final bool initialOnboardingComplete;

  const BasuraApp({super.key, required this.initialOnboardingComplete});

  @override
  State<BasuraApp> createState() => _BasuraAppState();
}

class _BasuraAppState extends State<BasuraApp> {
  late bool _onboardingComplete = widget.initialOnboardingComplete;

  Future<void> _completeOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setBool(
      AppConstants.onboardingCompletedStorageKey,
      true,
    );
    if (!saved) {
      throw StateError('No se pudo guardar el estado del onboarding.');
    }

    if (mounted) {
      setState(() => _onboardingComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basura — Smart Waste Classification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _onboardingComplete
          ? const MainNavigationShell()
          : OnboardingScreen(onComplete: _completeOnboarding),
    );
  }
}
