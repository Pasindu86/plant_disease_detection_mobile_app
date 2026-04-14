import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/disease_model.dart';

/// Service for classifying chili leaf diseases using a TFLite model.
///
/// Uses MobileNetV2-based model trained on 6 classes:
/// - Bacterial Spot
/// - Cercospora Leaf Spot
/// - Curl Virus
/// - Healthy Leaf
/// - Nutrition Deficiency
/// - White spot
class DiseaseClassifierService {
  static const String _modelPath = 'assets/ml/chili_disease_model.tflite';
  static const String _labelsPath = 'assets/ml/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  /// Singleton instance.
  static final DiseaseClassifierService _instance =
      DiseaseClassifierService._internal();

  factory DiseaseClassifierService() => _instance;

  DiseaseClassifierService._internal();

  /// Whether the model is loaded and ready.
  bool get isReady => _isInitialized;

  /// Initialize the TFLite interpreter and load labels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load the TFLite model bytes from Flutter assets
      final modelData = await rootBundle.load(_modelPath);
      final buffer = modelData.buffer.asUint8List();

      // Create interpreter from buffer
      _interpreter = Interpreter.fromBuffer(buffer);

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  /// Classify a leaf image from the given file path.
  ///
  /// Returns a [DiseaseResult] with the predicted disease name and confidence.
  Future<DiseaseResult> classifyImage(String imagePath) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null) {
      throw Exception('Model not loaded. Call initialize() first.');
    }

    // Read image bytes
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    // Do heavy image processing in a background isolate
    final input = await compute(_preprocessImage, imageBytes);

    // Prepare output tensor [1, numClasses]
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    // Run inference (must be on main isolate as interpreter is not transferable)
    _interpreter!.run(input, output);

    // Get probabilities
    final probabilities = (output[0] as List<double>);

    // Find the class with highest probability
    double maxProb = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    return DiseaseResult(
      name: _labels[maxIndex],
      confidence: maxProb * 100.0,
      classIndex: maxIndex,
      probabilities: probabilities,
    );
  }

  /// Preprocess image in a background isolate.
  /// Decodes, resizes, and normalizes image to [1, 224, 224, 3].
  static List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }

    final resizedImage = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    return _imageToInput(resizedImage);
  }

  /// Convert an image to the model's expected input format.
  ///
  /// Returns values in [0, 255] range as the model was trained with raw pixel values.
  static List<List<List<List<double>>>> _imageToInput(img.Image image) {
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r.toDouble(), // Red (0-255)
              pixel.g.toDouble(), // Green (0-255)
              pixel.b.toDouble(), // Blue (0-255)
            ];
          },
        ),
      ),
    );
    return input;
  }

  /// Get all predictions sorted by confidence (highest first).
  List<DiseaseResult> getTopPredictions(DiseaseResult result, {int topK = 3}) {
    final indexed = result.probabilities.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(topK).map((entry) {
      return DiseaseResult(
        name: _labels[entry.key],
        confidence: entry.value * 100.0,
        classIndex: entry.key,
        probabilities: result.probabilities,
      );
    }).toList();
  }

  /// Dispose the interpreter and free resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}
