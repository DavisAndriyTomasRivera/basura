import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/image_preprocessor.dart';
import '../../education/models/waste_category.dart';
import '../models/classification_result.dart';
import '../models/prediction_score.dart';

/// Senior Machine Learning & Flutter Service for TensorFlow Lite inference.
/// Handles:
/// - Dynamic metadata loading & class validation
/// - Model interpreter caching (avoiding repeated initialization)
/// - Asynchronous preprocessing & tensor execution
/// - Top-3 prediction extraction & threshold validation
class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  Map<String, dynamic>? _metadata;
  List<String> _classes = [];
  Map<String, String> _binMap = {};
  int _inputWidth = 224;
  int _inputHeight = 224;
  String _activeModelName = 'MobileNetV2 Fine-Tuning';
  String _modelVersion = '2.0';
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  String get activeModelName => _activeModelName;
  String get modelVersion => _modelVersion;
  List<String> get classes => List.unmodifiable(_classes);
  Map<String, String> get binMap => Map.unmodifiable(_binMap);
  Map<String, dynamic>? get rawMetadata => _metadata;

  /// Initializes the service by reading metadata.json and loading the TFLite model.
  Future<void> initialize() async {
    if (_isInitialized && _interpreter != null) return;

    try {
      dev.log('Inicializando TFLiteService...', name: 'TFLiteService');

      // 1. Read metadata.json
      await _loadMetadata();

      // 2. Load TFLite Model (preferring FP16 optimized version)
      await _loadInterpreter();

      _isInitialized = true;
      dev.log('TFLiteService inicializado correctamente con ${_classes.length} clases.',
          name: 'TFLiteService');
    } catch (e, stack) {
      dev.log('Error crítico al inicializar TFLiteService: $e',
          name: 'TFLiteService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> _loadMetadata() async {
    String? jsonContent;

    // Try primary asset path, then alternative path
    for (final path in [
      AppConstants.metadataAsset,
      AppConstants.metadataAssetAlt,
    ]) {
      try {
        jsonContent = await rootBundle.loadString(path);
        if (jsonContent.isNotEmpty) break;
      } catch (_) {
        // Try next path
      }
    }

    if (jsonContent == null) {
      throw FileSystemException('No se pudo encontrar ni leer el archivo metadata.json');
    }

    final data = jsonDecode(jsonContent) as Map<String, dynamic>;
    _metadata = data;

    // Extract classes maintaining strict order from JSON
    final rawClasses = data['clases'] as List<dynamic>?;
    if (rawClasses == null || rawClasses.isEmpty) {
      throw FormatException('El campo "clases" en metadata.json es inválido o está vacío.');
    }
    _classes = rawClasses.map((e) => e.toString()).toList();

    // Extract bin map
    final rawBinMap = data['bin_map'] as Map<String, dynamic>?;
    if (rawBinMap != null) {
      _binMap = rawBinMap.map((k, v) => MapEntry(k, v.toString()));
    }

    // Extract image size
    final rawSize = data['img_size'] as List<dynamic>?;
    if (rawSize != null && rawSize.length >= 2) {
      _inputWidth = (rawSize[0] as num).toInt();
      _inputHeight = (rawSize[1] as num).toInt();
    }

    _activeModelName = data['modelo']?.toString() ?? 'MobileNetV2 Fine-Tuning';
    _modelVersion = data['version']?.toString() ?? '2.0';

    dev.log(
      'Metadata cargada exitosamente: Modelo=$_activeModelName, Clases=${_classes.length}, Tamaño=[$_inputWidth, $_inputHeight]',
      name: 'TFLiteService',
    );
  }

  Future<void> _loadInterpreter() async {
    final options = InterpreterOptions()..threads = 2;

    // Prioritize FP16 model (half memory footprint, optimal mobile performance)
    final candidatePaths = [
      AppConstants.modelFp16Asset,
      AppConstants.modelFp16AssetAlt,
      AppConstants.modelV1Asset,
      AppConstants.modelV1AssetAlt,
    ];

    Object? lastError;
    for (final path in candidatePaths) {
      try {
        dev.log('Intentando cargar modelo desde: $path', name: 'TFLiteService');
        _interpreter = await Interpreter.fromAsset(path, options: options);
        dev.log('Modelo cargado exitosamente desde: $path', name: 'TFLiteService');
        _verifyTensorShapes();
        return;
      } catch (e) {
        lastError = e;
        dev.log('No se pudo cargar desde $path: $e', name: 'TFLiteService');
      }
    }

    throw StateError(
      'No fue posible instanciar el intérprete TFLite con ninguno de los modelos disponibles. Error: $lastError',
    );
  }

  void _verifyTensorShapes() {
    if (_interpreter == null) return;

    final inputTensors = _interpreter!.getInputTensors();
    final outputTensors = _interpreter!.getOutputTensors();

    dev.log(
      'Tensors verificados -> Entrada: ${inputTensors.map((t) => '${t.name} ${t.shape} ${t.type}')} | Salida: ${outputTensors.map((t) => '${t.name} ${t.shape} ${t.type}')}',
      name: 'TFLiteService',
    );

    // Validate expected input dimensions
    if (inputTensors.isNotEmpty) {
      final inShape = inputTensors.first.shape;
      if (inShape.length == 4) {
        _inputHeight = inShape[1];
        _inputWidth = inShape[2];
      }
    }
  }

  /// Runs inference on the provided image bytes.
  /// 1. Centered square crop
  /// 2. Resize to 224x224 RGB
  /// 3. Values 0.0 - 255.0 (model normalizes internally)
  /// 4. Asynchronous tensor run
  /// 5. Top-3 scores and confidence threshold evaluation
  Future<ClassificationResult> classifyImage({
    required Uint8List imageBytes,
    required String imagePath,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      await initialize();
    }

    if (_interpreter == null) {
      throw StateError('El intérprete TensorFlow Lite no está disponible.');
    }

    // Step 1 & 2: Preprocess image
    final inputTensor = ImagePreprocessor.preprocessImage(
      imageBytes,
      targetWidth: _inputWidth,
      targetHeight: _inputHeight,
    );

    // Output buffer: [1, numberOfClasses]
    final numClasses = _classes.isNotEmpty ? _classes.length : 7;
    final outputTensor = List.generate(
      1,
      (_) => List<double>.filled(numClasses, 0.0),
    );

    // Step 3: Run inference
    _interpreter!.run(inputTensor, outputTensor);

    final rawScores = outputTensor.first;

    // If scores are raw logits, apply softmax to convert to probabilities
    final probabilities = _ensureProbabilities(rawScores);

    // Step 4: Map predictions and sort descending
    final List<PredictionScore> allPredictions = [];
    for (int i = 0; i < probabilities.length && i < _classes.length; i++) {
      final classKey = _classes[i];
      final category = WasteCategory.getByKey(classKey);
      final bin = _binMap[classKey] ?? category.binName;

      allPredictions.add(
        PredictionScore(
          classKey: classKey,
          displayName: category.name,
          confidence: probabilities[i],
          binName: bin,
        ),
      );
    }

    allPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    final bestPrediction = allPredictions.isNotEmpty
        ? allPredictions.first
        : PredictionScore(
            classKey: 'otros',
            displayName: 'Otros',
            confidence: 0.0,
            binName: _binMap['otros'] ?? 'Tacho negro (no aprovechables)',
          );

    final bestCategory = WasteCategory.getByKey(bestPrediction.classKey);
    final top3 = allPredictions.take(3).toList();
    final isLow = bestPrediction.confidence < AppConstants.lowConfidenceThreshold;

    return ClassificationResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classKey: bestPrediction.classKey,
      displayName: bestPrediction.displayName,
      confidence: bestPrediction.confidence,
      recommendedBin: bestPrediction.binName,
      disposalAdvice: bestCategory.disposalAdvice,
      imagePath: imagePath,
      timestamp: DateTime.now(),
      topPredictions: top3,
      isLowConfidence: isLow,
      modelName: _activeModelName,
    );
  }

  /// Ensures probabilities sum to approximately 1.0 (Softmax if needed)
  List<double> _ensureProbabilities(List<double> rawScores) {
    if (rawScores.isEmpty) return rawScores;

    // Check if already probabilities (all >= 0 and sum ~= 1.0)
    final sum = rawScores.fold<double>(0.0, (acc, v) => acc + v);
    final allNonNegative = rawScores.every((v) => v >= 0.0);

    if (allNonNegative && (sum - 1.0).abs() < 0.05) {
      return rawScores;
    }

    // Apply numerically stable Softmax
    final double maxLogit = rawScores.reduce((curr, next) => curr > next ? curr : next);
    final expScores = rawScores.map((v) => math.exp(v - maxLogit)).toList();
    final expSum = expScores.fold<double>(0.0, (acc, v) => acc + v);

    if (expSum == 0) return rawScores;
    return expScores.map((v) => v / expSum).toList();
  }

  /// Releases resources cleanly
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
