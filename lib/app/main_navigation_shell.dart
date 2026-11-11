import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';
import '../features/home/screens/home_screen.dart';
import '../features/classifier/screens/classifier_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/education/screens/education_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  ImageSource? _pendingImageSource;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _pendingImageSource = null;
    });
  }

  void _triggerClassification([ImageSource? source]) {
    setState(() {
      _pendingImageSource = source;
      _currentIndex = 1; // Tab 1 is Classifier
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onStartClassify: (source) => _triggerClassification(source),
        onNavigateToHistory: () => _onTabSelected(2),
        onNavigateToEducation: () => _onTabSelected(3),
      ),
      ClassifierScreen(
        key: ValueKey<String>('classifier_${_pendingImageSource?.name ?? 'direct'}'),
        autoPickSource: _pendingImageSource,
      ),
      HistoryScreen(
        onNavigateToClassifier: () => _triggerClassification(),
      ),
      const EducationScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: LucideIcons.home,
                  label: 'Inicio',
                ),
                _buildClassifyCenterItem(),
                _buildNavItem(
                  index: 2,
                  icon: LucideIcons.history,
                  label: 'Historial',
                ),
                _buildNavItem(
                  index: 3,
                  icon: LucideIcons.bookOpen,
                  label: 'Aprender',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassifyCenterItem() {
    final isSelected = _currentIndex == 1;

    return GestureDetector(
      onTap: () => _triggerClassification(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: AppColors.secondary, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.scanLine,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              'Clasificar',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
