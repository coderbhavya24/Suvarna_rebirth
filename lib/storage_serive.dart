import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'dart:io';

class Storage{
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<firebase_storage.ListResult> listFiles() async {
    firebase_storage.ListResult results = await storage.ref('vaibhav2012093@akgec.ac.in').listAll();

    results.items.forEach((firebase_storage.Reference ref) {
      print('Found file: $ref');
    });

    return results;
  }
  Future<String> downloadURL(String imageName) async{
    String downloadURL  = await
    storage.ref('test/$imageName').getDownloadURL();

    return downloadURL;
  }

}
