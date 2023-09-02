import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';

class pdfupload extends StatefulWidget {
  String names="d";
  pdfupload(String name){
    this.names = name;
  }
  @override
  State<pdfupload> createState() => _pdfuploadState(names);
}

class _pdfuploadState extends State<pdfupload> {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pdfData = [];
  String names='d';
  _pdfuploadState(String name){
    this.names=name;
  }
  Future<String> uploadpdf( String filename , File file) async  {
    final refrence = FirebaseStorage.instance.ref().child('${names}_pdfs/$filename.pdf');
    final uploadtask = refrence.putFile(file);
    await uploadtask.whenComplete(() {});
    final downloadLink = await refrence.getDownloadURL();
    return downloadLink;
}
void getallpdf() async{
    final results= await
    _firebaseFirestore.collection("${names}pdfs").get();
    pdfData = results.docs.map((e) => e.data()).toList();
    setState(() {

    });
}

void pickFile() async {
    final pickedfile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if(pickedfile!= null){
      String filename = pickedfile.files[0].name;
      File file =   File(pickedfile.files[0].path!);

      final downloadlink = await uploadpdf(filename, file);
      await _firebaseFirestore.collection("${names}pdfs").add({
        "name" : filename,
        "url" : downloadlink,
      });
      print("pdf uplaoded successfully");

    }
}
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallpdf();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        leading: Container(),
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05 , left: 20,right: 20
          ),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text("  Lab Reports"
                  ,style: TextStyle(
                    fontFamily: 'Convergence',
                    fontWeight: FontWeight.w600,

                    fontSize: 28,
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
      ),
      body: GridView.builder(
        itemCount: pdfData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder:(context,index){
          return Container(
            padding: EdgeInsets.all(9.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> pdfviewerScreen('${pdfData[index]['url']}')));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black,width: 1.5 ),

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset("images/pdf1.png",height: 120, width: 100,),
                    Text('${pdfData[index]['name']}', style: TextStyle(
                      fontFamily: 'Convergence',
                      fontSize: 18,
                    ),)
                  ],
                )
              ),
            ),
          );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload_file),
        onPressed: pickFile,
      ),
    );
  }
}
class pdfviewerScreen extends StatefulWidget {
   String pdfUrl="";
  pdfviewerScreen(String url){
    this.pdfUrl = url;
  }


  @override
  State<pdfviewerScreen> createState() => _pdfviewerScreenState(pdfUrl);
}

class _pdfviewerScreenState extends State<pdfviewerScreen> {

  String pdfUrl="";
  _pdfviewerScreenState(String name){
    this.pdfUrl=name;
  }
  PDFDocument? document;
  void intializedf() async{
    document = await PDFDocument.fromURL(widget.pdfUrl);
    setState(() {

    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    intializedf();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: document!=null ? PDFViewer(
         document: document! ,
       ) : Center(child: CircularProgressIndicator(),)
    );
  }
}
