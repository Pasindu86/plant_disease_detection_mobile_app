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
  static const String _model1Path  = 'lib/models/model.tflite';
  static const String _labels1Path = 'lib/models/labels.txt';

  // ── Model 2 (train) ─────────────────────────────────────────────────────
  static const String _model2Path  = 'lib/models/train.tflite';
  static const String _labels2Path = 'lib/models/labels.txt';

  // ── Ensemble weights (must sum to 1.0) ──────────────────────────────────
  // Model 2 (train.tflite) is larger (9.5 MB vs 2.1 MB) so we give it
  // slightly more weight as it likely trained longer / on more data.
  static const double _w1 = 0.4; // weight for model.tflite
  static const double _w2 = 0.6; // weight for train.tflite

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
      _labels2 = await _loadLabels(_labels2Path);
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
    final agree = top1Label == top2Label;

    ModelPrediction ensemblePred;

    if (agree) {
      // ── Both agree → average scores per class for a stronger result ──
      final numClasses = _labels1.length;
      final fusedRaw = List<double>.generate(numClasses, (i) {
        return raw1[i] * _w1 + raw2[i] * _w2;
      });
      final total = fusedRaw.fold(0.0, (s, v) => s + v);
      final normFused = total > 0
          ? fusedRaw.map((v) => v / total).toList()
          : fusedRaw;

      ensemblePred = _buildPrediction(
        raw: normFused,
        labels: _labels1,
        modelName: 'Ensemble (agreed)',
      );
    } else {
      // ── Disagree → trust the more confident model ────────────────────
      final conf1 = pred1.top?.confidence ?? 0.0;
      final conf2 = pred2.top?.confidence ?? 0.0;
      ensemblePred = conf1 >= conf2 ? pred1 : pred2;
    }

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
        input[idx++] = pixel.r / 127.5 - 1.0;
        input[idx++] = pixel.g / 127.5 - 1.0;
        input[idx++] = pixel.b / 127.5 - 1.0;
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
