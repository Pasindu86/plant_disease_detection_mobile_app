import 'package:flutter/material.dart';
import '../../services/disease_detection_service.dart';

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

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: isHealthy
                        ? const Color(0xFFE5F9E9)
                        : const Color(0xFFFFEBEE),
                    radius: 24,
                    child: Icon(
                      isHealthy ? Icons.check_circle : Icons.warning,
                      color: isHealthy ? const Color(0xFF1EAC50) : Colors.red,
                      size: 28,
                    ),
                  ),
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
