import 'prediction_score.dart';

class ClassificationResult {
  final String id;
  final String classKey;
  final String displayName;
  final double confidence;
  final String recommendedBin;
  final String disposalAdvice;
  final String imagePath;
  final DateTime timestamp;
  final List<PredictionScore> topPredictions;
  final bool isLowConfidence;
  final String modelName;

  ClassificationResult({
    required this.id,
    required this.classKey,
    required this.displayName,
    required this.confidence,
    required this.recommendedBin,
    required this.disposalAdvice,
    required this.imagePath,
    required this.timestamp,
    required this.topPredictions,
    required this.isLowConfidence,
    this.modelName = 'MobileNetV2 Fine-Tuning v2.0',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'classKey': classKey,
        'displayName': displayName,
        'confidence': confidence,
        'recommendedBin': recommendedBin,
        'disposalAdvice': disposalAdvice,
        'imagePath': imagePath,
        'timestamp': timestamp.toIso8601String(),
        'topPredictions': topPredictions.map((p) => p.toJson()).toList(),
        'isLowConfidence': isLowConfidence,
        'modelName': modelName,
      };

  factory ClassificationResult.fromJson(Map<String, dynamic> json) =>
      ClassificationResult(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        classKey: json['classKey'] as String,
        displayName: json['displayName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        recommendedBin: json['recommendedBin'] as String,
        disposalAdvice: json['disposalAdvice'] as String? ?? '',
        imagePath: json['imagePath'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        topPredictions: (json['topPredictions'] as List<dynamic>?)
                ?.map((e) => PredictionScore.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        isLowConfidence: json['isLowConfidence'] as bool? ?? false,
        modelName: json['modelName'] as String? ?? 'MobileNetV2 Fine-Tuning v2.0',
      );
}
