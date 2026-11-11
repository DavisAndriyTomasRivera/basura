import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/waste_badge.dart';
import '../../classifier/models/classification_result.dart';
import '../../history/services/history_service.dart';

class ActivitySummaryCard extends StatelessWidget {
  final VoidCallback onViewHistory;

  const ActivitySummaryCard({
    super.key,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ValueListenableBuilder<List<ClassificationResult>>(
        valueListenable: HistoryService().historyNotifier,
        builder: (context, items, _) {
          return AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVIDAD RECIENTE',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (items.isNotEmpty)
                      InkWell(
                        onTap: onViewHistory,
                        child: Text(
                          'Ver todo (${items.length})',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (items.isEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.history,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sin actividad registrada',
                              style: AppTypography.titleSmall.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tus análisis guardados se sincronizarán aquí.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Most recent item
                  Builder(
                    builder: (context) {
                      final latest = items.first;
                      final binColor = AppColors.getBinColor(latest.classKey);
                      final formattedDate =
                          DateFormat('dd/MM/yyyy • HH:mm').format(latest.timestamp);

                      return Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: binColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              LucideIcons.recycle,
                              size: 20,
                              color: binColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      latest.displayName,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    WasteBadge(
                                      label:
                                          '${(latest.confidence * 100).toStringAsFixed(0)}%',
                                      color: latest.isLowConfidence
                                          ? AppColors.warning
                                          : AppColors.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${latest.recommendedBin.split('(').first.trim()} • $formattedDate',
                                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
