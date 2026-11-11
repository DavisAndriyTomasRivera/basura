import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';

class WasteCategory {
  final String key;
  final String name;
  final String binName;
  final Color color;
  final IconData icon;
  final String shortDescription;
  final String disposalAdvice;
  final List<String> examples;
  final String recyclingImpact;

  const WasteCategory({
    required this.key,
    required this.name,
    required this.binName,
    required this.color,
    required this.icon,
    required this.shortDescription,
    required this.disposalAdvice,
    required this.examples,
    required this.recyclingImpact,
  });

  static const List<WasteCategory> allCategories = [
    WasteCategory(
      key: 'plastico',
      name: 'Plástico',
      binName: 'Tacho blanco (plásticos)',
      color: AppColors.binPlastico,
      icon: LucideIcons.package,
      shortDescription:
          'Materiales termoplásticos y polímeros reciclables como botellas PET, envases PEAD y bolsas limpias.',
      disposalAdvice:
          'Vacía el contenido, enjuaga los residuos líquidos o grasas, deja secar y compacta el envase para reducir volumen.',
      examples: [
        'Botellas de agua y bebidas (PET)',
        'Envases de champú y detergente (PEAD)',
        'Tapas de plástico',
        'Bolsas limpias y secas',
      ],
      recyclingImpact:
          'Reciclar 1 tonelada de plástico ahorra hasta 2,000 litros de petróleo crudo y reduce la contaminación de ecosistemas marinos.',
    ),
    WasteCategory(
      key: 'papel_carton',
      name: 'Papel y Cartón',
      binName: 'Tacho azul (papel y cartón)',
      color: AppColors.binPapelCarton,
      icon: LucideIcons.newspaper,
      shortDescription:
          'Fibras celulósicas secas y limpias procedentes de embalajes, correspondencia, publicaciones y empaques.',
      disposalAdvice:
          'Asegúrate de que no tenga restos de comida, salsas ni aceites. Retira cintas adhesivas excesivas y desdobla las cajas.',
      examples: [
        'Cajas de cartón corrugado',
        'Periódicos, revistas y folletos',
        'Hojas bond de oficina',
        'Bolsas de papel kraft sin grasa',
      ],
      recyclingImpact:
          'Por cada tonelada de cartón y papel reciclado se salvan aproximadamente 17 árboles maduros y se reduce un 40% el consumo energético.',
    ),
    WasteCategory(
      key: 'vidrio',
      name: 'Vidrio',
      binName: 'Tacho verde (vidrio)',
      color: AppColors.binVidrio,
      icon: LucideIcons.wine,
      shortDescription:
          'Envases y botellas de vidrio silicatado 100% infinitamente reciclables sin perder propiedades físicas.',
      disposalAdvice:
          'Enjuaga el envase para eliminar olores y líquidos. Retira tapas metálicas o plásticas antes de depositarlo. No incluir espejos ni cerámica.',
      examples: [
        'Botellas de bebidas y licores',
        'Frascos de conservas y mermeladas',
        'Envases de perfumes y colonias',
        'Tarros de alimentos',
      ],
      recyclingImpact:
          'El vidrio puede reciclarse indefinidamente. 3 botellas recicladas ahorran la energía necesaria para mantener encendida una bombilla LED por 100 horas.',
    ),
    WasteCategory(
      key: 'metal',
      name: 'Metal',
      binName: 'Tacho amarillo (metales)',
      color: AppColors.binMetal,
      icon: LucideIcons.shieldAlert,
      shortDescription:
          'Metales ferrosos y no ferrosos como aluminio, hojalata y acero presentes en latas y perfiles.',
      disposalAdvice:
          'Lava las latas para retirar residuos orgánicos, escurre bien y aplasta suavemente si es aluminio para optimizar espacio.',
      examples: [
        'Latas de refresco o cerveza (aluminio)',
        'Latas de conserva y atún (hojalata)',
        'Tapas corona metálicas',
        'Papel de aluminio limpio',
      ],
      recyclingImpact:
          'El reciclaje de aluminio consume un 95% menos energía que extraerlo directamente del mineral de bauxita.',
    ),
    WasteCategory(
      key: 'organico',
      name: 'Orgánico',
      binName: 'Tacho marrón (orgánicos)',
      color: AppColors.binOrganico,
      icon: LucideIcons.leaf,
      shortDescription:
          'Restos de materia biodegradable de origen vegetal o animal aptos para procesos de compostaje y valorización biológica.',
      disposalAdvice:
          'Drena el exceso de humedad antes de desecharlos. Ideal para alimentar composteras domésticas o municipales.',
      examples: [
        'Cáscaras de frutas y verduras',
        'Restos de café y té',
        'Cáscaras de huevo',
        'Restos de poda y hojas secas',
      ],
      recyclingImpact:
          'El compostaje evita que la materia orgánica se descomponga anaeróbicamente en vertederos generando gas metano de efecto invernadero.',
    ),
    WasteCategory(
      key: 'peligroso',
      name: 'Peligroso',
      binName: 'Tacho rojo (residuos peligrosos)',
      color: AppColors.binPeligroso,
      icon: LucideIcons.triangleAlert,
      shortDescription:
          'Residuos con características tóxicas, corrosivas, reactivas, inflamables o biológico-infecciosas.',
      disposalAdvice:
          'No mezclar con la basura ordinaria ni verter al desagüe. Almacenar en contenedores resistentes y llevar a puntos de acopio autorizados.',
      examples: [
        'Pilas y baterías de litio',
        'Medicamentos vencidos',
        'Envases de insecticidas y solventes',
        'Focos fluorescentes y bombillas ahorradoras',
      ],
      recyclingImpact:
          'Una sola pila de botón puede contaminar hasta 600,000 litros de agua subterránea si se arroja en un vertedero convencional.',
    ),
    WasteCategory(
      key: 'otros',
      name: 'Otros (No aprovechables)',
      binName: 'Tacho negro (no aprovechables)',
      color: AppColors.binOtros,
      icon: LucideIcons.trash2,
      shortDescription:
          'Materiales que no pueden ser reciclados o valorizados con la tecnología local disponible y deben ir a relleno sanitario.',
      disposalAdvice:
          'Empacar en bolsa resistente y cerrar herméticamente para garantizar la seguridad del personal recolector.',
      examples: [
        'Papel higiénico y servilletas usadas',
        'Envolturas de golosinas metalizadas',
        'Colillas de cigarrillo',
        'Cerámicas y pañales desechables',
      ],
      recyclingImpact:
          'Una clasificación precisa asegura que solo el residuo verdaderamente no recuperable llegue a la disposición final, alargando la vida útil del relleno.',
    ),
  ];

  static WasteCategory getByKey(String key) {
    final normalized = key.toLowerCase().trim();
    return allCategories.firstWhere(
      (c) => c.key == normalized,
      orElse: () => allCategories.last, // 'otros' as fallback
    );
  }
}
