import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/services/plant_classifier_service.dart';
import 'result_page.dart';

<<<<<<< HEAD
=======
import '../../models/disease_model.dart';
import '../../services/disease_classifier_service.dart';
import 'disease_result_page.dart';

>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
class ImagePreviewPage extends StatefulWidget {
  final String imagePath;

  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
<<<<<<< HEAD
  final PlantClassifierService _classifier = PlantClassifierService();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    setState(() => _isAnalyzing = true);

    try {
      await _classifier.loadModel();
      // Run both models and get the dual result
      final dualResult = await _classifier.classifyImage(File(widget.imagePath));

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultPage(
            imagePath: widget.imagePath,
            results: dualResult.winner.results,
            dualResult: dualResult,
=======
  final DiseaseClassifierService _classifier = DiseaseClassifierService();
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _classifier.classifyImage(widget.imagePath);
      final topPredictions = _classifier.getTopPredictions(result);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DiseaseResultPage(
            imagePath: widget.imagePath,
            result: result,
            topPredictions: topPredictions,
            diseaseInfo: DiseaseInfo.getInfo(result.name),
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
<<<<<<< HEAD
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
=======
      setState(() {
        _isAnalyzing = false;
        _errorMessage = 'Failed to analyze image: $e';
      });
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Preview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Container(
<<<<<<< HEAD
=======
              width: double.infinity,
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: widget.imagePath.isNotEmpty
                    ? Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.cover,
<<<<<<< HEAD
                        width: double.infinity,
                      )
                    : const Center(child: Text('No image to display')),
=======
                      )
                    : const Center(
                        child: Text('No image to display'),
                      ),
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
              ),
            ),
          ),

<<<<<<< HEAD
          // Info text
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Make sure the leaf is clearly visible in the image for accurate detection.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
=======
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Analyze button
          Padding(
            padding: const EdgeInsets.all(24),
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
<<<<<<< HEAD
                            width: 22,
                            height: 22,
=======
                            width: 24,
                            height: 24,
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
<<<<<<< HEAD
                              fontSize: 17,
=======
                              fontSize: 18,
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
<<<<<<< HEAD
                          Icon(Icons.search_rounded, size: 24),
=======
                          Icon(Icons.biotech_rounded, size: 24),
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
                          SizedBox(width: 8),
                          Text(
                            'Analyze Leaf',
                            style: TextStyle(
<<<<<<< HEAD
                              fontSize: 17,
=======
                              fontSize: 18,
>>>>>>> 3217e9a4ccd8a5f69a05c9a216c3f92f02f1edc4
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
