
import 'package:backcoffer_task/video_player.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCard extends StatelessWidget {
  final String category;
  final String description;
  final String location;
  final String title;
  final String videoname;

  VideoCard({
    required this.category,
    required this.description,
    required this.location,
    required this.title,
    required this.videoname,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: $category'),
            Text('Description: $description'),
            Text('Location: $location'),
            Text('Video Name: $videoname'),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoURL: videoname),
            ),
          );
        },
      ),
    );
  }
}

class ShowAllVideos extends StatefulWidget {
  const ShowAllVideos({Key? key}) : super(key: key);

  @override
  State<ShowAllVideos> createState() => _ShowAllVideosState();
}

class _ShowAllVideosState extends State<ShowAllVideos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Videos"), centerTitle: true),
      body: VideoList(),
    );
  }
}

class VideoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('videosdetail').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final docs = snapshot.data?.docs;

        if (docs == null || docs.isEmpty) {
          return Text('No data available.');
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            return VideoCard(
              category: data['category'],
              description: data['description'],
              location: data['location'],
              title: data['title'],
              videoname: data['videoname'],
            );
          },
        );
      },
    );
  }
}

