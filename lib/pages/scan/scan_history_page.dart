import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/disease_detection_service.dart';
import '../../services/plant_classifier_service.dart';
import 'result_page.dart';

class ScanHistoryPage extends StatelessWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DiseaseDetectionService detectionService = DiseaseDetectionService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Scan History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: detectionService.getUserDetections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading history: ${snapshot.error}'),
            );
          }

          final detections = snapshot.data ?? [];

          if (detections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: detections.length,
            itemBuilder: (context, index) {
              final detection = detections[index];
              final diseaseName = detection['diseaseName'] ?? 'Unknown';
              final confidence =
                  (detection['confidence'] as num?)?.toDouble() ?? 0.0;
              final isHealthy = detection['isHealthy'] == true;
              final detectedAtStr = detection['detectedAt'] as String?;
              final imagePath = detection['imagePath'] as String?;

              DateTime? detectedAt;
              if (detectedAtStr != null) {
                detectedAt = DateTime.tryParse(detectedAtStr);
              }

              String formattedDate = 'Unknown date';
              if (detectedAt != null) {
                // simple format since we don't know if intl is installed
                formattedDate =
                    '${detectedAt.year}-${detectedAt.month.toString().padLeft(2, '0')}-${detectedAt.day.toString().padLeft(2, '0')} ${detectedAt.hour.toString().padLeft(2, '0')}:${detectedAt.minute.toString().padLeft(2, '0')}';
              }

              Widget leadingIcon = CircleAvatar(
                backgroundColor: isHealthy
                    ? const Color(0xFFE5F9E9)
                    : const Color(0xFFFFEBEE),
                radius: 28,
                child: Icon(
                  isHealthy ? Icons.check_circle : Icons.warning,
                  color: isHealthy ? const Color(0xFF1EAC50) : Colors.red,
                  size: 28,
                ),
              );

              Widget leadingWidget = leadingIcon;
              if (imagePath != null && imagePath.isNotEmpty) {
                // Determine if we should attempt to load this.
                // Assuming it's a local file path as saved initially.
                leadingWidget = ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return leadingIcon; // Fallback if image file is deleted or lost
                      },
                    ),
                  ),
                );
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () {
                    // Navigate to the actual scan result page using the history item's data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultPage(
                          imagePath: imagePath ?? '',
                          results: [
                            ClassificationResult(
                              label: diseaseName,
                              confidence: confidence,
                            ),
                          ],
                          isHistory:
                              true, // Prevents saving the duplicate to history again
                        ),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.all(16),
                  leading: leadingWidget,
                  title: Text(
                    diseaseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      context,
                      detectionService,
                      detection['id'],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DiseaseDetectionService service,
    String? id,
  ) {
    if (id == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
          'Are you sure you want to delete this scan record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              service.deleteDetection(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
