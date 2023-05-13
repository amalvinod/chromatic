import 'package:camera/camera.dart';
import 'package:chromatic/pages/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("Access is denied");
            break;
          default:
            print(e.description);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
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
                  children: [
                    Container(
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
                                    builder: (context) => ImagePreview(file)));
                          } on CameraException catch (e) {
                            debugPrint("Error Occured : $e");
                            return null;
                          }
                        },
                        fillColor: Colors.white,
                        child: const Icon(
                          Icons.camera,
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                    Container(
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
                                    builder: (context) => ImagePreview(file)));
                          } on CameraException catch (e) {
                            debugPrint("Error Occured : $e");
                            return null;
                          }
                        },
                        fillColor: Colors.white,
                        child: const Icon(
                          Icons.camera,
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                    Container(
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
                                    builder: (context) => ImagePreview(file)));
                          } on CameraException catch (e) {
                            debugPrint("Error Occured : $e");
                            return null;
                          }
                        },
                        fillColor: Colors.white,
                        child: const Icon(
                          Icons.camera,
                        ),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }
}
