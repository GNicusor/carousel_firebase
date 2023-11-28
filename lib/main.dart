import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('I try so hard and got no far:<'),
        ),
        body: ImageList(),
      ),
    );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    // Replace 'YOUR_DIRECTORY_PATH_HERE' with the actual path in Firebase Storage.
    String directoryPath = 'Images/';

    Reference reference = FirebaseStorage.instance.ref().child(directoryPath);

    // List all items in the directory
    ListResult result = await reference.listAll();

    // Get the download URLs for each item
    List<String> urls = [];
    for (Reference ref in result.items) {
      String url = await ref.getDownloadURL();
      urls.add(url);
    }

    setState(() {
      imageUrls = urls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            imageUrls[index],
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
