class PredictionScore {
  final String classKey;
  final String displayName;
  final double confidence;
  final String binName;

  const PredictionScore({
    required this.classKey,
    required this.displayName,
    required this.confidence,
    required this.binName,
  });

  Map<String, dynamic> toJson() => {
        'classKey': classKey,
        'displayName': displayName,
        'confidence': confidence,
        'binName': binName,
      };

  factory PredictionScore.fromJson(Map<String, dynamic> json) => PredictionScore(
        classKey: json['classKey'] as String,
        displayName: json['displayName'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        binName: json['binName'] as String,
      );
}
