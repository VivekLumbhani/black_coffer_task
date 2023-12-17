import 'dart:io';
import 'dart:typed_data';

import 'package:backcoffer_task/form.dart';
import 'package:backcoffer_task/show_all_videos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
      setState(() {});
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


                }
              },
              child: button(
                isRecording ? Icons.stop : Icons.video_call_outlined,
                Alignment.bottomCenter,
              ),
            ),
            GestureDetector(
              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShowAllVideos()),
                );
              },
              child: button(Icons.browse_gallery, Alignment.bottomRight),
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
      final XFile videoFile = await cameraController.stopVideoRecording();
      print('Video file path: ${videoFile.path}');

      setState(() {
        isRecording = false;
      });


      await uploadVideoToFirebaseStorage(videoFile.path);
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }


  Future<void> uploadVideoToFirebaseStorage(String videoPath) async {
    try {
      final List<int> videoBytes = await File(videoPath).readAsBytes();

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      var ext = ".mp4";
      var vidname = timestamp + ext;

      final firebase_storage.Reference storageReference =
      firebase_storage.FirebaseStorage.instance.ref().child('videos/$vidname');

      await storageReference.putData(Uint8List.fromList(videoBytes));
      print('Video uploaded to Firebase Storage!');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => form_fillup(vidname: vidname)),
      );
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
