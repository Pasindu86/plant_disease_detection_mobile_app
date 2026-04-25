import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Result of a single classification prediction.
class ClassificationResult {
  final String label;
  final double confidence;

  /// Which model produced this result.
  /// 'Ensemble' when scores are fused from both models.
  final String modelSource;

  ClassificationResult({
    required this.label,
    required this.confidence,
    this.modelSource = '',
  });

  bool get isHealthy => label.toLowerCase().contains('healthy');
}

/// Holds the full ranked list from a single model plus metadata.
class ModelPrediction {
  final String modelName;
  final List<ClassificationResult> results;

  const ModelPrediction({required this.modelName, required this.results});

  ClassificationResult? get top => results.isNotEmpty ? results[0] : null;
}

/// Combined result: smart fusion + per-model breakdowns.
class DualModelResult {
  /// The final prediction after smart fusion logic.
  final ModelPrediction ensemble;

  /// Raw predictions from Model 1 alone.
  final ModelPrediction model1;

  /// Raw predictions from Model 2 alone (null if train.tflite failed to load).
  final ModelPrediction? model2;

  /// True when both models agree on the top disease label.
  final bool modelsAgree;

  const DualModelResult({
    required this.ensemble,
    required this.model1,
    this.model2,
    this.modelsAgree = true,
  });

  /// Whether both models contributed to the result.
  bool get isDualModel => model2 != null;

  ModelPrediction get winner => ensemble;
  ClassificationResult? get topResult => ensemble.top;
}

/// Service that runs TWO TFLite models on the same image and fuses their
/// per-class confidence scores (weighted average ensemble) to produce a
/// single, more accurate final prediction.
class PlantClassifierService {
  // ── Model 1 (original) ──────────────────────────────────────────────────
  static const String _model1Path  = 'assets/ml/model.tflite';
  static const String _labels1Path = 'assets/ml/labels.txt';

  // Model 2 (train) usually trained via TensorFlow Keras flow_from_directory
  // uses alphabetical sorting for its class indices, which differs from labels.txt.
  static const List<String> _model2LabelsList = [
    "Bacterial Spot",
    "Cercospora Leaf Spot",
    "Curl Virus",
    "Healthy Leaves",
    "Nutrition Deficiency",
    "White Spot",
  ];

  static const String _model2Path  = 'assets/ml/train.tflite';
  // We no longer read labels for Model 2 from labels.txt to avoid the alphabetical mismatch.

  // ── Input size for models ────────────────────────────────────────────────
  static const int _inputSize = 224;

  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  List<String> _labels1 = [];
  List<String> _labels2 = [];
  bool _isLoaded = false;
  bool _model2Available = false;

  bool get isLoaded => _isLoaded;

  // ── Loading ──────────────────────────────────────────────────────────────

  Future<void> loadModel() async {
    if (_isLoaded) return;

    // Model 1 is required
    try {
      _interpreter1 = await Interpreter.fromAsset(_model1Path);
      _labels1 = await _loadLabels(_labels1Path);
    } catch (e) {
      throw Exception('Failed to load model.tflite: $e');
    }

    // Model 2 is optional – graceful fallback if missing
    try {
      _interpreter2 = await Interpreter.fromAsset(_model2Path);
      _labels2 = _model2LabelsList;
      _model2Available = true;
    } catch (_) {
      _model2Available = false;
    }

    _isLoaded = true;
  }

  static Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) {
          final parts = l.split(' ');
          if (parts.length > 1 && int.tryParse(parts[0]) != null) {
            return parts.sublist(1).join(' ');
          }
          return l;
        })
        .toList();
  }

  // ── Inference ────────────────────────────────────────────────────────────

  /// Smart dual-model fusion:
  ///
  /// • If both models agree on the top label → average their scores (boosts
  ///   confidence when both are correct).
  /// • If they disagree → trust the model whose top score is higher
  ///   (a model that is 100% sure beats one that is 96% sure on a different
  ///   label, so we pick the more confident one as the winner).
  ///
  /// Falls back to Model 1 only if Model 2 is unavailable.
  Future<DualModelResult> classifyImage(File imageFile) async {
    if (!_isLoaded) await loadModel();

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);
    final inputTensor = _buildInputTensor(resized);

    // ── Run Model 1 ─────────────────────────────────────────────────────
    final raw1 = _runRaw(
      interpreter: _interpreter1!,
      numLabels: _labels1.length,
      inputTensor: inputTensor,
    );
    final pred1 = _buildPrediction(
      raw: raw1,
      labels: _labels1,
      modelName: 'Model 1 (model.tflite)',
    );

    // ── Model 2 unavailable → use Model 1 only ──────────────────────────
    if (!_model2Available || _interpreter2 == null) {
      return DualModelResult(
        ensemble: pred1,
        model1: pred1,
        model2: null,
        modelsAgree: true,
      );
    }

    // ── Run Model 2 ─────────────────────────────────────────────────────
    final raw2 = _runRaw(
      interpreter: _interpreter2!,
      numLabels: _labels2.length,
      inputTensor: inputTensor,
    );
    final pred2 = _buildPrediction(
      raw: raw2,
      labels: _labels2,
      modelName: 'Model 2 (train.tflite)',
    );

    final top1Label = pred1.top?.label ?? '';
    final top2Label = pred2.top?.label ?? '';
    final agree = top1Label == top2Label && top1Label.isNotEmpty;

    // Define weights for the models (Model 2 is more heavily weighted)
    const double w1 = 0.4;
    const double w2 = 0.6;

    // Merge by taking a weighted average of the confidence scores from both models
    final Map<String, double> weightedConfidences = {};
    for (var result in pred1.results) {
      weightedConfidences[result.label] = (weightedConfidences[result.label] ?? 0.0) + (result.confidence * w1);
    }
    for (var result in pred2.results) {
      weightedConfidences[result.label] = (weightedConfidences[result.label] ?? 0.0) + (result.confidence * w2);
    }

    // Create merged results and sort by highest total score
    final List<ClassificationResult> mergedResults = weightedConfidences.entries.map((e) {
      return ClassificationResult(
        label: e.key,
        confidence: e.value,
        modelSource: 'Merged Models',
      );
    }).toList();

    mergedResults.sort((a, b) => b.confidence.compareTo(a.confidence));

    ModelPrediction ensemblePred = ModelPrediction(
      modelName: 'Merged Models',
      results: mergedResults,
    );

    return DualModelResult(
      ensemble: ensemblePred,
      model1: pred1,
      model2: pred2,
      modelsAgree: agree,
    );
  }

  /// Returns the ensemble-fused results list directly.
  Future<List<ClassificationResult>> classifyImageSimple(File imageFile) async {
    final dual = await classifyImage(imageFile);
    return dual.ensemble.results;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static List<dynamic> _buildInputTensor(img.Image resized) {
    final input = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        // The ML model was trained with rescale=1.0/255.0 so we strictly divide by 255.0
        // (Do NOT use / 127.5 - 1.0)
        input[idx++] = pixel.r / 255.0;
        input[idx++] = pixel.g / 255.0;
        input[idx++] = pixel.b / 255.0;
      }
    }
    return input.reshape([1, _inputSize, _inputSize, 3]);
  }

  /// Run inference and return the raw float output list (length = numLabels).
  static List<double> _runRaw({
    required Interpreter interpreter,
    required int numLabels,
    required List<dynamic> inputTensor,
  }) {
    final outputTensor =
        List.filled(numLabels, 0.0).reshape([1, numLabels]);
    interpreter.run(inputTensor, outputTensor);
    return (outputTensor[0] as List<double>);
  }

  static ModelPrediction _buildPrediction({
    required List<double> raw,
    required List<String> labels,
    required String modelName,
  }) {
    final results = <ClassificationResult>[
      for (int i = 0; i < labels.length; i++)
        ClassificationResult(
          label: labels[i],
          confidence: raw[i],
          modelSource: modelName,
        ),
    ]..sort((a, b) => b.confidence.compareTo(a.confidence));

    return ModelPrediction(modelName: modelName, results: results);
  }

  // ── Dispose ──────────────────────────────────────────────────────────────

  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _interpreter1 = null;
    _interpreter2 = null;
    _isLoaded = false;
  }
}
