/// Application-wide constants for Basura App
class AppConstants {
  AppConstants._();

  static const String appName = 'Basura';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Smart Waste Classification';

  // Model Asset Paths (prioritizing FP16 for mobile performance)
  static const String modelFp16Asset = 'assets/model/model_v1_fp16.tflite';
  static const String modelV1Asset = 'assets/model/model_v1.tflite';
  static const String metadataAsset = 'assets/model/metadata.json';

  // Alternative paths (root assets)
  static const String modelFp16AssetAlt = 'assets/model_v1_fp16.tflite';
  static const String modelV1AssetAlt = 'assets/model_v1.tflite';
  static const String metadataAssetAlt = 'assets/metadata.json';

  // Lottie Animation Paths
  static const String phoenixAnimation = 'assets/animations/Phoenix.json';
  static const String analysisAnimation =
      'assets/animations/Data Analysis.json';
  static const String successAnimation =
      'assets/animations/payment Successfully in green colore.json';
  static const String uncpLogo = 'assets/logos/Vectorizada.svg';

  // Onboarding Storage Key
  static const String onboardingCompletedStorageKey =
      'basura_onboarding_completed';

  // Model specifications according to metadata.json
  static const int inputWidth = 224;
  static const int inputHeight = 224;
  static const int inputChannels = 3;

  // Confidence Threshold for Low Confidence Warnings
  static const double lowConfidenceThreshold = 0.60;

  // History Storage Key
  static const String historyStorageKey = 'basura_classification_history_v2';
}
