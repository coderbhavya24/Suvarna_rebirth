import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swathyavardhak/storage_serive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Retrieval extends StatefulWidget {
  // const Homescreen({key? key}) : super(key: key);

  @override
  State<Retrieval> createState() => _RetrievalState();
}

class _RetrievalState extends State<Retrieval> {
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
              future: storage.listFiles(),
              builder: (BuildContext context,
              AsyncSnapshot<firebase_storage.ListResult> snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData ){
                  return Container(
                    // padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 400,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (BuildContext context, int index){
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
              )
        ],
      ),
    );
  }
}
