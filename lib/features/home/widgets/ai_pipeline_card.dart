import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

class AIPipelineCard extends StatelessWidget {
  const AIPipelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'CÓMO FUNCIONA LA INTELIGENCIA ARTIFICIAL',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStepRow(
              stepNumber: '1',
              title: 'Captura y preprocesamiento',
              description: 'Se recorta el centro de la imagen y se ajusta a 224×224 píxeles RGB.',
              icon: LucideIcons.camera,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 17),
              child: SizedBox(
                height: 16,
                child: VerticalDivider(color: AppColors.border, thickness: 1.5),
              ),
            ),
            _buildStepRow(
              stepNumber: '2',
              title: 'Inferencia local con MobileNetV2',
              description: 'El modelo TFLite analiza las características visuales directamente en tu móvil.',
              icon: LucideIcons.cpu,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 17),
              child: SizedBox(
                height: 16,
                child: VerticalDivider(color: AppColors.border, thickness: 1.5),
              ),
            ),
            _buildStepRow(
              stepNumber: '3',
              title: 'Tacho y recomendaciones',
              description: 'Te indica el contenedor oficial correspondiente y cómo prepararlo para reciclaje.',
              icon: LucideIcons.recycle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
