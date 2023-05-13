import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final XFile file;

  const ImagePreview(this.file, {required key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Center(
        child: Image.file(
          File(file.path),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}