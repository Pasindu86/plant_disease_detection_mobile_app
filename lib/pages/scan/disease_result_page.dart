import 'dart:io';

import 'package:flutter/material.dart';

import '../../models/disease_model.dart';

class DiseaseResultPage extends StatelessWidget {
  final String imagePath;
  final DiseaseResult result;
  final List<DiseaseResult> topPredictions;
  final DiseaseInfo diseaseInfo;

  const DiseaseResultPage({
    super.key,
    required this.imagePath,
    required this.result,
    required this.topPredictions,
    required this.diseaseInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(imagePath), fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Result badge at bottom
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                result.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Confidence: ${result.confidenceText}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Confidence indicator card
                _buildConfidenceCard(),
                const SizedBox(height: 16),

                // Description card
                _buildInfoCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Description',
                  child: Text(
                    diseaseInfo.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cause card
                _buildInfoCard(
                  icon: Icons.bug_report_outlined,
                  title: 'Cause',
                  child: Text(
                    diseaseInfo.cause,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Severity card
                _buildInfoCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Severity',
                  child: _buildSeverityIndicator(),
                ),
                const SizedBox(height: 16),

                // Symptoms card
                _buildInfoCard(
                  icon: Icons.visibility_outlined,
                  title: 'Symptoms',
                  child: Column(
                    children: diseaseInfo.symptoms
                        .map((s) => _buildBulletPoint(s))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Treatment card
                _buildInfoCard(
                  icon: Icons.healing_rounded,
                  title: result.isHealthy
                      ? 'Care Recommendations'
                      : 'Treatment',
                  child: Column(
                    children: diseaseInfo.treatments
                        .asMap()
                        .entries
                        .map((e) => _buildNumberedPoint(e.key + 1, e.value))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Add Care Treatment button - shown if analysis report exists
                if (diseaseInfo.treatments.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => FractionallySizedBox(
                            heightFactor: 0.85,
                            child: CareTreatmentStepsSheet(
                              treatments: diseaseInfo.treatments,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text(
                        'Add Care Treatment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
                const SizedBox(height: 16),

                // Other predictions card
                if (topPredictions.length > 1)
                  _buildInfoCard(
                    icon: Icons.analytics_outlined,
                    title: 'Other Possibilities',
                    child: Column(
                      children: topPredictions
                          .skip(1)
                          .map((p) => _buildPredictionRow(p))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 16),

                // Low confidence warning
                if (!result.isConfident)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The confidence is below 60%. For a more accurate '
                            'result, try taking a clearer photo with better '
                            'lighting and ensure the leaf fills the frame.',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Scan again button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Pop back to ScanPage (2 screens back: Result -> Preview was replaced, so just pop once to ScanPage)
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text(
                      'Scan Another Leaf',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isHealthy = result.isHealthy;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isHealthy ? Colors.green : Colors.red.shade400,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isHealthy ? Colors.green : Colors.red).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isHealthy ? Icons.check_rounded : Icons.warning_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildConfidenceCard() {
    final confidence = result.confidence;
    final color = confidence >= 80
        ? const Color(0xFF4CAF50)
        : confidence >= 60
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prediction Confidence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                result.confidenceText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence / 100.0,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            confidence >= 80
                ? 'High confidence - Result is reliable'
                : confidence >= 60
                ? 'Moderate confidence - Consider retaking photo'
                : 'Low confidence - Please retake with better lighting',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSeverityIndicator() {
    final severity = diseaseInfo.severity;
    Color severityColor;
    IconData severityIcon;

    switch (severity) {
      case 'None':
        severityColor = Colors.green;
        severityIcon = Icons.check_circle_outline;
        break;
      case 'Low to Moderate':
        severityColor = Colors.orange;
        severityIcon = Icons.warning_amber_rounded;
        break;
      case 'Moderate':
        severityColor = Colors.orange.shade700;
        severityIcon = Icons.warning_rounded;
        break;
      case 'Moderate to High':
        severityColor = Colors.deepOrange;
        severityIcon = Icons.dangerous_outlined;
        break;
      case 'High':
        severityColor = Colors.red;
        severityIcon = Icons.dangerous_rounded;
        break;
      default:
        severityColor = Colors.grey;
        severityIcon = Icons.help_outline;
    }

    return Row(
      children: [
        Icon(severityIcon, color: severityColor, size: 24),
        const SizedBox(width: 8),
        Text(
          severity,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: severityColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionRow(DiseaseResult prediction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prediction.name,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: prediction.confidence / 100.0,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              prediction.confidenceText,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CareTreatmentStepsSheet extends StatefulWidget {
  final List<String> treatments;

  const CareTreatmentStepsSheet({super.key, required this.treatments});

  @override
  State<CareTreatmentStepsSheet> createState() =>
      _CareTreatmentStepsSheetState();
}

class _CareTreatmentStepsSheetState extends State<CareTreatmentStepsSheet> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Care & Treatment Plan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Stepper area
          Expanded(
            child: Theme(
              // Override theme to change Stepper colors
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF4CAF50), // Active step color
                ),
              ),
              child: Stepper(
                type: StepperType.vertical,
                physics: const BouncingScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => setState(() => _currentStep = step),
                onStepContinue: () {
                  if (_currentStep < widget.treatments.length - 1) {
                    setState(() => _currentStep += 1);
                  } else {
                    // Reached the end
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Care plan marked as active!'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder: (context, details) {
                  final isLastStep =
                      _currentStep == widget.treatments.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isLastStep ? 'Complete Plan' : 'Next Step',
                            ),
                          ),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4CAF50),
                                side: const BorderSide(
                                  color: Color(0xFF4CAF50),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: widget.treatments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final treatment = entry.value;
                  return Step(
                    title: Text(
                      'Step ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    content: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        treatment,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4A4A4A),
                          height: 1.5,
                        ),
                      ),
                    ),
                    isActive: _currentStep >= index,
                    state: _currentStep > index
                        ? StepState.complete
                        : StepState.indexed,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
