import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
void main() async {
  final interpreter = Interpreter.fromFile(File('assets/ml/chili_disease_model.tflite'));
  print(interpreter.getInputTensors());
  print(interpreter.getOutputTensors());
}
