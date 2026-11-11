import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../services/tflite_service.dart';
import '../widgets/analysis_loading_view.dart';
import 'result_screen.dart';

class ClassifierScreen extends StatefulWidget {
  final ImageSource? autoPickSource;

  const ClassifierScreen({
    super.key,
    this.autoPickSource,
  });

  @override
  State<ClassifierScreen> createState() => _ClassifierScreenState();
}

class _ClassifierScreenState extends State<ClassifierScreen> {
  final ImagePicker _picker = ImagePicker();
  final TFLiteService _tfliteService = TFLiteService();

  XFile? _selectedFile;
  bool _isAnalyzing = false;
  int _analysisStage = 0; // 0: Preparando, 1: Procesando recorte, 2: Analizando IA
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Warm up model in background if not already loaded
    _tfliteService.initialize().catchError((e) {
      debugPrint('Aviso: TFLiteService inicialización diferida: $e');
    });

    if (widget.autoPickSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.autoPickSource!);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'No se pudo acceder a la imagen: $e';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedFile == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _analysisStage = 0;
      _errorMessage = null;
    });

    try {
      // Stage 0: Preparando imagen
      await Future.delayed(const Duration(milliseconds: 350));
      final bytes = await _selectedFile!.readAsBytes();

      if (!mounted) return;
      setState(() => _analysisStage = 1);

      // Stage 1: Procesando recorte 224x224 RGB
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      setState(() => _analysisStage = 2);

      // Stage 2: Inferencia TFLite
      final result = await _tfliteService.classifyImage(
        imageBytes: bytes,
        imagePath: _selectedFile!.path,
      );

      // Brief pause to complete visual animation
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to Result Screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
        ),
      );

      // Reset state on return
      if (mounted) {
        setState(() {
          _selectedFile = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Error durante la clasificación: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clasificador de Residuos'),
        actions: [
          if (_selectedFile != null && !_isAnalyzing)
            IconButton(
              icon: const Icon(LucideIcons.trash2, size: 20),
              tooltip: 'Descartar imagen',
              onPressed: () {
                setState(() => _selectedFile = null);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Info Bar
                _buildHeaderPill(),

                const SizedBox(height: 20),

                // Main Image Container or Drop Area
                _selectedFile == null ? _buildEmptySelector() : _buildImagePreview(),

                const SizedBox(height: 20),

                // Error Message if any
                if (_errorMessage != null) ...[
                  _buildErrorCard(),
                  const SizedBox(height: 16),
                ],

                // Action Area
                if (_selectedFile == null)
                  _buildSelectionButtons()
                else
                  _buildAnalysisControls(),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Analysis Loading Overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.4),
                child: AnalysisLoadingView(stageIndex: _analysisStage),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Modelo MobileNetV2 Fine-Tuning v2.0 cargado',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildEmptySelector() {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                LucideIcons.scanLine,
                size: 38,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Identifica cualquier residuo',
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Toma una foto con la cámara o selecciona una imagen de tu galería para analizar su categoría con IA.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.leaf, size: 12, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  '7 categorías soportadas • Tachos normados',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(_selectedFile!.path),
                fit: BoxFit.cover,
              ),
              // Subtle corner guides to suggest scanning
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        'Vista previa',
                        style: AppTypography.labelSmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildSelectionButtons() {
    return Column(
      children: [
        CustomButton(
          label: 'Tomar fotografía',
          icon: LucideIcons.camera,
          onPressed: () => _pickImage(ImageSource.camera),
        ),
        const SizedBox(height: 12),
        CustomButton(
          label: 'Elegir de la galería',
          icon: LucideIcons.images,
          variant: ButtonVariant.secondary,
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Widget _buildAnalysisControls() {
    return Column(
      children: [
        CustomButton(
          label: 'Analizar con Inteligencia Artificial',
          icon: LucideIcons.sparkles,
          isLoading: _isAnalyzing,
          onPressed: _analyzeImage,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Cámara',
                icon: LucideIcons.camera,
                variant: ButtonVariant.outline,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Galería',
                icon: LucideIcons.images,
                variant: ButtonVariant.outline,
                onPressed: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.triangleAlert, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: const Color(0xFF991B1B)),
            ),
          ),
        ],
      ),
    );
  }
}
