import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
void main() {
  final interpreter = Interpreter.fromFile(File('assets/ml/chili_disease_model.tflite'));
  final input = List.generate(1, (_) => List.generate(224, (_) => List.generate(224, (_) => [0.0, 0.0, 0.0])));
  final output = List.filled(6, 0.0).reshape([1, 6]);
  interpreter.run(input, output);
  print(output);
}
