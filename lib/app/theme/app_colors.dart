import 'package:flutter/material.dart';

/// Centralized color system for Basura App.
/// Concept: Environmental Tech / Smart Sustainability / Modern AI Product.
class AppColors {
  AppColors._();

  // Core Palette
  static const Color background = Color(0xFFF5F7F4);
  static const Color primary = Color(0xFF1F5948);
  static const Color primaryDark = Color(0xFF183C32);
  static const Color secondary = Color(0xFF82A995);
  static const Color textPrimary = Color(0xFF1D2924);
  static const Color textSecondary = Color(0xFF78847D);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5EAE5);

  // Functional & Accent Colors
  static const Color surfaceVariant = Color(0xFFEDF2EE);
  static const Color primaryLight = Color(0xFFE3EDE7);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Waste Bin Standard Colors (Peruvian / International Solid Waste Norm)
  // plastico: Tacho blanco
  // papel_carton: Tacho azul
  // vidrio: Tacho verde
  // metal: Tacho amarillo
  // organico: Tacho marrón
  // peligroso: Tacho rojo
  // otros: Tacho negro
  static const Color binPlastico = Color(0xFF0284C7); // Clean blue-slate / White container accent
  static const Color binPlasticoContainer = Color(0xFFF8FAFC);
  static const Color binPapelCarton = Color(0xFF2563EB); // Blue
  static const Color binVidrio = Color(0xFF16A34A); // Green
  static const Color binMetal = Color(0xFFD97706); // Amber / Yellow
  static const Color binOrganico = Color(0xFF854D0E); // Brown
  static const Color binPeligroso = Color(0xFFDC2626); // Red
  static const Color binOtros = Color(0xFF1F2937); // Dark gray / Black

  /// Return corresponding bin primary color from class key
  static Color getBinColor(String classKey) {
    switch (classKey.toLowerCase()) {
      case 'plastico':
        return const Color(0xFF0284C7);
      case 'papel_carton':
        return binPapelCarton;
      case 'vidrio':
        return binVidrio;
      case 'metal':
        return binMetal;
      case 'organico':
        return binOrganico;
      case 'peligroso':
        return binPeligroso;
      case 'otros':
      default:
        return binOtros;
    }
  }

  /// Return soft background color for badges / cards
  static Color getBinColorLight(String classKey) {
    switch (classKey.toLowerCase()) {
      case 'plastico':
        return const Color(0xFFE0F2FE);
      case 'papel_carton':
        return const Color(0xFFDBEAFE);
      case 'vidrio':
        return const Color(0xFFDCFCE7);
      case 'metal':
        return const Color(0xFFFEF3C7);
      case 'organico':
        return const Color(0xFFFEF3C7).withValues(alpha: 0.5);
      case 'peligroso':
        return const Color(0xFFFEE2E2);
      case 'otros':
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}
