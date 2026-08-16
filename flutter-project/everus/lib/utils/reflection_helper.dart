import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reflection_models.dart';
import '../data/reflection_mock_data.dart';

class ReflectionHelper {
  static const String _keyReflections = 'everus_saved_reflections';
  static const String _keyPatterns = 'everus_memory_patterns';

  /// Default pre-seeded reflections from mock repository
  static List<ReflectionItem> _getDefaultReflections() => ReflectionMockData.defaultReflections;

  /// Default memory patterns from mock repository
  static List<MemoryPattern> _getDefaultPatterns() => ReflectionMockData.defaultPatterns;

  /// Shared insights for the "Us" (Chúng mình) tab from mock repository
  static List<SharedRelationshipInsight> getSharedInsights() => ReflectionMockData.sharedInsights;

  /// Load all reflections
  static Future<List<ReflectionItem>> loadReflections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson = prefs.getString(_keyReflections);
      if (listJson != null && listJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(listJson);
        return decoded.map((e) => ReflectionItem.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading reflections: $e');
    }
    return _getDefaultReflections();
  }

  /// Save a new reflection
  static Future<void> saveReflection(ReflectionItem item) async {
    try {
      final currentList = await loadReflections();
      final updatedList = [item, ...currentList.where((e) => e.id != item.id)];
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(updatedList.map((e) => e.toMap()).toList());
      await prefs.setString(_keyReflections, encoded);
    } catch (e) {
      debugPrint('Error saving reflection: $e');
    }
  }

  /// Load memory patterns
  static Future<List<MemoryPattern>> loadPatterns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patternsJson = prefs.getString(_keyPatterns);
      if (patternsJson != null && patternsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(patternsJson);
        return decoded.map((e) => MemoryPattern.fromMap(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading patterns: $e');
    }
    return _getDefaultPatterns();
  }

  /// Update pattern confidence based on user feedback (Screen 4)
  static Future<void> adjustPatternConfidence(String patternId, double delta) async {
    try {
      final patterns = await loadPatterns();
      final updated = patterns.map((p) {
        if (p.id == patternId) {
          final newConf = (p.confidence + delta).clamp(0.1, 1.0);
          return MemoryPattern(
            id: p.id,
            trigger: p.trigger,
            description: p.description,
            confidence: newConf,
            count: delta > 0 ? p.count + 1 : p.count,
            lastObserved: DateTime.now(),
          );
        }
        return p;
      }).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _keyPatterns, json.encode(updated.map((e) => e.toMap()).toList()));
    } catch (e) {
      debugPrint('Error adjusting pattern confidence: $e');
    }
  }
}
