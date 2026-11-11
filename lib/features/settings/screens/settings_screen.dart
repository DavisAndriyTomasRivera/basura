import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../history/services/history_service.dart';
import '../widgets/model_info_card.dart';
import '../widgets/setting_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HistoryService _historyService = HistoryService();

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Vaciar historial?', style: AppTypography.titleMedium),
        content: Text(
          'Se eliminarán todas las clasificaciones registradas localmente en este dispositivo.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: AppTypography.labelLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial eliminado exitosamente')),
        );
      }
    }
  }

  void _showDatasetsInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Datasets de Entrenamiento', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              'El modelo MobileNetV2 fue entrenado y validado utilizando colecciones abiertas de imágenes de residuos reales:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            _buildDatasetRow('Roboflow garbage-classification v6'),
            _buildDatasetRow('Roboflow waste-classification v3'),
            _buildDatasetRow('RealWaste (UCI Machine Learning, CC BY 4.0)'),
            _buildDatasetRow('TACO Trash Annotations (recortes contextuales)'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDatasetRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(LucideIcons.circleCheck, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configuración e IA'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'MODELO DE INTELIGENCIA ARTIFICIAL',
            style: AppTypography.labelSmall.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          const ModelInfoCard(),

          const SizedBox(height: 24),

          Text(
            'PARÁMETROS Y DATOS',
            style: AppTypography.labelSmall.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          SettingTile(
            icon: LucideIcons.sliders,
            title: 'Umbral de Certeza',
            subtitle: 'Alerta de baja confianza por debajo del 60%',
            trailing: Text(
              '60%',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          SettingTile(
            icon: LucideIcons.database,
            title: 'Fuentes de Datos (Datasets)',
            subtitle: 'Roboflow, RealWaste, TACO',
            onTap: _showDatasetsInfo,
          ),
          const SizedBox(height: 10),

          SettingTile(
            icon: LucideIcons.trash2,
            iconColor: AppColors.error,
            title: 'Vaciar Historial Local',
            subtitle: 'Eliminar registros de clasificaciones guardadas',
            onTap: _clearHistory,
          ),

          const SizedBox(height: 24),

          Text(
            'ACERCA DE',
            style: AppTypography.labelSmall.copyWith(
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          SettingTile(
            icon: LucideIcons.info,
            title: AppConstants.appName,
            subtitle: 'Versión ${AppConstants.appVersion} • Environmental Tech',
            trailing: const Text('v2.0.0'),
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                const Icon(LucideIcons.leaf, size: 24, color: AppColors.secondary),
                const SizedBox(height: 6),
                Text(
                  'Basura — Smart Waste Classification',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Inferencia Edge AI con TensorFlow Lite',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
