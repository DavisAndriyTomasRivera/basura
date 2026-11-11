import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function() onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 3;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  Future<void> _onPrimaryAction() async {
    if (_isCompleting) return;

    if (_currentPage < _pageCount - 1) {
      await _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    setState(() => _isCompleting = true);
    try {
      await widget.onComplete();
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  Text(
                    'BASURA',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    LucideIcons.leaf,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _WelcomePage(),
                  _InstitutionPage(),
                  _TeamPage(),
                ],
              ),
            ),
            _OnboardingFooter(
              currentPage: _currentPage,
              isCompleting: _isCompleting,
              onPressed: _onPrimaryAction,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  final int currentPage;
  final bool isCompleting;
  final VoidCallback onPressed;

  const _OnboardingFooter({
    required this.currentPage,
    required this.isCompleting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == 2;
    final labelFontSize = MediaQuery.textScalerOf(context).scale(14);
    final buttonHeight = (54 * labelFontSize / 14).clamp(54.0, 100.0);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PASO ${currentPage + 1} DE 3',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Paso ${currentPage + 1} de 3',
                child: Row(
                  children: List.generate(3, (index) {
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                        decoration: BoxDecoration(
                          color: index <= currentPage
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: isCompleting ? null : onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.65,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isCompleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isLastPage ? 'Comenzar a explorar' : 'Siguiente',
                          textAlign: TextAlign.center,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotSize = (constraints.maxHeight * 0.43)
            .clamp(180.0, 340.0)
            .toDouble();
        return _ScrollablePage(
          minHeight: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.88, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) => Opacity(
                  opacity: scale.clamp(0, 1),
                  child: Transform.scale(scale: scale, child: child),
                ),
                child: Container(
                  width: mascotSize,
                  height: mascotSize,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Semantics(
                    label: 'Phoenix, mascota robot de Basura',
                    image: true,
                    child: Lottie.asset(
                      AppConstants.phoenixAnimation,
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'Tecnología para un futuro más limpio',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 12),
              Text(
                'Conoce Basura, una aplicación inteligente que utiliza inteligencia artificial para identificar y clasificar residuos sólidos, facilitando su correcta disposición.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InstitutionPage extends StatelessWidget {
  const _InstitutionPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final logoSize = (constraints.maxHeight * 0.23)
            .clamp(88.0, 132.0)
            .toDouble();
        return _ScrollablePage(
          minHeight: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppConstants.uncpLogo,
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
                semanticsLabel:
                    'Logo de la Universidad Nacional del Centro del Perú',
              ),
              const SizedBox(height: 14),
              Text(
                'UNIVERSIDAD NACIONAL\nDEL CENTRO DEL PERÚ',
                textAlign: TextAlign.center,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.45,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Un proyecto con identidad universitaria',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 18),
              _InstitutionDetailsCard(),
              const SizedBox(height: 16),
              Text(
                'Desarrollado en la Universidad Nacional del Centro del Perú, como iniciativa de innovación tecnológica y compromiso ambiental.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InstitutionDetailsCard extends StatelessWidget {
  const _InstitutionDetailsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'CURSO', value: 'Ingeniería del Conocimiento'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _DetailRow(
            label: 'DOCENTE',
            value: 'Msc. Jaime Antonio Huaytalla Pariona',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamPage extends StatelessWidget {
  const _TeamPage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _ScrollablePage(
          minHeight: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Detrás de Basura',
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(fontSize: 27),
              ),
              const SizedBox(height: 8),
              Text(
                'Un proyecto desarrollado en equipo.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EQUIPO DEL PROYECTO',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _TeamMember(
                      name: 'Andriy Tomas Rivera',
                      role: 'CEO',
                      highlighted: true,
                    ),
                    const _TeamMember(name: 'Echegoyen Rojas Anahi'),
                    const _TeamMember(name: 'Espinoza Inga Deysi'),
                    const _TeamMember(name: 'Paucar Ramirez Carolina'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppConstants.uncpLogo,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                    semanticsLabel:
                        'Logo de la Universidad Nacional del Centro del Perú',
                  ),
                  const SizedBox(width: 9),
                  Flexible(
                    child: Text(
                      'Universidad Nacional del Centro del Perú',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String? role;
  final bool highlighted;

  const _TeamMember({required this.name, this.role, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLight : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.userRound,
            size: 18,
            color: highlighted ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          if (role != null)
            Text(
              role!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScrollablePage extends StatelessWidget {
  final double minHeight;
  final Widget child;

  const _ScrollablePage({required this.minHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight - 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: child,
          ),
        ),
      ),
    );
  }
}
