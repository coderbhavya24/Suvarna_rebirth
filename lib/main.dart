import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swathyavardhak/Firebase_api.dart';
import 'package:swathyavardhak/Medicines.dart';
import 'package:swathyavardhak/presciptions_screen.dart';
import 'package:swathyavardhak/pdfupload.dart';
import 'package:swathyavardhak/devicepick.dart';
import 'package:swathyavardhak/setting.dart';
import 'package:swathyavardhak/splash.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home:  Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class MyHomePage extends StatefulWidget {


  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int num=0;
  double Text_size=23;
  final blue1 = const Color(0xff0d0f35);
  bool j=true;
  late File _image;
  final imagePicker = ImagePicker();
  final  _auth =  FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser!;

  final Stream<QuerySnapshot> users = FirebaseFirestore.instance.collection('users').snapshots();
  // your_async_method () async {
  //
  //   final documents = await FirebaseFirestore.instance.collection('users').doc(user.email);
  //   final userObject = documents.document.first.data;
  //   print(userObject);
  // }

    Future<void> getImage() async {
    final image = await imagePicker.pickImage(
        source: ImageSource.camera);

    setState(() {
      _image = File(image!.path);
    });
    File file = File(_image.path);
    final filename = basename(file!.path!);
    final destination = '${user.email}/$filename';
    // FirebaseApi.uploadFile(destination, file!);
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

      var mimeType = lookupMimeType(file!.path);
      var imageFile = await http.MultipartFile.fromPath(
        'file',
        _image.path,
        contentType: MediaType.parse(mimeType ?? 'image/'),
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
        await FirebaseFirestore.instance.collection("${user.email}data").add({
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
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user.email).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          notchMargin: 42,
          elevation: 85,
          color: blue1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              IconButton(
                onPressed: () {
                  Navigator.push(

                    context,
                    MaterialPageRoute(builder: (context) {
                      return MyHomePage();
                    }),
                  );
                },
                icon: Icon(Icons.home_outlined,
                color: Colors.white,
                ),
                iconSize: 35,
              ),
              Container(
                height: 60,
                width: 60,

                // padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  boxShadow: const [BoxShadow(
                    color: Colors.white,
                    spreadRadius: 1.5,
                  ),],
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(0, 178, 255, 100),
                  // color: Color.fromRGBO(132, 29, 210, 72),
                ),
                child:
                Container(
                  // margin: EdgeInsets.only(bottom: 20),
                  child: PopupMenuButton(
                    color: Colors.grey,
                    offset: Offset(27, 0),
                    // elevation: 200,
                    child: Icon(Icons.camera_alt,
                    size: 35,),

                    itemBuilder: (context) => [

                      PopupMenuItem(
                        child: GestureDetector(
                            onTap: () => getImage(),
                            child: Center(child: Text("Camera"))),
                      ),
                      // PopupMenuItem(
                      //   child: Text("Flutter.io"),
                      // ),
                      PopupMenuItem(
                        child: GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {

                                  return Pick_From_Device( user.email ?? 'files');
                                }),
                              );
                            },

                            child: Center(child: Text("Gallery"))),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SettingSwas(user.email ?? 'queries');
                    }),
                  );
                },
                icon: Icon(Icons.settings,
                color: Colors.white,),
                iconSize: 30,
              ),

              const SizedBox(),
            ],
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
                    child: Text("HI!   ${data['Name']}"

                      ,

                        // + nam_email!

                    style: TextStyle(
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


            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Retrieval(user.email ?? 'files');
                  }),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Color.fromRGBO(0, 178, 255, 100),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.09,left: 13,right: 13),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  [
                    Text('Prescription',
                    style: TextStyle(
                      fontFamily: 'Convergence',
                      fontWeight: FontWeight.w600,
                      fontSize: Text_size,
                    ),)
                    ,
                    Container(
                      height: 120.0,
                      width: 120.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'images/prescription.png'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )


                  ],
                ),


              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return Medicine(user.email ?? 'files');
                  }),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Color.fromRGBO(0, 178, 255, 100),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03,left: 13,right: 13),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  [
                    Text('Medicines',
                      style: TextStyle(
                        fontFamily: 'Convergence',
                        fontWeight: FontWeight.w600,
                        fontSize: Text_size,
                      ),)
                    ,
                    Container(
                      height: 120.0,
                      width: 120.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'images/lab result.png'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )


                  ],
                ),


              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return pdfupload(user.email ?? 'files');
                  }),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Color.fromRGBO(0, 178, 255, 100),
                ),
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03,left: 13,right: 13),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height*0.15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:  [
                    Text('Lab Reports',
                      style: TextStyle(
                        fontFamily: 'Convergence',
                        fontWeight: FontWeight.w600,
                        fontSize: Text_size,
                      ),)
                    ,
                    Container(
                      height: 110.0,
                      width: 110.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'images/medical.png'),
                          fit: BoxFit.fill,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )


                  ],
                ),


              ),
            ),
          ],
        ),

      ),
    );
  }

  return Scaffold(
    body: Center(

      child: Container(
        height: 80,
        width: 80,
        child: CircularProgressIndicator(
          strokeWidth: 8,
        ),
      ),
    ),
  );
},
);
  }
}
