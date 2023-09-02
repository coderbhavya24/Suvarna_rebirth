import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:swathyavardhak/storage_serive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Medicine extends StatefulWidget {
  // const Homescreen({key? key}) : super(key: key);
  String names="d";
  Medicine(String name){
    this.names = name;
  }
  @override
  State<Medicine> createState() => _MedicineState(names);
}

class _MedicineState extends State<Medicine> {
  String names='d';
  _MedicineState(String name){
    this.names=name;
  }
  List<bool> check = List<bool>.filled(100, false);
  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
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
                child: Text("  Medicine"
                  ,style: TextStyle(
                    fontFamily: 'Convergence',
                    fontWeight: FontWeight.w600,

                    fontSize: 32,
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
      body: ListView(
        children: [

          FutureBuilder(
              future: storage.listFiles(names),
              builder: (BuildContext context,
                  AsyncSnapshot<firebase_storage.ListResult> snapshot){
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData ){
                  return Container(
                    // padding: EdgeInsets.symmetric(horizontal: 20),

                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (BuildContext context, int index){
                          return Column(
                            children: [
                              Container(
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
                                    Text(
                                      'Medicine ${index+1}',
                                      // snapshot.data!.items[index].name,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Convergence'
                                      ),),
                                    Container(
                                      child: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            check[index] = !check[index];
                                          });
                                        },
                                        icon: Icon(Icons.arrow_drop_down_circle_outlined,
                                          size: 35,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              check[index] ?
                              FutureBuilder(
                                  future: storage.downloadURL(snapshot.data!.items[index].name , names),
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
                                      return Center(

                                          child: CircularProgressIndicator(strokeWidth: 8,

                                          ));
                                    }
                                    return Container();
                                  }
                              ) :
                              Container(),
                            ],
                          );

                        }),
                  );
                }
                if(snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData ){
                  return Center(

                      child: CircularProgressIndicator(strokeWidth: 8,

                      ));
                }
                return Container();
              }
          ),
        ],
      ),
    );
  }
}
