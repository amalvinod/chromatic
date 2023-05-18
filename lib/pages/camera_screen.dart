import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'image_preview.dart';

class CameraScreen extends StatelessWidget {
  final XFile file;
  final void Function(String?) onColorSelected;

  const CameraScreen(this.file, {required this.onColorSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImagePreview(file, onColorSelected: onColorSelected),
                  ),
                );
              },
              child: Text('Preview Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
