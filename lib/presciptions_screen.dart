import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swathyavardhak/storage_serive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Retrieval extends StatefulWidget {
  // const Homescreen({key? key}) : super(key: key);
  String names = "d";
  Retrieval(String name) {
    this.names = name;
  }
  @override
  State<Retrieval> createState() => _RetrievalState(names);
}

class _RetrievalState extends State<Retrieval> {
  String names = 'd';
  _RetrievalState(String name) {
    this.names = name;
  }
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> imgData = [];
  void getallimgs() async {
    final results = await _firebaseFirestore.collection("${names}data").get();
    imgData = results.docs.map((e) => e.data()).toList();
    setState(() {});
  }

  List<bool> check = List<bool>.filled(100, false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallimgs();
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        leading: Container(),
        flexibleSpace: Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.05,
              left: 20,
              right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  "  Prescriptions",
                  style: TextStyle(
                    fontFamily: 'Convergence',
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
              ),
              Container(
                  height: 45,
                  width: 45,

                  // padding: EdgeInsets.all(20),
                  // margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 1.5,
                      ),
                    ],
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(0, 178, 255, 100),
                    // color: Color.fromRGBO(132, 29, 210, 72),
                  ),
                  child: CircleAvatar(
                    backgroundImage: AssetImage('images/avata.png'),
                  )),
            ],
          ),
        ),
      ),
      body: ListView.builder(
          // physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: imgData.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Color.fromRGBO(196, 196, 196, 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Prescription ${index + 1}',
                        // snapshot.data!.items[index].name,
                        style:
                            TextStyle(fontSize: 18, fontFamily: 'Convergence'),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              check[index] = !check[index];
                            });
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            size: 35,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                check[index]
                    ? Column(
                      children: [
                        Container(
                            //   width: 300,
                            // height: 150,
                            child: Container(
                              margin: EdgeInsets.only(top: 30),
                              height: 400,
                              width: 400,
                              color: Colors.transparent,
                              child: Image.network(
                                imgData[index]['url']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        SizedBox(height: 15,),

                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Findings from the Image',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
            imgData[index]['extractedText'],
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),

                      ],
                    )
                    : Container(),
              ],
            );
          }),

    );
  }
}
