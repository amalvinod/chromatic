import 'package:camera/camera.dart';
import 'package:chromatic/pages/camera_screen.dart';
import 'package:chromatic/pages/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

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
  bool _isCameraInitialized = false;

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreview(file, key: null,),
        ),
      );
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
          builder: (context) => CameraScreen(file),
        ),
      );
    } on CameraException catch (e) {
      debugPrint("Error Occurred: $e");
      return;
    }
  }

  void detectColor() {
    // Add your logic for live image color detection here
    // You can use _controller.value.previewImage to access the live camera feed
    // Perform color detection on the image frames and update the UI accordingly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
          if (_isCameraInitialized)
      Container(
      height: double.infinity,
      child: CameraPreview(_controller),
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
    children: [ Container(
      child: RawMaterialButton(
        onPressed: () async {
          if (!_controller.value.isInitialized) {
            return null;
          }
          if (_controller.value.isTakingPicture) {
            return null;
          }

          try {
            _controller.setFlashMode(FlashMode.off);
            XFile file = await _controller.takePicture();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePreview(file, key: null,)));
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
          onPressed: detectColor,
          fillColor: Colors.white,
          child: const Icon(Icons.colorize),
          shape: const CircleBorder(),
        ),
      ),
     ],
    ),
    ),
    ),
    ],
    ),],
      ),
    );
  }
}


