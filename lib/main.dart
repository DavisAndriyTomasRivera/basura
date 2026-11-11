import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/app_constants.dart';
import 'features/classifier/services/tflite_service.dart';
import 'features/history/services/history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final onboardingComplete =
      preferences.getBool(AppConstants.onboardingCompletedStorageKey) ?? false;

  // Set system UI style for immersive experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize background services (non-blocking)
  TFLiteService().initialize().catchError((error) {
    debugPrint(
      'Aviso: Inicialización en segundo plano de TFLiteService diferida: $error',
    );
  });

  HistoryService().initialize().catchError((error) {
    debugPrint(
      'Aviso: Inicialización en segundo plano de HistoryService diferida: $error',
    );
  });

  runApp(BasuraApp(initialOnboardingComplete: onboardingComplete));
}
