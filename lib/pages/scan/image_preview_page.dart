import 'dart:io';

import 'package:flutter/material.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;

  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: Center(
        child: imagePath.isNotEmpty
            ? Image.file(File(imagePath))
            : const Text('No image to display'),
      ),
    );
  }
}
