import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../models/waste_category.dart';
import '../widgets/category_card.dart';
import 'category_detail_sheet.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  String _searchQuery = '';

  List<WasteCategory> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) {
      return WasteCategory.allCategories;
    }
    final q = _searchQuery.toLowerCase().trim();
    return WasteCategory.allCategories.where((cat) {
      final matchName = cat.name.toLowerCase().contains(q);
      final matchBin = cat.binName.toLowerCase().contains(q);
      final matchEx = cat.examples.any((e) => e.toLowerCase().contains(q));
      return matchName || matchBin || matchEx;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _filteredCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Guía de Residuos'),
      ),
      body: CustomScrollView(
        slivers: [
          // Header Introduction
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7 Categorías Normadas',
                    style: AppTypography.displayMedium.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Conoce los contenedores oficiales, ejemplos de materiales y cómo disponer cada residuo para maximizar su valorización.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.search, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Buscar material (ej. botellas, cartón, pilas)...',
                              hintStyle: AppTypography.bodySmall,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 16),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Categories List
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: categories.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(LucideIcons.searchX, size: 40, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'No se encontraron categorías',
                              style: AppTypography.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Intenta con otro término de búsqueda.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList.separated(
                    itemCount: categories.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () => CategoryDetailSheet.show(context, cat),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
