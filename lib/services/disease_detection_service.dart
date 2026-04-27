import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

/// Service to save and retrieve disease detection records from local cache.
class DiseaseDetectionService {
  static const String _cacheKey = 'scan_history_cache';

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      return v == 'true' || v == '1' || v == 'yes';
    }
    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  static List<Map<String, dynamic>> _decodeHistory(String cachedData) {
    final decoded = json.decode(cachedData);

    // Older app versions may have stored a single map instead of a list.
    final List<dynamic> list = decoded is List
        ? decoded
        : (decoded is Map ? [decoded] : <dynamic>[]);

    final records = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is Map) {
        records.add(Map<String, dynamic>.from(item));
      }
    }
    return records;
  }

  static Map<String, dynamic> _sanitizeRecord(Map<String, dynamic> record) {
    final detectedAtStr = record['detectedAt']?.toString();
    final detectedAt = detectedAtStr != null ? DateTime.tryParse(detectedAtStr) : null;
    final timestamp = record['timestamp'];
    final ts = timestamp is num
        ? timestamp.toInt()
        : (detectedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);

    return {
      'id': (record['id']?.toString().isNotEmpty ?? false)
          ? record['id'].toString()
          : ts.toString(),
      'diseaseName': (record['diseaseName'] ?? record['label'] ?? 'Unknown').toString(),
      'confidence': _parseDouble(record['confidence']),
      'isHealthy': _parseBool(record['isHealthy']),
      'imagePath': record['imagePath']?.toString(),
      'detectedAt': detectedAt?.toIso8601String() ?? DateTime.fromMillisecondsSinceEpoch(ts).toIso8601String(),
      'timestamp': ts,
    };
  }

  /// Save a disease detection result to local cache
  Future<void> saveDetection({
    required String diseaseName,
    required double confidence,
    required bool isHealthy,
    String? imagePath,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String? savedImagePath = imagePath;

      final now = DateTime.now();

      // Move the image from temporary cache to permanent app directory
      if (imagePath != null && imagePath.isNotEmpty) {
        final File originalFile = File(imagePath);
        if (await originalFile.exists()) {
          final directory = await getApplicationDocumentsDirectory();
          final String fileExtension = p.extension(imagePath);
          final String newFileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
          final String newPath = p.join(directory.path, 'scans', newFileName);
          
          // Ensure folder exists
          final savedDir = Directory(p.join(directory.path, 'scans'));
          if (!(await savedDir.exists())) {
            await savedDir.create(recursive: true);
          }

          final File savedFile = await originalFile.copy(newPath);
          savedImagePath = savedFile.path;
        }
      }

      // Create new record
      final newRecord = {
        'id': now.millisecondsSinceEpoch.toString(),
        'diseaseName': diseaseName,
        'confidence': confidence,
        'isHealthy': isHealthy,
        'imagePath': savedImagePath, // Save the permanent local file path
        'detectedAt': now.toIso8601String(),
        'timestamp': now.millisecondsSinceEpoch,
      };

      // Get existing history
      final String? cachedData = prefs.getString(_cacheKey);

      // Decode + migrate old formats (Map vs List) + drop invalid items.
      List<Map<String, dynamic>> history = [];
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          history = _decodeHistory(cachedData);
        } catch (_) {
          history = [];
        }
      }

      // Sanitize existing items to ensure consistent types.
      final sanitized = history.map(_sanitizeRecord).toList();

      // Add new record to the top.
      sanitized.insert(0, _sanitizeRecord(Map<String, dynamic>.from(newRecord)));

      // Save back to cache.
      await prefs.setString(_cacheKey, json.encode(sanitized));
      print('✅ Detection cached successfully locally: $diseaseName ($confidence)');
    } catch (e) {
      print('❌ Error saving detection locally: $e');
      rethrow;
    }
  }

  /// Get all detections from local cache
  Future<List<Map<String, dynamic>>> getUserDetections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);
      
      if (cachedData == null) return [];

      final history = _decodeHistory(cachedData);
      final sanitized = history.map(_sanitizeRecord).toList();
      sanitized.sort((a, b) {
        final at = (a['timestamp'] as num?)?.toInt() ?? 0;
        final bt = (b['timestamp'] as num?)?.toInt() ?? 0;
        return bt.compareTo(at);
      });

      // If we had to sanitize (or fix ordering), persist the cleaned data.
      await prefs.setString(_cacheKey, json.encode(sanitized));

      return sanitized;
    } catch (e) {
      print('❌ Error getting local detections: $e');
      return [];
    }
  }

  /// Get detection count from local cache
  Future<int> getDetectionCount() async {
    final detections = await getUserDetections();
    return detections.length;
  }

  /// Delete a specific detection from local cache
  Future<void> deleteDetection(String detectionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);
      
      if (cachedData == null) return;

      List<dynamic> history = json.decode(cachedData);
      
      // Find the item to delete its image file too
      final itemToDelete = history.firstWhere(
        (item) => item['id'] == detectionId, 
        orElse: () => null
      );
      
      if (itemToDelete != null && itemToDelete['imagePath'] != null) {
        final file = File(itemToDelete['imagePath']);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove the item with matching id
      history.removeWhere((item) => item['id'] == detectionId);

      // Save updated list back to cache
      await prefs.setString(_cacheKey, json.encode(history));
      print('✅ Detection deleted locally successfully');
    } catch (e) {
      print('❌ Error deleting local detection: $e');
      rethrow;
    }
  }

  /// Get recent detections (limited to n) from local cache
  Future<List<Map<String, dynamic>>> getRecentDetections({int limit = 10}) async {
    final detections = await getUserDetections();
    if (detections.length <= limit) return detections;
    return detections.take(limit).toList();
  }
}
