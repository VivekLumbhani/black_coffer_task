import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';


class VideoPlayerScreen extends StatefulWidget {
  final String videoURL;

  VideoPlayerScreen({required this.videoURL});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    final _url = await downloadVideoURL(widget.videoURL);
    _videoPlayerController = VideoPlayerController.network(_url)
      ..initialize().then((_) {
        setState(() {
          _initializeVideoPlayerFuture = _videoPlayerController.play();
        });
      });

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.isPlaying != _isPlaying) {
        setState(() {
          _isPlaying = _videoPlayerController.value.isPlaying;
        });
      }
    });
  }

  Future<String> downloadVideoURL(String videoFile) async {
    try {
      String downloadURL =
      await FirebaseStorage.instance.ref('videos/$videoFile').getDownloadURL();
      print(downloadURL);
      return downloadURL;
    } on FirebaseException catch (e) {
      print(e);
      throw Exception("Failed to load video");
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    if (_initializeVideoPlayerFuture == null) {
      return CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_videoPlayerController),
          // Add a play/pause button
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {
              setState(() {
                if (_isPlaying) {
                  _videoPlayerController.pause();
                } else {
                  _videoPlayerController.play();
                }
              });
            },
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Player"), centerTitle: true),
      body: _buildVideoPlayer(),
    );
  }


}
