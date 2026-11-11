import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/waste_badge.dart';
import '../../classifier/models/classification_result.dart';
import '../../classifier/widgets/bin_recommendation_card.dart';
import '../../classifier/widgets/prediction_bar.dart';

class HistoryDetailSheet extends StatelessWidget {
  final ClassificationResult item;
  final VoidCallback onDelete;

  const HistoryDetailSheet({
    super.key,
    required this.item,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required ClassificationResult item,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HistoryDetailSheet(item: item, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final binColor = AppColors.getBinColor(item.classKey);
    final percentage = (item.confidence * 100).clamp(0.0, 100.0);
    final formattedDate = DateFormat('dd/MM/yyyy • HH:mm').format(item.timestamp);
    final imageFile = File(item.imagePath);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalle de Clasificación',
                      style: AppTypography.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 20, color: AppColors.error),
                      tooltip: 'Eliminar registro',
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.border),

              // Scrollable Body
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Image with timestamp
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageFile.existsSync())
                            Image.file(imageFile, fit: BoxFit.cover)
                          else
                            const Center(
                              child: Icon(LucideIcons.image, size: 40, color: Colors.white54),
                            ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                formattedDate,
                                style: AppTypography.labelSmall.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Overview Card
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: binColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Icon(
                                LucideIcons.recycle,
                                size: 26,
                                color: binColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.modelName,
                                  style: AppTypography.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          WasteBadge(
                            label: '${percentage.toStringAsFixed(0)}% certeza',
                            color: item.isLowConfidence ? AppColors.warning : AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bin Recommendation
                    BinRecommendationCard(
                      classKey: item.classKey,
                      binName: item.recommendedBin,
                      disposalAdvice: item.disposalAdvice,
                    ),

                    const SizedBox(height: 16),

                    // Top Predictions
                    if (item.topPredictions.isNotEmpty)
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DISTRIBUCIÓN DE PREDICCIONES',
                              style: AppTypography.labelSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...item.topPredictions.asMap().entries.map((entry) {
                              return PredictionBar(
                                prediction: entry.value,
                                isTop: entry.key == 0,
                              );
                            }),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    CustomButton(
                      label: 'Cerrar',
                      variant: ButtonVariant.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
