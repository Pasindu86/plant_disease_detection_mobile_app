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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Scan History',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: detectionService.getUserDetections(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1EAC50)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading history',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
                  ),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final detections = snapshot.data ?? [];

          if (detections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      size: 64,
                      color: Color(0xFF1EAC50),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Scans Yet',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your plant disease scan history\nwill appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: detections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                formattedDate =
                    '${detectedAt.year}-${detectedAt.month.toString().padLeft(2, '0')}-${detectedAt.day.toString().padLeft(2, '0')} ${detectedAt.hour.toString().padLeft(2, '0')}:${detectedAt.minute.toString().padLeft(2, '0')}';
              }

              final Widget placeholderIcon = Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFE5F9E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isHealthy ? Icons.check_circle : Icons.warning,
                  color: isHealthy ? const Color(0xFF1EAC50) : Colors.red,
                  size: 36,
                ),
              );

              Widget imageSection = placeholderIcon;

              if (imagePath != null && imagePath.isNotEmpty) {
                final isNetworkImage = imagePath.startsWith('http');
                imageSection = ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: isNetworkImage
                      ? Image.network(
                          imagePath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => placeholderIcon,
                        )
                      : Image.file(
                          File(imagePath),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => placeholderIcon,
                        ),
                );
              }

              return GestureDetector(
                onTap: () {
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
                        isHistory: true, // Prevents duplicates
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Picture
                      imageSection,
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diseaseName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isHealthy
                                    ? const Color(0xFFE5F9E9)
                                    : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isHealthy
                                    ? 'Healthy'
                                    : '${(confidence * 100).toInt()}% Match',
                                style: TextStyle(
                                  color: isHealthy
                                      ? const Color(0xFF1EAC50)
                                      : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Delete Icon
                      IconButton(
                        onPressed: () => _confirmDelete(
                          context,
                          detectionService,
                          detection['id'],
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
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
