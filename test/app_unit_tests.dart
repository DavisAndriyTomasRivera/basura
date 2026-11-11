import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:basura/core/constants/app_constants.dart';
import 'package:basura/core/utils/image_preprocessor.dart';
import 'package:basura/features/classifier/models/classification_result.dart';
import 'package:basura/features/classifier/models/prediction_score.dart';
import 'package:basura/features/education/models/waste_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Metadata & Category Verification', () {
    test('metadata.json contains exact 7 classes matching specifications', () {
      final file = File('assets/model/metadata.json');
      expect(file.existsSync(), isTrue);

      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final classes = List<String>.from(json['clases'] as List);

      // Order must match strictly
      expect(classes, [
        'metal',
        'organico',
        'otros',
        'papel_carton',
        'peligroso',
        'plastico',
        'vidrio',
      ]);

      expect(json['img_size'], [224, 224]);
      expect(json['version'], '2.0');

      final binMap = Map<String, dynamic>.from(json['bin_map'] as Map);
      for (final cls in classes) {
        expect(binMap.containsKey(cls), isTrue);
      }
    });

    test('All 7 WasteCategory definitions correspond to model classes', () {
      final file = File('assets/model/metadata.json');
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final classes = List<String>.from(json['clases'] as List);

      for (final cls in classes) {
        final category = WasteCategory.getByKey(cls);
        expect(category.key, cls);
        expect(category.name.isNotEmpty, isTrue);
        expect(category.binName.isNotEmpty, isTrue);
        expect(category.examples.isNotEmpty, isTrue);
        expect(category.disposalAdvice.isNotEmpty, isTrue);
        expect(category.recyclingImpact.isNotEmpty, isTrue);
      }
    });
  });

  group('Image Preprocessor Pipeline', () {
    test('Correctly crops square and resizes to 224x224 RGB without dividing by 255', () {
      // Create a test synthetic image (300x200)
      final testImg = img.Image(width: 300, height: 200);
      for (int y = 0; y < 200; y++) {
        for (int x = 0; x < 300; x++) {
          testImg.setPixelRgb(x, y, 120, 200, 50);
        }
      }
      final encodedBytes = Uint8List.fromList(img.encodeJpg(testImg));

      // Run preprocessing
      final tensor = ImagePreprocessor.preprocessImage(
        encodedBytes,
        targetWidth: 224,
        targetHeight: 224,
      );

      // Verify shape: [1, 224, 224, 3]
      expect(tensor.length, 1);
      expect(tensor[0].length, 224);
      expect(tensor[0][0].length, 224);
      expect(tensor[0][0][0].length, 3);

      // Verify values are in 0.0 - 255.0 range (not normalized between 0-1)
      final r = tensor[0][0][0][0];
      final g = tensor[0][0][0][1];
      final b = tensor[0][0][0][2];

      expect(r, inInclusiveRange(0.0, 255.0));
      expect(g, inInclusiveRange(0.0, 255.0));
      expect(b, inInclusiveRange(0.0, 255.0));

      // Check approximate expected RGB values
      expect((r - 120).abs(), lessThan(15));
      expect((g - 200).abs(), lessThan(15));
      expect((b - 50).abs(), lessThan(15));
    });
  });

  group('Classification Result & Serialization', () {
    test('Json serialization and deserialization works seamlessly', () {
      final now = DateTime.now();
      final original = ClassificationResult(
        id: 'test-123',
        classKey: 'plastico',
        displayName: 'Plástico',
        confidence: 0.945,
        recommendedBin: 'Tacho blanco (plásticos)',
        disposalAdvice: 'Vaciar y enjuagar',
        imagePath: '/path/to/test.jpg',
        timestamp: now,
        topPredictions: [
          const PredictionScore(
            classKey: 'plastico',
            displayName: 'Plástico',
            confidence: 0.945,
            binName: 'Tacho blanco (plásticos)',
          ),
          const PredictionScore(
            classKey: 'vidrio',
            displayName: 'Vidrio',
            confidence: 0.035,
            binName: 'Tacho verde (vidrio)',
          ),
          const PredictionScore(
            classKey: 'metal',
            displayName: 'Metal',
            confidence: 0.020,
            binName: 'Tacho amarillo (metales)',
          ),
        ],
        isLowConfidence: false,
      );

      final map = original.toJson();
      final restored = ClassificationResult.fromJson(map);

      expect(restored.id, 'test-123');
      expect(restored.classKey, 'plastico');
      expect(restored.displayName, 'Plástico');
      expect(restored.confidence, 0.945);
      expect(restored.recommendedBin, 'Tacho blanco (plásticos)');
      expect(restored.topPredictions.length, 3);
      expect(restored.isLowConfidence, isFalse);
    });

    test('Threshold triggers low confidence warning when confidence < 0.60', () {
      final lowResult = ClassificationResult(
        id: 'test-low',
        classKey: 'otros',
        displayName: 'Otros',
        confidence: 0.52,
        recommendedBin: 'Tacho negro (no aprovechables)',
        disposalAdvice: 'Disponer en bolsa cerrada',
        imagePath: '/path/to/low.jpg',
        timestamp: DateTime.now(),
        topPredictions: [],
        isLowConfidence: 0.52 < AppConstants.lowConfidenceThreshold,
      );

      expect(lowResult.isLowConfidence, isTrue);
      expect(AppConstants.lowConfidenceThreshold, 0.60);
    });
  });
}
