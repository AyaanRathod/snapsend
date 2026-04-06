import 'dart:io';
import 'package:flutter/material.dart';

/// Full-screen image viewer supporting pinch-to-zoom and panning.
/// Used to view high-res scanned receipts.
class ImageViewerScreen extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const ImageViewerScreen({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
