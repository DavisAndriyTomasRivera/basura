import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/waste_badge.dart';
import '../../classifier/services/tflite_service.dart';

class ModelInfoCard extends StatelessWidget {
  const ModelInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tflite = TFLiteService();
    final meta = tflite.rawMetadata;
    final metrics = meta?['metricas_test'] as List<dynamic>?;
    final bestMetric = metrics != null && metrics.isNotEmpty
        ? (metrics.last as Map<String, dynamic>)
        : null;

    final testAcc = bestMetric?['Test Accuracy'] != null
        ? '${((bestMetric!['Test Accuracy'] as num) * 100).toStringAsFixed(1)}%'
        : '89.6%';
    final f1Macro = bestMetric?['F1 macro'] != null
        ? '${((bestMetric!['F1 macro'] as num) * 100).toStringAsFixed(1)}%'
        : '87.0%';
    final params = bestMetric?['Params']?.toString() ?? '2,427,975';

    return AppCard(
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(LucideIcons.cpu, size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tflite.activeModelName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TensorFlow Lite • Versión ${tflite.modelVersion}',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
              ),
              const WasteBadge(
                label: 'FP16',
                color: AppColors.primary,
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem('Exactitud Test', testAcc),
              _buildMetricItem('F1-Score Macro', f1Macro),
              _buildMetricItem('Parámetros', params),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Entrada: 224×224 RGB • Inferencia en dispositivo sin enviar fotos a servidores externos.',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
