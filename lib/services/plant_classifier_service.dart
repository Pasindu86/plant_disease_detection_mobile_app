import 'dart:io';
import 'dart:math' as math;
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
  static const String _model1Path = 'assets/ml/model.tflite';
  static const String _labels1Path = 'assets/ml/labels.txt';

  // ── Model 3 (chili disease model) ───────────────────────────────────────
  static const String _model3Path = 'assets/ml/chili_disease_model.tflite';
  static const String _labels3Path = 'assets/ml/labels.txt';

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

  static const String _model2Path = 'assets/ml/train.tflite';
  // We no longer read labels for Model 2 from labels.txt to avoid the alphabetical mismatch.

  // ── Input size for models ────────────────────────────────────────────────
  static const int _inputSize = 224;

  Interpreter? _interpreter1;
  Interpreter? _interpreter2;
  Interpreter? _interpreter3;
  List<String> _labels1 = [];
  List<String> _labels2 = [];
  List<String> _labels3 = [];
  bool _isLoaded = false;
  bool _model2Available = false;
  bool _model3Available = false;

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

    // Model 3 is optional – graceful fallback if missing
    try {
      _interpreter3 = await Interpreter.fromAsset(_model3Path);
      _labels3 = await _loadLabels(_labels3Path);
      _model3Available = true;
    } catch (_) {
      _model3Available = false;
    }

    _isLoaded = true;
  }

  static Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).map((
      l,
    ) {
      final parts = l.split(' ');
      if (parts.length > 1 && int.tryParse(parts[0]) != null) {
        return parts.sublist(1).join(' ');
      }
      return l;
    }).toList();
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

    // Camera images often have EXIF rotation; fix orientation before resizing.
    final oriented = img.bakeOrientation(image);

    final resized = img.copyResize(
      oriented,
      width: _inputSize,
      height: _inputSize,
    );
    final inputTensor = _buildInputTensor(resized);

    // ── Run Model 1 ─────────────────────────────────────────────────────
    final raw1 = _runRaw(
      interpreter: _interpreter1!,
      numLabels: _labels1.length,
      inputTensor: inputTensor,
    );
    final probs1 = _toProbabilities(raw1);
    final pred1 = _buildPrediction(
      raw: probs1,
      labels: _labels1,
      modelName: 'Model 1 (model.tflite)',
    );

    ModelPrediction? pred2;
    if (_model2Available && _interpreter2 != null) {
      final raw2 = _runRaw(
        interpreter: _interpreter2!,
        numLabels: _labels2.length,
        inputTensor: inputTensor,
      );
      final probs2 = _toProbabilities(raw2);
      pred2 = _buildPrediction(
        raw: probs2,
        labels: _labels2,
        modelName: 'Model 2 (train.tflite)',
      );
    }

    ModelPrediction? pred3;
    if (_model3Available && _interpreter3 != null) {
      final raw3 = _runRaw(
        interpreter: _interpreter3!,
        numLabels: _labels3.length,
        inputTensor: inputTensor,
      );
      final probs3 = _toProbabilities(raw3);
      pred3 = _buildPrediction(
        raw: probs3,
        labels: _labels3,
        modelName: 'Model 3 (chili_disease_model.tflite)',
      );
    }

    // ── Ensemble fusion ("most mark") ───────────────────────────────────
    // For each label, keep the MAX confidence across available models.
    // This ensures if any model is strongly confident about "White spot",
    // the final prediction reflects that.
    final Map<String, double> fused = {};

    void addToFused(ModelPrediction prediction) {
      for (final r in prediction.results) {
        final current = fused[r.label] ?? 0.0;
        if (r.confidence > current) fused[r.label] = r.confidence;
      }
    }

    addToFused(pred1);
    if (pred2 != null) addToFused(pred2);
    if (pred3 != null) addToFused(pred3);

    final mergedResults =
        fused.entries
            .map(
              (e) => ClassificationResult(
                label: e.key,
                confidence: e.value,
                modelSource: 'Ensemble (max)',
              ),
            )
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final ensemblePred = ModelPrediction(
      modelName: 'Ensemble (max)',
      results: mergedResults,
    );

    final top1Label = pred1.top?.label ?? '';
    final top2Label = pred2?.top?.label ?? '';
    final top3Label = pred3?.top?.label ?? '';

    final topLabels = <String>[
      top1Label,
      top2Label,
      top3Label,
    ].where((e) => e.isNotEmpty).toList();
    final agree =
        topLabels.isNotEmpty && topLabels.every((l) => l == topLabels.first);

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
    final outputTensor = List.filled(numLabels, 0.0).reshape([1, numLabels]);
    interpreter.run(inputTensor, outputTensor);
    return (outputTensor[0] as List<double>);
  }

  static ModelPrediction _buildPrediction({
    required List<double> raw,
    required List<String> labels,
    required String modelName,
  }) {
    final Map<String, double> byLabel = {};
    for (int i = 0; i < labels.length; i++) {
      final label = _canonicalizeLabel(labels[i]);
      final score = raw[i];
      final current = byLabel[label] ?? -double.infinity;
      if (score > current) byLabel[label] = score;
    }

    final results =
        byLabel.entries
            .map(
              (e) => ClassificationResult(
                label: e.key,
                confidence: e.value,
                modelSource: modelName,
              ),
            )
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return ModelPrediction(modelName: modelName, results: results);
  }

  static String _canonicalizeLabel(String label) {
    final trimmed = label.trim();
    final lower = trimmed.toLowerCase();

    switch (lower) {
      case 'healthy leaves':
      case 'healthy leaf':
        return 'Healthy Leaf';
      case 'white spot':
        // Keep consistent with the disease info DB naming.
        return 'White spot';
      case 'bacterial spot':
        return 'Bacterial Spot';
      case 'cercospora leaf spot':
        return 'Cercospora Leaf Spot';
      case 'curl virus':
        return 'Curl Virus';
      case 'nutrition deficiency':
        return 'Nutrition Deficiency';
      default:
        return trimmed;
    }
  }

  static List<double> _toProbabilities(List<double> raw) {
    final sum = raw.fold<double>(0.0, (a, b) => a + b);

    // If this already looks like probabilities, keep as-is.
    if ((sum - 1.0).abs() <= 0.1 && raw.every((e) => e >= 0.0 && e <= 1.0)) {
      return raw;
    }

    // Otherwise, assume logits and apply softmax.
    final maxLogit = raw.reduce((a, b) => a > b ? a : b);
    double expSum = 0.0;
    final exps = List<double>.filled(raw.length, 0.0);
    for (int i = 0; i < raw.length; i++) {
      final v = (raw[i] - maxLogit);
      final ev = v.isFinite ? math.exp(v) : 0.0;
      exps[i] = ev;
      expSum += ev;
    }
    if (expSum == 0.0) {
      return List<double>.filled(raw.length, 0.0);
    }
    for (int i = 0; i < exps.length; i++) {
      exps[i] = exps[i] / expSum;
    }
    return exps;
  }

  // ── Dispose ──────────────────────────────────────────────────────────────

  void dispose() {
    _interpreter1?.close();
    _interpreter2?.close();
    _interpreter3?.close();
    _interpreter1 = null;
    _interpreter2 = null;
    _interpreter3 = null;
    _isLoaded = false;
  }
}
