import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final XFile file;

  const CameraScreen(this.file);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Center(
        child: Text('Preview'),
      ),
    );
  }
}