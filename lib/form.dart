import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class form_fillup extends StatefulWidget {
  String vidname;
  form_fillup({super.key,required this.vidname});

  @override
  State<form_fillup> createState() => _form_fillupState();
}

class _form_fillupState extends State<form_fillup> {
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _otherFieldController = TextEditingController();

  List<String> spinnerItems = ['entertainment', 'thrill', 'romantic', 'horror'];
  String selectedValue = 'entertainment';

  String _locationMessage = "";

  @override
  void initState() {
    _getLocation();
    _descriptionController = TextEditingController(); // Initialize the controller
    super.initState();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationMessage =
        'Latitude: ${position.latitude}\nLongitude: ${position.longitude}';
      });
    } on PermissionDeniedException catch (e) {
      print('Permission denied: $e');
      setState(() {
        _locationMessage = 'Permission denied to access location';
      });
    } on LocationServiceDisabledException catch (e) {
      print('Location service disabled: $e');
      setState(() {
        _locationMessage = 'Location service is disabled';
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _locationMessage = 'Error getting location';
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Video"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text(
              "Title for Video:",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _otherFieldController,
              decoration: InputDecoration(
                hintText: "Enter Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Description:",
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: "Enter Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Category:",
              style: TextStyle(fontSize: 16),
            ),
            DropdownButton(
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
              items: spinnerItems.map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async{

                String description = _descriptionController.text;
                String title = _otherFieldController.text;
                String dropdownvalue = selectedValue;
                String location = _locationMessage;

                print("Description: $description");
                print("Title: $title");
                print("Category: $dropdownvalue");
                print("Location: $location");
                try {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  CollectionReference videos = firestore.collection('videosdetail');

                  DocumentReference docRef = await videos.add({
                    'videoname': widget.vidname.toString(),
                    'title': _otherFieldController.text,
                    'description': _descriptionController.text,
                    'category': selectedValue,
                    'location': _locationMessage,
                  });

                  print('Document added with ID: ${docRef.id}');
                } catch (e) {
                  print('Error inserting data: $e');
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
