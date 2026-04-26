import 'package:flutter/material.dart';
import 'package:plant_disease_detection_mobile_app/services/care_treatment_service.dart';
import 'package:plant_disease_detection_mobile_app/models/care_treatment_model.dart';

class CareTreatmentsPage extends StatelessWidget {
  const CareTreatmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CareTreatmentService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Care Treatments'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0.5,
      ),
      body: StreamBuilder<List<CareTreatmentModel>>(
        stream: service.getUserTreatments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final treatments = snapshot.data ?? [];
          if (treatments.isEmpty) {
            return const Center(
              child: Text(
                'No care treatments saved yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: treatments.length,
            itemBuilder: (context, index) {
              final item = treatments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.diseaseName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} • ${item.createdAt.hour}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _TreatmentChecklist(
                      tips: item.tips,
                      onFinished: () {
                        // Directly delete the item when done
                        service.deleteTreatment(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Treatment marked as done and removed.',
                            ),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TreatmentChecklist extends StatefulWidget {
  final String tips;
  final VoidCallback onFinished;

  const _TreatmentChecklist({required this.tips, required this.onFinished});

  @override
  State<_TreatmentChecklist> createState() => _TreatmentChecklistState();
}

class _TreatmentChecklistState extends State<_TreatmentChecklist> {
  late List<String> _steps;
  late List<bool> _checked;

  @override
  void initState() {
    super.initState();
    _parseSteps();
  }

  @override
  void didUpdateWidget(covariant _TreatmentChecklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tips != widget.tips) {
      _parseSteps();
    }
  }

  void _parseSteps() {
    // Parse the saved tips block -> split by line, trim, and filter out empty strings
    // or the "Care Treatment:" header if it exists.
    final lines = widget.tips
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isNotEmpty &&
        lines.first.toLowerCase().contains('care treatment')) {
      lines.removeAt(0);
    }

    _steps = lines;
    _checked = List.filled(_steps.length, false);
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Text(
        widget.tips,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF4B5563),
          height: 1.6,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_steps.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _checked[index] = !_checked[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _checked[index]
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      border: Border.all(
                        color: _checked[index]
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: _checked[index]
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _checked[index] = !_checked[index];
                      });
                    },
                    child: Text(
                      _steps[index],
                      style: TextStyle(
                        fontSize: 15,
                        color: _checked[index]
                            ? Colors.grey[500]
                            : const Color(0xFF4B5563),
                        height: 1.5,
                        decoration: _checked[index]
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        // Done button
        if (_steps.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _checked.every((c) => c) ? widget.onFinished : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5F9E9), // Light green
                  foregroundColor: const Color(0xFF2E7D32), // Darker green text
                  disabledBackgroundColor: Colors.grey[200],
                  disabledForegroundColor: Colors.grey[500],
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Treatment is done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
