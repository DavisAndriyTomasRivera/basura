import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

class WasteBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool isSolid;

  const WasteBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSolid ? effectiveColor : effectiveColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: isSolid
            ? null
            : Border.all(
                color: effectiveColor.withValues(alpha: 0.25),
                width: 1,
              ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: isSolid ? Colors.white : effectiveColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSolid ? Colors.white : effectiveColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
