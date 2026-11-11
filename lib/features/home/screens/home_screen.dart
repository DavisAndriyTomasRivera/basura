import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/activity_summary_card.dart';
import '../widgets/ai_pipeline_card.dart';
import '../widgets/category_preview_carousel.dart';
import '../widgets/hero_banner.dart';

class HomeScreen extends StatelessWidget {
  final Function(ImageSource?) onStartClassify;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToEducation;

  const HomeScreen({
    super.key,
    required this.onStartClassify,
    required this.onNavigateToHistory,
    required this.onNavigateToEducation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.leaf,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Basura',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'AI Solid Waste Classifier',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            tooltip: 'Configuración',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Hero Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HeroBanner(
                onScanPressed: () => onStartClassify(ImageSource.camera),
                onGalleryPressed: () => onStartClassify(ImageSource.gallery),
              ),
            ),

            const SizedBox(height: 24),

            // Waste Categories Carousel
            CategoryPreviewCarousel(
              onViewAll: onNavigateToEducation,
            ),

            const SizedBox(height: 24),

            // Real Activity Summary Card
            ActivitySummaryCard(
              onViewHistory: onNavigateToHistory,
            ),

            const SizedBox(height: 24),

            // AI Working Pipeline Explanation
            const AIPipelineCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
