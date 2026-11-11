import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/waste_badge.dart';
import '../../classifier/models/classification_result.dart';

class HistoryItemCard extends StatelessWidget {
  final ClassificationResult item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final binColor = AppColors.getBinColor(item.classKey);
    final percentage = (item.confidence * 100).clamp(0.0, 100.0);
    final formattedDate = DateFormat('dd/MM/yyyy • HH:mm').format(item.timestamp);
    final imageFile = File(item.imagePath);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 22),
      ),
      onDismissed: (_) => onDelete(),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageFile.existsSync()
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        LucideIcons.image,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        LucideIcons.image,
                        color: AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.displayName,
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      WasteBadge(
                        label: '${percentage.toStringAsFixed(0)}%',
                        color: item.isLowConfidence ? AppColors.warning : AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: binColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.recommendedBin,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.history, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),
            const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
