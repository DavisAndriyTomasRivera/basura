import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/waste_badge.dart';
import '../../education/models/waste_category.dart';
import '../../history/services/history_service.dart';
import '../models/classification_result.dart';
import '../widgets/bin_recommendation_card.dart';
import '../widgets/prediction_bar.dart';

class ResultScreen extends StatefulWidget {
  final ClassificationResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Auto-save result to history so user work is never lost
    _autoSave();
  }

  Future<void> _autoSave() async {
    try {
      await HistoryService().saveClassification(widget.result);
      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      debugPrint('Error al guardar en historial: $e');
    }
  }

  Future<void> _manualSave() async {
    if (_isSaved || _isSaving) return;
    setState(() => _isSaving = true);
    await HistoryService().saveClassification(widget.result);
    if (mounted) {
      setState(() {
        _isSaved = true;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.circleCheck, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Resultado guardado en el historial'),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final category = WasteCategory.getByKey(result.classKey);
    final binColor = AppColors.getBinColor(result.classKey);
    final percentage = (result.confidence * 100).clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resultado del Análisis'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? LucideIcons.circleCheck : LucideIcons.bookmark,
              color: _isSaved ? AppColors.success : AppColors.textPrimary,
            ),
            tooltip: _isSaved ? 'Guardado en historial' : 'Guardar',
            onPressed: _manualSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview with AI Tech Overlay
            _buildImageCard(result, binColor)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // Low Confidence Warning (if < 0.60)
            if (result.isLowConfidence)
              _buildLowConfidenceBanner()
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .shake(duration: 400.ms, hz: 3),

            if (result.isLowConfidence) const SizedBox(height: 16),

            // Main Classification Summary Card
            _buildClassificationCard(category, percentage, binColor)
                .animate()
                .fadeIn(delay: 100.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // Bin Recommendation Card
            BinRecommendationCard(
              classKey: result.classKey,
              binName: result.recommendedBin,
              disposalAdvice: result.disposalAdvice,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // Category Description & Examples Card
            _buildCategoryDetailsCard(category)
                .animate()
                .fadeIn(delay: 300.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // Top-3 Predictions Distribution Card
            _buildTopPredictionsCard(result)
                .animate()
                .fadeIn(delay: 400.ms, duration: 350.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // Action Buttons
            CustomButton(
              label: 'Clasificar otro residuo',
              icon: LucideIcons.camera,
              onPressed: () {
                Navigator.pop(context);
              },
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 10),

            CustomButton(
              label: 'Volver al inicio',
              icon: LucideIcons.house,
              variant: ButtonVariant.outline,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ).animate().fadeIn(delay: 550.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(ClassificationResult result, Color binColor) {
    final file = File(result.imagePath);

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (file.existsSync())
            Image.file(
              file,
              fit: BoxFit.cover,
            )
          else
            Container(
              color: AppColors.primaryLight,
              child: const Center(
                child: Icon(LucideIcons.image, size: 48, color: AppColors.primary),
              ),
            ),

          // Gradient overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Tech Tag
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WasteBadge(
                  label: result.displayName.toUpperCase(),
                  color: binColor,
                  isSolid: true,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.cpu, size: 12, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        'MobileNetV2 Fine-Tuning',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowConfidenceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.triangleAlert,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Predicción con baja certeza (< 60%)',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'El residuo no se distingue con suficiente claridad. Te sugerimos tomar otra fotografía más nítida, centrada y con mejor iluminación.',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard(
    WasteCategory category,
    double percentage,
    Color binColor,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Circular Confidence Indicator
          SizedBox(
            width: 74,
            height: 74,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressIndicator(
                    value: (percentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 7,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.result.isLowConfidence ? AppColors.warning : AppColors.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.result.isLowConfidence
                            ? AppColors.warning
                            : AppColors.primary,
                      ),
                    ),
                    Text(
                      'Certeza',
                      style: AppTypography.labelSmall.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          // Classification Title and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WasteBadge(
                      label: widget.result.isLowConfidence ? 'Baja certeza' : 'Alta certeza',
                      color: widget.result.isLowConfidence
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'IA Local',
                      style: AppTypography.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  category.name,
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDetailsCard(WasteCategory category) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'IMPACTO AMBIENTAL',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.recyclingImpact,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          Text(
            'EJEMPLOS HABITUALES',
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: category.examples.map((ex) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  ex,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPredictionsCard(ClassificationResult result) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROBABILIDADES DEL MODELO',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Top 3 clases',
                style: AppTypography.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.topPredictions.asMap().entries.map((entry) {
            final idx = entry.key;
            final pred = entry.value;
            return PredictionBar(
              prediction: pred,
              isTop: idx == 0,
            );
          }),
        ],
      ),
    );
  }
}
