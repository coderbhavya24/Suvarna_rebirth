import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swathyavardhak/storage_serive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Retrieval extends StatefulWidget {
  // const Homescreen({key? key}) : super(key: key);
  String names="d";
  Retrieval(String name){
    this.names = name;
  }
  @override
  State<Retrieval> createState() => _RetrievalState(names);
}

class _RetrievalState extends State<Retrieval> {
  String names='d';
  _RetrievalState(String name){
    this.names=name;
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      appBar: AppBar(
        title: Text('Retrieval'),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: storage.listFiles(names),
              builder: (BuildContext context,
              AsyncSnapshot<firebase_storage.ListResult> snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData ){
                  return Container(
                    // padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (BuildContext context, int index){
                         return Container(
                            margin: EdgeInsets.only(top: 20,left: 10,right: 10),
                            height: 60,

                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              borderRadius : BorderRadius.all(Radius.circular(20)),
                              color: Color.fromRGBO(196, 196, 196, 1),

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text('Prescription ${index}',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'Convergence'
                                  ),),
                                Container(
                                  child: IconButton(
                                    onPressed: (){
                                      setState(() {
                                      });
                                    },
                                    icon: Icon(Icons.arrow_drop_down_circle_outlined,
                                      size: 35,),
                                  ),
                                )
                              ],
                            ),
                          );
                          return ElevatedButton(
                            onPressed: (){},
                            child: Text(snapshot.data!.items[index].name),

                          );

                        }),
                  );
                }
                if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData ){
                  return CircularProgressIndicator();
                }
                return Container();
              }
              ),
          FutureBuilder(
              future: storage.downloadURL('IMG-20230725-WA0028.jpg' , names),
              builder: (BuildContext context,
                  AsyncSnapshot<String> snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData ){
                  return Container(
                  //   width: 300,
                  // height: 150,
                  child: Container(
                    margin: EdgeInsets.only(top: 30),
                    height: 400,
                    width: 400,
                    color: Colors.transparent,
                    child: Image.network(
                      snapshot.data!
                      , fit: BoxFit.cover,),
                  ),
                  );
                }
                if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData ){
                  print(snapshot.hasData);
                  return CircularProgressIndicator();
                }
                return Container();
              }
          ),
        ],
      ),
    );
  }
}
