import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../classifier/models/classification_result.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final ValueNotifier<List<ClassificationResult>> historyNotifier =
      ValueNotifier<List<ClassificationResult>>([]);

  bool _isLoaded = false;

  Future<void> initialize() async {
    if (_isLoaded) return;
    await loadHistory();
    _isLoaded = true;
  }

  Future<List<ClassificationResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(AppConstants.historyStorageKey) ?? [];

    final list = <ClassificationResult>[];
    for (final item in jsonList) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        list.add(ClassificationResult.fromJson(map));
      } catch (e) {
        debugPrint('Error decodificando item de historial: $e');
      }
    }

    // Sort newest first
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    historyNotifier.value = list;
    return list;
  }

  /// Saves a classification result, persisting the image to local app storage.
  Future<void> saveClassification(ClassificationResult result) async {
    String persistentPath = result.imagePath;

    try {
      final originalFile = File(result.imagePath);
      if (await originalFile.exists()) {
        final docsDir = await getApplicationDocumentsDirectory();
        final fileName = 'waste_${result.id}.jpg';
        final targetPath = '${docsDir.path}/$fileName';
        final savedFile = await originalFile.copy(targetPath);
        persistentPath = savedFile.path;
      }
    } catch (e) {
      debugPrint('No se pudo duplicar imagen persistente: $e');
    }

    final updatedResult = ClassificationResult(
      id: result.id,
      classKey: result.classKey,
      displayName: result.displayName,
      confidence: result.confidence,
      recommendedBin: result.recommendedBin,
      disposalAdvice: result.disposalAdvice,
      imagePath: persistentPath,
      timestamp: result.timestamp,
      topPredictions: result.topPredictions,
      isLowConfidence: result.isLowConfidence,
      modelName: result.modelName,
    );

    final current = List<ClassificationResult>.from(historyNotifier.value);
    // Remove duplicate if exists
    current.removeWhere((item) => item.id == updatedResult.id);
    current.insert(0, updatedResult);

    await _persistList(current);
    historyNotifier.value = current;
  }

  Future<void> deleteClassification(String id) async {
    final current = List<ClassificationResult>.from(historyNotifier.value);
    final index = current.indexWhere((item) => item.id == id);
    if (index != -1) {
      final removed = current.removeAt(index);
      try {
        final file = File(removed.imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      await _persistList(current);
      historyNotifier.value = current;
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.historyStorageKey);
    historyNotifier.value = [];
  }

  Future<void> _persistList(List<ClassificationResult> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(AppConstants.historyStorageKey, jsonList);
  }
}
