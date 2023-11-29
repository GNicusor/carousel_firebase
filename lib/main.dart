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
          title: Text('Firebase Storage Images'),
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
  Reference storageRef = FirebaseStorage.instance.ref().child('Images/');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: loadImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No images available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  snapshot.data![index],
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        }
      },
    );
  }
  Future<List<String>> loadImages() async {
    List<String> imageUrls = [];
    await for (ListResult result in listAllPaginated(storageRef)) {
      for (Reference ref in result.items) {
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    }
    return imageUrls;
  }
  Stream<ListResult> listAllPaginated(Reference storageRef) async* {
    String? pageToken;
    do {
      final listResult = await storageRef.list(ListOptions(
        maxResults: 100,
        pageToken: pageToken,
      ));
      yield listResult;
      pageToken = listResult.nextPageToken;
    } while (pageToken != null);
  }
}//meow