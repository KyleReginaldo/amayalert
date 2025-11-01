import 'package:flutter/material.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewerPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5.0,
          child: imageUrl.isNotEmpty
              ? Image.network(imageUrl, fit: BoxFit.contain)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
