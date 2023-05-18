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
        title: Text(
          'Camera Screen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.black,
        elevation: 0,
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
                    builder: (context) => ImagePreview(
                      file,
                      onColorSelected: onColorSelected,
                    ),
                  ),
                );
              },
              child: Text('Preview Image'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: TextStyle(fontSize: 18),
                primary: Colors.yellow.shade100,
                onPrimary: Colors.black,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}