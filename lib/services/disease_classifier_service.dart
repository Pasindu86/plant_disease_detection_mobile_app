import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/disease_model.dart';

/// Service for classifying chili leaf diseases using a TFLite model.
///
/// Uses MobileNetV2-based model trained on 6 classes:

class DiseaseClassifierService {
  static const List<String> _modelPaths = [
    'assets/ml/chili_disease_model.tflite',
    'assets/ml/train.tflite',
    'assets/ml/model.tflite',
  ];
  static const String _labelsPath = 'assets/ml/labels.txt';
  static const int _inputSize = 224;

  List<Interpreter> _interpreters = [];
  List<String> _labels = [];
  bool _isInitialized = false;

  /// Singleton instance.
  static final DiseaseClassifierService _instance =
      DiseaseClassifierService._internal();

  factory DiseaseClassifierService() => _instance;

  DiseaseClassifierService._internal();

  /// Whether the model is loaded and ready.
  bool get isReady => _isInitialized;

  /// Initialize the TFLite interpreters and load labels.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load all 3 TFLite models from Flutter assets for ensemble prediction
      _interpreters.clear();
      for (String path in _modelPaths) {
        final modelData = await rootBundle.load(path);
        final buffer = modelData.buffer.asUint8List();
        _interpreters.add(Interpreter.fromBuffer(buffer));
      }

      // Load labels and clean them up
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData
          .split('\n')
          .map((l) {
            String text = l.trim();
            // Remove leading numbers and spaces (e.g., "0 Curl Virus" -> "Curl Virus")
            text = text.replaceFirst(RegExp(r'^\d+\s*'), '');
            // Fix mismatches between labels.txt and DiseaseInfo database
            if (text == 'Healthy Leaves') text = 'Healthy Leaf';
            return text;
          })
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

    if (_interpreters.isEmpty) {
      throw Exception('Models not loaded. Call initialize() first.');
    }

    // Read image bytes
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    // image processing in a background isolate
    final input = await compute(_preprocessImage, imageBytes);

    // Initialize  sum of probabilities from all models
    List<double> ensembleProbabilities = List.filled(_labels.length, 0.0);

    for (var interpreter in _interpreters) {
      // Prepare output tensor [1, numClasses]
      final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      // Run inference (must be on main isolate as interpreter is not transferable)
      interpreter.run(input, output);

      // Get probabilities and check if softmax is needed (often required if logits output)
      final rawOutput = (output[0] as List<double>);
      double sum = rawOutput.fold(0.0, (a, b) => a + b);
      
      List<double> probabilities;
      if ((sum - 1.0).abs() > 0.1) {
        // Model outputted logits, apply softmax
        double maxLogit = rawOutput.reduce((a, b) => a > b ? a : b);
        double expSum = 0.0;
        for (double val in rawOutput) {
          expSum += math.exp(val - maxLogit);
        }
        probabilities = rawOutput.map((e) => math.exp(e - maxLogit) / expSum).toList();
      } else {
        // Model already has softmax probability values
        probabilities = rawOutput;
      }

      // Add to ensemble probabilities
      for (int i = 0; i < probabilities.length; i++) {
        ensembleProbabilities[i] += probabilities[i];
      }
    }

    // Average the probabilities across all interpreters
    for (int i = 0; i < ensembleProbabilities.length; i++) {
      ensembleProbabilities[i] /= _interpreters.length;
    }

    // Find the class with highest average probability
    double maxProb = 0.0;
    int maxIndex = 0;
    for (int i = 0; i < ensembleProbabilities.length; i++) {
      if (ensembleProbabilities[i] > maxProb) {
        maxProb = ensembleProbabilities[i];
        maxIndex = i;
      }
    }

    return DiseaseResult(
      name: _labels[maxIndex],
      confidence: maxProb * 100.0,
      classIndex: maxIndex,
      probabilities: ensembleProbabilities,
    );
  }

  /// Preprocess image in a background isolate.
   static List<List<List<List<double>>>> _preprocessImage(Uint8List imageBytes) {
    var image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Could not decode image');
    }

    // Crucial: Fix image orientation based on EXIF rotation before feeding to model
    image = img.bakeOrientation(image);

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
  /// Returns values in [0, 1] range as the model expects normalized floats.
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
              pixel.r.toDouble() / 255.0, // Red (0-1)
              pixel.g.toDouble() / 255.0, // Green (0-1)
              pixel.b.toDouble() / 255.0, // Blue (0-1)
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

  /// Dispose the interpreters and free resources.
  void dispose() {
    for (var interpreter in _interpreters) {
      interpreter.close();
    }
    _interpreters.clear();
    _isInitialized = false;
  }
}
