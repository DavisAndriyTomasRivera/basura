import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';

class HistoryEmptyState extends StatelessWidget {
  final VoidCallback onStartClassifying;

  const HistoryEmptyState({
    super.key,
    required this.onStartClassifying,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.history,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aún no hay clasificaciones',
              style: AppTypography.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Cada vez que captures y clasifiques un residuo, su registro, porcentaje de certeza y recomendaciones aparecerán aquí.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Clasificar primer residuo',
              icon: LucideIcons.camera,
              width: 240,
              onPressed: onStartClassifying,
            ),
          ],
        ),
      ),
    );
  }
}
