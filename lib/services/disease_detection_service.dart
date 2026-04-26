import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

/// Service to save and retrieve disease detection records from local cache.
class DiseaseDetectionService {
  static const String _cacheKey = 'scan_history_cache';

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
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'diseaseName': diseaseName,
        'confidence': confidence,
        'isHealthy': isHealthy,
        'imagePath': savedImagePath, // Save the permanent local file path
        'detectedAt': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Get existing history
      final String? cachedData = prefs.getString(_cacheKey);
      List<dynamic> history = [];
      
      if (cachedData != null) {
        history = json.decode(cachedData);
      }

      // Add new record to the top
      history.insert(0, newRecord);

      // Save back to cache
      await prefs.setString(_cacheKey, json.encode(history));
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

      final List<dynamic> history = json.decode(cachedData);
      return history.map((e) => Map<String, dynamic>.from(e)).toList();
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
