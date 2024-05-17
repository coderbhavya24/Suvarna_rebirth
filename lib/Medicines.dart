import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  String medname='a';
  String medtime='b';
  String medquan='c';
  List<Map<String, String>> morningEntries = [];
  List<Map<String, String>> midDayEntries = [];
  List<Map<String, String>> nightEntries = [];

  final blue1 = const Color(0xff0d0f35);
  // final MedicineService _medicineService = MedicineService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        leading: Container(),
        flexibleSpace: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.05,
            left: 20,
            right: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  "  Medicine",
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
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage('images/avata.png'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(context, 'Morning', morningEntries),
            _buildSection(context, 'Mid-Day', midDayEntries),
            _buildSection(context, 'Night', nightEntries),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Map<String, String>> entries) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: blue1,
            ),
          ),
          SizedBox(height: 10.0),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('${names}_med_$title').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Placeholder for loading state
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // Placeholder for error state
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No data available'); // Placeholder for empty state
              }
              // Data is available
              final entries = snapshot.data!.docs.map((doc) => doc.data()).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries.map<Widget>((entry) => _buildMedicineEntry(context, entry)).toList(),
              );
            },
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: entries
                .map<Widget>(
                  (entry) => _buildMedicineEntry(context, entry),
            )
                .toList(),
          ),
          SizedBox(height: 10.0),
          _buildAddButton(context, entries,title),
        ],
      ),
    );
  }


  Widget _buildAddButton(BuildContext context, List<Map<String, String>> entries, String title) {
    return TextButton.icon(
      onPressed: () async {
        // Show dialog to add entry
        Map<String, String?> result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            String? medicineName;
            String? timeToEat;
            String? quantity;
            return AlertDialog(
              title: Text('Add Medicine Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      medicineName = value;
                    },
                    decoration: InputDecoration(labelText: 'Medicine Name'),
                  ),
                  TextField(
                    onChanged: (value) {
                      timeToEat = value;
                    },
                    decoration: InputDecoration(labelText: 'Time to Eat'),
                  ),
                  TextField(
                    onChanged: (value) {
                      quantity = value;
                    },
                    decoration: InputDecoration(labelText: 'Quantity'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'medicineName': null, 'timeToEat': null, 'quantity': null}); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'medicineName': medicineName, 'timeToEat': timeToEat, 'quantity': quantity}); // Return the result
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );

        // Add the entry to the list if a result is returned
        if (result['medicineName'] != null && result['timeToEat'] != null && result['quantity'] != null) {
          setState(() {
            medquan=result['quantity']!;
            medtime=result['timeToEat']!;
            medname=result['medicineName']!;
            addUser(title);
            entries.add({
              'medicineName': result['medicineName']!,
              'timeToEat': result['timeToEat']!,
              'quantity': result['quantity']!,
            });
          });
        }
      },
      icon: Icon(Icons.add),
      label: Text('Add Entry'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Widget _buildMedicineEntry(BuildContext context, Object? entry) {
    if (entry == null) {
      return SizedBox(); // Return an empty widget if entry is null
    }

    final Map<String, dynamic> entryMap = entry as Map<String, dynamic>;

    final String? medicineName = entryMap['medicineName'] as String?;
    final String? timeToEat = entryMap['timeToEat'] as String?;
    final String? quantity = entryMap['quantity'] as String?;

    if (medicineName == null || timeToEat == null || quantity == null) {
      return SizedBox(); // Return an empty widget if any required data is null
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  timeToEat,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  // Remove the entry from the list
                  morningEntries.remove(entryMap);
                  midDayEntries.remove(entryMap);
                  nightEntries.remove(entryMap);
                });
              },
            ),
          ],
        ),
      ),
    );
  }



  Future<void> addUser(String time) async {
    final collection = FirebaseFirestore.instance.collection('${names}_med_${time}');

    final json = {
      'Name': medname,
      'Time': medtime,
      'Quantity': medquan,
    };

    final docRef = await collection.add(json); // Add the document and get the document reference

    // Retrieve the auto-generated document ID
    final documentID = docRef.id;

    // Update the document with the document ID
    await docRef.update({'DocumentID': documentID})
        .then((value) => print("User Added with Document ID: $documentID"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
