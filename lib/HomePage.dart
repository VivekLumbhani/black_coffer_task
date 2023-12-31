import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;

  int direction = 0;
  bool isRecording = false;

  @override
  void initState() {
    startCamera(direction);
    super.initState();
  }

  void startCamera(int direction) async {
    cameras = await availableCameras();

    cameraController = CameraController(
      cameras[direction],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {}); // To refresh widget
    }).catchError((e) {
      print(e);
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(cameraController),
            GestureDetector(
              onTap: () {
                setState(() {
                  direction = direction == 0 ? 1 : 0;
                  startCamera(direction);
                });
              },
              child: button(Icons.flip_camera_ios_outlined, Alignment.bottomLeft),
            ),
            GestureDetector(
              onTap: () async {
                if (!isRecording) {
                  startVideoRecording();
                } else {
                  stopVideoRecording();
                  await uploadVideoToFirebaseStorage();

                }
              },
              child: button(
                isRecording ? Icons.stop : Icons.video_call_outlined,
                Alignment.bottomCenter,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.topCenter,
              child: Text(
                "My Camera",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void startVideoRecording() async {
    try {
      await cameraController.startVideoRecording();
      setState(() {
        isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void stopVideoRecording() async {
    try {
      await cameraController.stopVideoRecording().then((value) {
        setState(() {
          isRecording = false;
        });
      });
    } catch (e) {
      print(e);
    }
  }
  Future<void> uploadVideoToFirebaseStorage() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videoPath = path.join(appDir.path, 'video.mp4');
      final String fileName = path.basename(videoPath);
      final File videoFile = File(videoPath);

      if (videoFile.existsSync()) {
        final firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('videos/$fileName');

        await storageReference.putFile(videoFile);
        print('Video uploaded to Firebase Storage!');
      } else {
        print('Error: Video file does not exist at path $videoPath');
      }
    } catch (e) {
      print('Error uploading video to Firebase Storage: $e');
    }
  }

  Widget button(IconData icon, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(
          left: 20,
          bottom: 20,
        ),
        height: 50,
        width: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
