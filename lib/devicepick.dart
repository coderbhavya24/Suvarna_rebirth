import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as  http;
import 'package:swathyavardhak/Firebase_api.dart';

class Pick_From_Device extends StatefulWidget {

  String names="d";

   Pick_From_Device(String name){
    this.names = name;
  }

  @override
  State<Pick_From_Device> createState() => _Pick_From_DeviceState(names);
}

class _Pick_From_DeviceState extends State<Pick_From_Device> {
  final blue1 = const Color(0xff0d0f35);
File? file;
  String imgpath='';
  String names='d';
  _Pick_From_DeviceState(String name){
    this.names=name;
  }

  Future<void> selectFileFromStorage() async {
    print(names);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpeg', 'jpg'],
    );
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      imgpath=path!;
    });
    print('File selected: $path');
  }

  Future<void> uploadFileAndSaveUrl() async {
    if (file == null) return;

    final filename = basename(file!.path);
    final destination = '$names/$filename';
    final ref = FirebaseStorage.instance.ref(destination);

    try {
      // Upload the file to Firebase Storage
      await ref.putFile(file!);

      // Get the download link
      final downloadLink = await ref.getDownloadURL();

      // Get the current date and time
      final dateTime = DateTime.now();

      // Send the image to the API to get the text
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://suvarna-sarthak-guptas-projects.vercel.app/image'),
      );
      var imageFile = await http.MultipartFile.fromPath(
        'file',
        imgpath,
         // Ensure correct MIME type
      );
      request.files.add(imageFile);

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final result = json.decode(responseData.body);

        // Print the entire response for debugging
        print('API Response: $result');

        // Assuming the text is in the response under the key 'message'
        final extractedText = result['message'] ?? 'No text extracted';

        // Save the download link and other details to Firestore
        await FirebaseFirestore.instance.collection("${names}data").add({
          "name": filename,
          "url": downloadLink,
          "uploadDate": dateTime,
          "extractedText": extractedText,
        });

        print('File uploaded and download link saved to Firestore');
      } else {
        print('Failed to extract text from the image. Status code: ${response.statusCode}');
        final responseData = await http.Response.fromStream(response);
        print('Response body: ${responseData.body}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: Container(
        margin: EdgeInsets.only(right: 20,bottom: 20),
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: ()  {
            final snackBar = SnackBar(
              content: const Text('File uploaded'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );
            uploadFileAndSaveUrl();
            // Find the ScaffoldMessenger in the widget tree
            // and use it to show a SnackBar.
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Icon(Icons.cloud_upload,
          size: 35,),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.12 , left: 20,right: 20
            ),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Text("  View section"
                    ,style: TextStyle(
                      fontFamily: 'Convergence',
                      fontWeight: FontWeight.w600,

                      fontSize: 23,
                    ),),
                ),
                Container(
                    height: 45,
                    width: 45,

                    // padding: EdgeInsets.all(20),
                    // margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      boxShadow: const [BoxShadow(
                        color: Colors.white,
                        spreadRadius: 1.5,
                      ),],
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(0, 178, 255, 100),
                      // color: Color.fromRGBO(132, 29, 210, 72),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('images/avata.png'),
                    )
                ),
              ],
            ),
          ),
          file!=null?
             Container(
               margin: EdgeInsets.only(top: 30),
              height: 400,
              width: 400,
              color: Colors.transparent,
              child: Image.file(
                File(file!.path),
                // width: double.infinity,
                // fit: BoxFit.cover,
              ),
            ) :
          Container(
            margin: EdgeInsets.only(top: 30 , left: 2 , right: 2),
            height: 400,
            width: 400,
            // color: Colors.grey,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                )
              ),
            child: Center(
              child: Text("Image Area",
              style: TextStyle(
                fontFamily: 'Convergence',
                fontSize: 30,
              ),),
            )
          ),

            Container(),
          GestureDetector(
            onTap: selectFileFromStorage,
            child: Container(
              margin: EdgeInsets.only(top: 30),
              width: MediaQuery.of(context).size.width*0.8,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.blue,
              ),
              child: Center(
                child: Text('Select File',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: 'Convergence'
                ),),
              ),
            ),
          ),



        ],
      ),

    );
  }
}

