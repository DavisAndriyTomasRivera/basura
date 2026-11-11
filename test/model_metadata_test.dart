import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Validate metadata.json format and consistency', () {
    final file = File('assets/model/metadata.json');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();
    final json = jsonDecode(content) as Map<String, dynamic>;

    expect(json['version'], '2.0');
    expect(json['modelo'], contains('MobileNetV2'));

    final classes = List<String>.from(json['clases'] as List);
    expect(classes.length, 7);
    expect(classes, [
      'metal',
      'organico',
      'otros',
      'papel_carton',
      'peligroso',
      'plastico',
      'vidrio',
    ]);

    final imgSize = List<int>.from(json['img_size'] as List);
    expect(imgSize, [224, 224]);

    final binMap = Map<String, dynamic>.from(json['bin_map'] as Map);
    for (final cls in classes) {
      expect(binMap.containsKey(cls), isTrue, reason: 'bin_map must contain $cls');
    }
  });
}
