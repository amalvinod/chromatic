import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePreview extends StatefulWidget {
  final XFile file;
  final Function(String) onColorSelected;

  const ImagePreview(this.file, {Key? key, required this.onColorSelected}) : super(key: key);


  @override
  ImagePreviewState createState() => ImagePreviewState();
}

class ImagePreviewState extends State<ImagePreview> {
  Offset? _selectedPixel;
  String? selectedHexColor;
  Offset? cursorPosition;
  Color? _selectedColor;
  bool _colorSelected = false;


  void _handleDragStart(DragStartDetails details) {
    setState(() {
      cursorPosition = details.localPosition;
    });
  }
  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _selectedColor = _getColorAtPixel(cursorPosition);
      if (kDebugMode) {
        print("Color: End ");
        print(_selectedColor);
        print("Cursor Position: ");
        print(cursorPosition);
      }
    });
  }
  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      // RenderBox box = context.findRenderObject() as RenderBox;
      // cursorPosition = box.globalToLocal(details.globalPosition);
      cursorPosition = details.localPosition;
      if (kDebugMode) {
        print("Color: Update ");
        print(selectedHexColor);
        print("Cursor Position Update: ");
        print(cursorPosition);
      }
      if (_selectedColor != null) {
        String hexCode = _getHexCode(_selectedColor!);
        widget.onColorSelected(hexCode);
      }
    });
  }
  void _saveColor() {
    if (_selectedColor != null) {
      final String hexColor = _getHexCode(_selectedColor);
      widget.onColorSelected(hexColor);
      _colorSelected = true;
    }
  }
  Color? _getColorAtPixel(Offset? pixel) {
    if (pixel == null) return null;

    final img.Image image = img.decodeImage(File(widget.file.path).readAsBytesSync())!;
    final int x = pixel.dx.toInt();
    final int y = pixel.dy.toInt();

    if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
      final img.Pixel pixelValue = image.getPixel(x, y);
      final int alpha = (pixelValue.a as int).clamp(0, 255);
      final int red = (pixelValue.r as int).clamp(0, 255);
      final int green = (pixelValue.g as int).clamp(0, 255);
      final int blue = (pixelValue.b as int).clamp(0, 255);
      final int hexValue = ((alpha << 24) | (red << 16) | (green << 8) | blue) & 0xFFFFFFFF;
      // return '#${hexValue.toRadixString(16).padLeft(8, '0')}';
      return Color.fromARGB(alpha, red, green, blue);

    }

    return null;
  }


  String _getHexCode(Color? color) {
    if (color == null) return '';
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  String _getShade(Color? color) {
    if (color == null) return '';
    final double luminance = color.computeLuminance();
    if (luminance > 0.5) {
      return 'Light';
    } else {
      return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static View'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final imageSize = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );
          return GestureDetector(
            onPanStart: _handleDragStart,
            onPanUpdate: _handleDragUpdate,
            onPanEnd: _handleDragEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Image.file(
                    File(widget.file.path),
                    fit: BoxFit.contain,
                  ),
                ),
                if (cursorPosition != null)
                  Positioned(
                    left: cursorPosition!.dx, // Adjust the position as needed
                    top: cursorPosition!.dy, // Adjust the position as needed
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                          width: 3.0,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 80,
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          color: _selectedColor,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hex Code: ${_getHexCode(_selectedColor)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Shade: ${_getShade(_selectedColor)}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

