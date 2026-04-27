import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/services/care_treatment_service.dart';
import 'package:plant_disease_detection_mobile_app/services/plant_classifier_service.dart';

class ResultTreatmentSection extends StatelessWidget {
  final bool isHealthy;
  final String content;
  final ClassificationResult? topResult;

  const ResultTreatmentSection({
    super.key,
    required this.isHealthy,
    required this.content,
    this.topResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Care tips card ──
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
                    Icons.local_florist_rounded,
                    color: Color(0xFF4CAF50),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isHealthy ? 'Maintenance Tips' : 'Treatment & Care Tips',
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
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Add Care Treatment button - shown if there are care tips
        if (!isHealthy && content.isNotEmpty)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final List<String> steps = content
                    .split('\n')
                    .map((e) => e.replaceAll('•', '').trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (steps.isNotEmpty) {
                  try {
                    await CareTreatmentService().saveTreatment(
                      diseaseName: topResult?.label ?? 'Plant Treatment',
                      tips: 'Care Treatment:\n${steps.join("\n")}',
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Treatment saved to Care Treatments!'),
                          backgroundColor: Color(0xFF4CAF50),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      // Pop back to home after saving
                      int popCount = 0;
                      Navigator.of(context).popUntil((_) => ++popCount > 2);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to save treatment: $e'),
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text(
                'Add Care Treatment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
      ],
    );
  }
}
