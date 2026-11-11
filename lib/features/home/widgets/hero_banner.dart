import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback onGalleryPressed;

  const HeroBanner({
    super.key,
    required this.onScanPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      backgroundColor: AppColors.primary,
      borderColor: AppColors.primaryDark,
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles, size: 13, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'AI MobileNetV2 • 89.6% precisión',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.leaf, color: AppColors.secondary, size: 22),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Clasifica residuos con visión artificial',
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Apunta con tu cámara a cualquier residuo para identificar su tacho normado y las pautas para su correcta valorización.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomButton(
                  label: 'Escanear residuo',
                  icon: LucideIcons.camera,
                  customColor: Colors.white,
                  textColor: AppColors.primary,
                  onPressed: onScanPressed,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: CustomButton(
                  label: 'Galería',
                  icon: LucideIcons.images,
                  variant: ButtonVariant.secondary,
                  customColor: Colors.white.withValues(alpha: 0.2),
                  textColor: Colors.white,
                  onPressed: onGalleryPressed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
