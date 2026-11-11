import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Preprocessing pipeline for TensorFlow Lite MobileNetV2 Fine-Tuning.
/// Adheres strictly to metadata.json:
/// - Centered square crop
/// - Resize to 224x224 RGB
/// - Raw pixel values 0.0 - 255.0 (model handles normalization internally)
class ImagePreprocessor {
  ImagePreprocessor._();

  /// Preprocesses raw image bytes into a 4D Float32 tensor input [1, 224, 224, 3].
  static List<List<List<List<double>>>> preprocessImage(
    Uint8List imageBytes, {
    int targetWidth = 224,
    int targetHeight = 224,
  }) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('No se pudo decodificar la imagen proporcionada.');
    }

    // 1. Convert to RGB / Bake orientation if EXIF metadata exists
    final oriented = img.bakeOrientation(decoded);

    // 2. Centered square crop
    final minDim = min(oriented.width, oriented.height);
    final cropX = (oriented.width - minDim) ~/ 2;
    final cropY = (oriented.height - minDim) ~/ 2;
    final cropped = img.copyCrop(
      oriented,
      x: cropX,
      y: cropY,
      width: minDim,
      height: minDim,
    );

    // 3. Resize to 224x224
    final resized = img.copyResize(
      cropped,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    // 4. Construct 4D input [1, 224, 224, 3] with values in 0.0 - 255.0
    // Note: Do NOT normalize by 255.0 because the model normalizes internally.
    final input = List.generate(
      1,
      (_) => List.generate(
        targetHeight,
        (y) => List.generate(
          targetWidth,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    return input;
  }
}
