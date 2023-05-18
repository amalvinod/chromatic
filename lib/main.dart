import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:chromatic/pages/camera_screen.dart';
import 'package:chromatic/pages/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:color_models/color_models.dart'; //new package added
import 'package:tflite_flutter/tflite_flutter.dart'; //new package added
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  Color? _detectedColor; // Added variable to store the detected color
  final modelPath = 'Chromatic-model.tflite';
  String? detectedColorByModel;
  bool _isCameraInitialized = false;
  Offset _cursorPosition = Offset(0, 0); // Initial cursor position

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    await _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void captureImage() async {
    if (!_isCameraInitialized || _controller.value.isTakingPicture) {
      return;
    }

    try {
      _controller.setFlashMode(FlashMode.off);
      final XFile file = await _controller.takePicture();

      final img.Image? capturedImage =
          img.decodeImage(await file.readAsBytes());
      if (capturedImage != null) {
        final pixelColor = capturedImage.getPixel(0, 0);
        final color = Color(pixelColor as int);
        print('Captured Pixel Color: $color');
      }
      String? savedHexCode;

      void handleColorSelected(String hexCode) {
        setState(() {
          savedHexCode = hexCode;
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreview(file,
              key: null, onColorSelected: handleColorSelected),
        ),
      );
      ;
    } on CameraException catch (e) {
      debugPrint("Error Occurred: $e");
      return;
    }
  }

  void openCamera() async {
    if (!_isCameraInitialized || _controller.value.isTakingPicture) {
      return;
    }

    try {
      _controller.setFlashMode(FlashMode.off);
      final XFile file = await _controller.takePicture();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            file,
            onColorSelected: (String) {},
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint("Error Occurred: $e");
      return;
    }
  }

  void _startFrameAnalysis() {
    if (_controller.value.isStreamingImages) {
      stopImageProcessing();
    } else if (_controller.value.isInitialized) {
      print("Processing Starting");
      _controller.startImageStream((CameraImage image) {
        _processImage(image);
      });
    }
  }

  void _processImage(CameraImage image) {
    final Plane plane = image.planes[0];
    final int? width = plane.width;
    final int? height = plane.height;
    final int bytesPerPixel = plane.bytesPerPixel!;
    final Uint8List bytes = plane.bytes;

    final int pixelX = _cursorPosition.dx.toInt();
    final int pixelY = _cursorPosition.dy.toInt();

    final int rowStride = plane.bytesPerRow;
    final int pixelOffset = pixelY * rowStride + pixelX * bytesPerPixel;

    final int alpha = bytes[pixelOffset];
    final int red = bytes[pixelOffset + 1];
    final int green = bytes[pixelOffset + 2];
    final int blue = bytes[pixelOffset + 3];

    final Color rgbColor = Color.fromARGB(alpha, red, green, blue);
    final HSVColor hsvColor = HSVColor.fromColor(rgbColor);

    final double hue = hsvColor.hue;
    final double saturation = hsvColor.saturation;
    final double value = hsvColor.value;

    print('Captured Pixel HSV: Hue=$hue, Saturation=$saturation, Value=$value');
    setState(() {
      _detectedColor = rgbColor; // Update the detected color
    });
    HSVName([hue, saturation, value]);
  }

  List<List<double>> generateList() {
    final rows = 1;
    final columns = 144;
    return List.generate(rows, (_) => List.filled(columns, 0.0));
  }

  int argMax(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('The input list must not be empty.');
    }

    var maxIndex = 0;
    var maxValue = values[0];

    for (var i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  //CSV only has 1 column
  Future<List<String>> readCSV() async {
    final String csvData =
        await rootBundle.loadString('assets/color-labels.csv');
    List<String> csvRows = LineSplitter().convert(csvData);
    return csvRows;
  }

  void HSVName(List<double> hsvValues) async {
    // Load the TFLite model
    List<dynamic> csvContent = await readCSV();
    final interpreter =
        await Interpreter.fromAsset(modelPath); //successful contact with model
    final inputTensor = interpreter.getInputTensors()[0];
    final outputTensor = interpreter.getOutputTensors()[0];
    print("INPUT AND OUTPUT TENSORS");
    print(inputTensor);
    print(outputTensor);

    // Convert hsvValues to Float32List
    final inputValues = Float32List.fromList(hsvValues);

    // Set the input values

    final inputData = [inputValues];

    // Run inference
    // Allocate space for the output tensor
    final outputShape = outputTensor.shape;
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = generateList();

    // Run inference
    interpreter.run(inputData, output);

    // Process the output
    int index = argMax(output[0]);
    print(csvContent[index]);
    detectedColorByModel = csvContent[index];
    // Dispose the interpreter
    interpreter.close();
  }

  void detectColorByModel() async {
    print("BUTTON PRESSED");
    if (_controller.value.isStreamingImages) {
      stopImageProcessing();
    } else {
      _startFrameAnalysis();
    }
  }

  void stopImageProcessing() async {
    print("Stopping Image Processing");
    if (_controller.value.isStreamingImages) {
      _controller.stopImageStream();
    }
  }

  void updateCursorPosition(Offset newPosition) {
    print(_detectedColor);
    setState(() {
      _cursorPosition = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isCameraInitialized)
            GestureDetector(
              onPanUpdate: (details) {
                updateCursorPosition(details.localPosition);
                // detectColor(); // Call detectColor when cursor position updates
                // _startFrameAnalysis();
              },
              child: Container(
                height: double.infinity,
                child: CameraPreview(_controller),
              ),
            ),
          Positioned(
            left: _cursorPosition.dx - 15, // Adjust position for centering
            top: _cursorPosition.dy - 15, // Adjust position for centering
            child: Draggable(
              feedback: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
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
              onDragEnd: (dragDetails) {
                updateCursorPosition(dragDetails.offset);
              },
            ),
          ),
          if (_detectedColor != null) // Display the detected color box
            Positioned(
              // left: _cursorPosition.dx - 20,
              // right: _cursorPosition.dy - 20,
              bottom: 120, // Adjust the position of the box as needed
              child: Container(
                padding: EdgeInsets.all(8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _detectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Detected Color: $detectedColorByModel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: RawMaterialButton(
                          onPressed: () async {
                            if (!_controller.value.isInitialized) {
                              stopImageProcessing();
                              return null;
                            }
                            if (_controller.value.isTakingPicture) {
                              stopImageProcessing();
                              return null;
                            }

                            try {
                              _controller.setFlashMode(FlashMode.off);
                              stopImageProcessing();
                              XFile file = await _controller.takePicture();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ImagePreview(
                                            file,
                                            key: null,
                                            onColorSelected: (String) {},
                                          )));
                            } on CameraException catch (e) {
                              debugPrint("Error Occured : $e");
                              return null;
                            }
                          },
                          fillColor: Colors.white,
                          child: const Icon(Icons.camera),
                          shape: const CircleBorder(),
                        ),
                      ),
                      Container(
                        child: RawMaterialButton(
                          onPressed: openCamera,
                          fillColor: Colors.white,
                          child: const Icon(Icons.image),
                          shape: const CircleBorder(),
                        ),
                      ),
                      Container(
                        child: RawMaterialButton(
                          onPressed: detectColorByModel,
                          fillColor: Colors.white,
                          child: const Text('Start/Stop Live Detection'),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          padding: EdgeInsets.all(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
