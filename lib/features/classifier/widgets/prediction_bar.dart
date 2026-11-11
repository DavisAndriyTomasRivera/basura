import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/prediction_score.dart';

class PredictionBar extends StatelessWidget {
  final PredictionScore prediction;
  final bool isTop;

  const PredictionBar({
    super.key,
    required this.prediction,
    this.isTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (prediction.confidence * 100).clamp(0.0, 100.0);
    final color = AppColors.getBinColor(prediction.classKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    prediction.displayName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: isTop ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                  color: isTop ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prediction.confidence.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isTop ? color : color.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
