import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePreview extends StatefulWidget {
  final XFile file;

  const ImagePreview(this.file, {required Key key}) : super(key: key);

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  Offset? selectedPixel;
  Color? selectedColor;

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      final RenderBox box = context.findRenderObject() as RenderBox;
      selectedPixel = box.globalToLocal(details.globalPosition);
      selectedColor = _getColorAtPixel(selectedPixel);
    });
  }

  Color? _getColorAtPixel(Offset? pixel) {
    if (pixel == null) return null;

    final img.Image image =
        img.decodeImage(File(widget.file.path).readAsBytesSync())!;
    final int x = pixel.dx.toInt();
    final int y = pixel.dy.toInt();

    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      final img.Pixel pixelValue = image.getPixel(x, y);
      final int alpha = (pixelValue.a as int).clamp(0, 255);
      final int red = (pixelValue.r as int).clamp(0, 255);
      final int green = (pixelValue.g as int).clamp(0, 255);
      final int blue = (pixelValue.b as int).clamp(0, 255);
      return Color.fromARGB(alpha, red, green, blue);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: GestureDetector(
        onTapUp: _handleTapUp,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Image.file(
                File(widget.file.path),
                fit: BoxFit.contain,
              ),
            ),
            if (selectedPixel != null && selectedColor != null)
              Positioned(
                left: selectedPixel!.dx,
                top: selectedPixel!.dy,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: Center(
                      child: Text(
                        selectedColor!.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
