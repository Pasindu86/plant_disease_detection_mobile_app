import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Result of a single classification prediction.
class ClassificationResult {
  final String label;
  final double confidence;

  ClassificationResult({required this.label, required this.confidence});

  bool get isHealthy => label.toLowerCase().contains('healthy');
}

/// Service that loads a TFLite model and classifies chili leaf images.
class PlantClassifierService {
  static const String _modelPath = 'lib/models/model_unquant.tflite';
  static const String _labelsPath = 'lib/models/labels.txt';
  static const int _inputSize = 224; // Standard MobileNet input size

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get labels => _labels;

  /// Load the TFLite model and labels from assets.
  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      // Load model
      _interpreter = await Interpreter.fromAsset(_modelPath);

      // Load labels
      final labelData = await rootBundle.loadString(_labelsPath);
      _labels = labelData
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) {
            // Remove the leading index number (e.g., "0 Bacterial Spot" → "Bacterial Spot")
            final parts = line.split(' ');
            if (parts.length > 1 && int.tryParse(parts[0]) != null) {
              return parts.sublist(1).join(' ');
            }
            return line;
          })
          .toList();

      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load model: $e');
    }
  }

  /// Classify an image file and return sorted results.
  Future<List<ClassificationResult>> classifyImage(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      await loadModel();
    }

    // Read and preprocess the image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Resize to model input size
    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    // Create input tensor – normalized float32 [1, 224, 224, 3]
    final input = Float32List(_inputSize * _inputSize * 3);
    int pixelIndex = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }

    // Reshape to [1, 224, 224, 3]
    final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

    // Prepare output tensor [1, numLabels]
    final outputTensor = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

    // Run inference
    _interpreter!.run(inputTensor, outputTensor);

    // Parse output
    final output = (outputTensor[0] as List<double>);

    // Build results
    final results = <ClassificationResult>[];
    for (int i = 0; i < _labels.length; i++) {
      results.add(ClassificationResult(
        label: _labels[i],
        confidence: output[i],
      ));
    }

    // Sort by confidence descending
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    return results;
  }

  /// Dispose the interpreter to free resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
