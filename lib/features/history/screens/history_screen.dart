import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../classifier/models/classification_result.dart';
import '../services/history_service.dart';
import '../widgets/history_empty_state.dart';
import '../widgets/history_item_card.dart';
import 'history_detail_sheet.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onNavigateToClassifier;

  const HistoryScreen({
    super.key,
    required this.onNavigateToClassifier,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _historyService.initialize();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿Vaciar historial?', style: AppTypography.titleMedium),
        content: Text(
          'Se eliminarán permanentemente todas las clasificaciones guardadas en este dispositivo.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Vaciar', style: AppTypography.labelLarge.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial de Clasificaciones'),
        actions: [
          ValueListenableBuilder<List<ClassificationResult>>(
            valueListenable: _historyService.historyNotifier,
            builder: (context, list, _) {
              if (list.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(LucideIcons.trash2, size: 20),
                tooltip: 'Vaciar historial',
                onPressed: _confirmClearAll,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ClassificationResult>>(
        valueListenable: _historyService.historyNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return HistoryEmptyState(
              onStartClassifying: widget.onNavigateToClassifier,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} ${items.length == 1 ? 'REGISTRO GUARDADO' : 'REGISTROS GUARDADOS'}',
                      style: AppTypography.labelSmall.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Desliza para eliminar',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return HistoryItemCard(
                      item: item,
                      onTap: () {
                        HistoryDetailSheet.show(
                          context,
                          item: item,
                          onDelete: () => _historyService.deleteClassification(item.id),
                        );
                      },
                      onDelete: () => _historyService.deleteClassification(item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
