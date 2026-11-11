import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

class AnalysisLoadingView extends StatelessWidget {
  final int stageIndex; // 0: Preparando, 1: Procesando, 2: Analizando IA

  const AnalysisLoadingView({
    super.key,
    required this.stageIndex,
  });

  String get _stageTitle {
    switch (stageIndex) {
      case 0:
        return 'Preparando imagen';
      case 1:
        return 'Procesando tensor 224×224 RGB';
      case 2:
      default:
        return 'Analizando con MobileNetV2';
    }
  }

  String get _stageSubtitle {
    switch (stageIndex) {
      case 0:
        return 'Decodificando píxeles y orientación...';
      case 1:
        return 'Aplicando recorte central y valores 0-255...';
      case 2:
      default:
        return 'Calculando probabilidades y contenedor óptimo...';
    }
  }

  double get _progressValue {
    switch (stageIndex) {
      case 0:
        return 0.35;
      case 1:
        return 0.70;
      case 2:
      default:
        return 0.95;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Lottie Animation Container
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                AppConstants.analysisAnimation,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.cpu,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animated Status Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _stageTitle,
                key: ValueKey<String>(_stageTitle),
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 6),

            // Animated Status Subtitle
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _stageSubtitle,
                key: ValueKey<String>(_stageSubtitle),
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Elegant Linear Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                tween: Tween<double>(begin: 0.1, end: _progressValue),
                builder: (context, val, _) => LinearProgressIndicator(
                  value: val,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Technical AI Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.sparkles, size: 12, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Inferencia Local • Sin conexión requerida',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
