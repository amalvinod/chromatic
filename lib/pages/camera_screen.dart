import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatefulWidget {
  ImagePreview(this.file, {super.key});
  XFile file;
  String images = '';
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  @override
  Widget build(BuildContext context) {
    File picture = File(widget.file.path);
    String images = picture.path.split('.').last;
    return Scaffold(
        appBar: AppBar(title: Text("Image preview")),
        body: Center(
          child: Image.file(picture),
        ));
  }
}
