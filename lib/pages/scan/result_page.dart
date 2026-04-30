import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/services/plant_classifier_service.dart';
import 'package:plant_disease_detection_mobile_app/services/disease_detection_service.dart';
import 'result_treatment_section.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final List<ClassificationResult> results;
  final bool isHistory;

  /// Full dual-model result (optional – kept for backward compat).
  final DualModelResult? dualResult;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.results,
    this.dualResult,
    this.isHistory = false,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final DiseaseDetectionService _detectionService = DiseaseDetectionService();

  @override
  void initState() {
    super.initState();
    if (!widget.isHistory) {
      _saveDetectionLocally();
    }
  }

  Future<void> _saveDetectionLocally() async {
    if (widget.results.isEmpty) return;

    try {
      final topResult = widget.results[0];
      await _detectionService.saveDetection(
        diseaseName: topResult.label,
        confidence: topResult.confidence,
        isHealthy: topResult.isHealthy,
        imagePath: widget.imagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Detection saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Returns disease-specific information (description + care tips).
  static Map<String, String> _getDiseaseInfo(String label) {
    final map = {
      'Bacterial Spot': {
        'description':
            'Bacterial spot is caused by Xanthomonas bacteria. It creates small, dark, water-soaked lesions on leaves that may enlarge and turn brown.',
        'tips':
            '• Remove and destroy infected leaves\n• Avoid overhead watering\n• Apply copper-based bactericide\n• Rotate crops and avoid planting in the same soil\n• Ensure good air circulation around plants',
      },
      'Curl Virus': {
        'description':
            'Leaf curl virus (transmitted by whiteflies) causes upward curling, puckering, and yellowing of leaves, stunting plant growth and reducing yield.',
        'tips':
            '• Control whitefly populations with sticky traps or insecticides\n• Remove and destroy infected plants immediately\n• Use virus-resistant chili varieties\n• Apply neem oil as a preventive measure\n• Use reflective mulches to deter whiteflies',
      },
      'Cercospora Leaf Spot': {
        'description':
            'Cercospora leaf spot is a fungal disease that produces circular spots with gray or tan centers and dark brown margins on leaves.',
        'tips':
            '• Remove affected leaves to reduce spore spread\n• Apply fungicides (e.g., chlorothalonil or mancozeb)\n• Avoid wetting the foliage when watering\n• Maintain proper plant spacing for airflow\n• Rotate crops every season',
      },
      'Nutrition Deficiency': {
        'description':
            'Nutrient deficiencies cause yellowing, stunted growth, or discolored leaves depending on the specific nutrient lacking (nitrogen, potassium, magnesium, etc.).',
        'tips':
            '• Test soil pH and nutrient levels\n• Apply balanced NPK fertilizer\n• Add compost or organic matter to improve soil\n• Use foliar sprays for quick micronutrient uptake\n• Water consistently to help nutrient absorption',
      },
      'White Spot': {
        'description':
            'White spots on chili leaves can be caused by powdery mildew or other fungal pathogens, forming white powdery patches on the leaf surface.',
        'tips':
            '• Apply sulfur-based or potassium bicarbonate fungicides\n• Improve air circulation around plants\n• Avoid excessive nitrogen fertilization\n• Water at the base of plants, not on leaves\n• Remove heavily infected leaves',
      },
      'Healthy Leaves': {
        'description':
            'Your chili plant looks healthy! The leaves show no signs of disease, pests, or nutritional deficiencies.',
        'tips':
            '• Continue regular watering and fertilization\n• Monitor plants weekly for early signs of disease\n• Maintain good garden hygiene\n• Ensure adequate sunlight (6-8 hours daily)\n• Keep using organic mulch to retain moisture',
      },
    };

    return map[label] ??
        {
          'description':
              'No detailed information available for this condition.',
          'tips':
              '• Consult a local agricultural expert for specific guidance.',
        };
  }

  Widget _buildPredictionRow(
    ClassificationResult r,
    ClassificationResult? topResult,
  ) {
    final pct = (r.confidence * 100).toStringAsFixed(1);
    final isTop = r == topResult;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              r.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                color: isTop ? const Color(0xFF1A1A2E) : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: r.confidence,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isTop
                      ? (r.isHealthy
                            ? const Color(0xFF1EAC50)
                            : const Color(0xFFE53935))
                      : Colors.grey[400]!,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '$pct%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                color: isTop ? const Color(0xFF1A1A2E) : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topResult = widget.results.isNotEmpty ? widget.results[0] : null;
    final isHealthy = topResult?.isHealthy ?? false;
    final confidencePercent = ((topResult?.confidence ?? 0) * 100)
        .toStringAsFixed(1);
    final info = _getDiseaseInfo(topResult?.label ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Analysis Result',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image with status badge ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.imagePath.startsWith('http')
                      ? Image.network(
                          widget.imagePath,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : Image.file(
                          File(widget.imagePath),
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 220,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isHealthy
                          ? const Color(0xFF1EAC50)
                          : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHealthy
                              ? Icons.check_circle
                              : Icons.warning_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isHealthy ? 'Healthy' : 'Disease Detected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Primary result card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color:
                              (isHealthy
                                      ? const Color(0xFF1EAC50)
                                      : const Color(0xFFE53935))
                                  .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isHealthy
                              ? Icons.eco_rounded
                              : Icons.bug_report_rounded,
                          color: isHealthy
                              ? const Color(0xFF1EAC50)
                              : const Color(0xFFE53935),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topResult?.label ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Confidence: $confidencePercent%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Confidence bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: topResult?.confidence ?? 0,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isHealthy
                            ? const Color(0xFF1EAC50)
                            : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Description card ──
            _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'About This Condition',
              content: info['description'] ?? '',
              iconColor: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 12),

            // ── Care tips & Treatment ──
            ResultTreatmentSection(
              isHealthy: isHealthy,
              content: info['tips'] ?? '',
              topResult: topResult,
            ),
            const SizedBox(height: 16),

            // ── All predictions ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFF9C27B0),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'All Predictions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...widget.results.map(
                    (r) => _buildPredictionRow(r, topResult),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Scan again button ──
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Pop back to scan page (remove result + preview pages)
                  int popCount = 0;
                  Navigator.of(context).popUntil((_) => ++popCount > 2);
                },
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text(
                  'Scan Another Leaf',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1EAC50),
                  side: const BorderSide(color: Color(0xFF1EAC50), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Reusable info card widget.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;

  const _InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
