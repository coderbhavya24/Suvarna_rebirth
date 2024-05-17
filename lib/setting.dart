import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swathyavardhak/login.dart';
import 'package:swathyavardhak/main.dart';
class Item {
  Item({
  required this.headerText,
  this.expandedText="",
  this.isExpanded = false,
});
  String headerText;
  String expandedText;
  bool isExpanded;
}

class SettingSwas extends StatefulWidget {
  // const SettingSwas({Key? key}) : super(key: key);
  String names ="d";
  SettingSwas(String name){
    this.names = name;
  }
  @override
  State<SettingSwas> createState() => _SettingSwasState(names);
}

class _SettingSwasState extends State<SettingSwas> {
  String names='d';
  _SettingSwasState(String name){
    this.names= name;
  }
  late Future<bool> _hasDocumentsFuture;
  bool _hasDocuments = false;

  @override
  void initState() {
    super.initState();
    _hasDocumentsFuture = hasDocuments('query_${names}');
    _hasDocumentsFuture.then((value) {
      setState(() {
        _hasDocuments = value;
      });
    });
  }
  // TextEditingController query = TextEditingController();
  final List<Item> _data = List<Item>.generate(10,  (int index){
    return Item(headerText: _questions[index]['question'].toString(),
   expandedText: _questions[index]['answers'].toString() );
  });
  TextEditingController querycontroller = new TextEditingController();
  @override

  int num=0;
  final blue1 = const Color(0xff0d0f35);
  bool j=true;
  Widget build(BuildContext context) {
    return Scaffold(
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
              Icon(
                Icons.camera_alt,
                size: 35,
                color: Colors.black,
              ),
            ),
            IconButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) {
                //     return SettingSwas();
                //   }),
                // );
              },
              icon: Icon(Icons.settings,
                color: Colors.white,),
              iconSize: 30,
            ),

            const SizedBox(),
          ],
        ),
      ),
      appBar: AppBar(

        automaticallyImplyLeading: false,
        // centerTitle: true,
        actions: [
          Container(
            padding: EdgeInsets.only(right: 12),
            child: PopupMenuButton(

              // child: Icon(Icons.list,
              // size: 30,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("FAQ'S"),
                ),
                // PopupMenuItem(
                //   child: Text("Flutter.io"),
                // ),
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: (){
                      FirebaseAuth.instance.signOut().then((value) {
                        print("Signed out");
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Mylogin()));
                      }).onError((error, stackTrace) {
                        print("Error ${error.toString()}");
                      });
                    },
                      child: Text("Log out")),
                ),
              ],
            ),
          )

        ],
        backgroundColor: blue1,
        title: Text('  Settings',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 25,
          fontFamily: 'Convergence'
        ),),
      ),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 20,top: 30),
                  child: Text('Ask your Queries',
                    style: TextStyle(
                      fontSize: 25,
                      // fontFamily: 'Convergence',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15,left: 20,right: 20),
                  child: TextField(
                    maxLines: 4,
                    controller: querycontroller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelText: 'Query',
                      labelStyle: TextStyle(
                          fontStyle: FontStyle.italic, fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        // margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.77),
                        padding: EdgeInsets.only(bottom:10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),

                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height*0.06,
                          width: MediaQuery.of(context).size.width*0.55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue1,
                            ),
                            onPressed: (){
                              addQuery();
                            },
                            child: const Text('Post Query',style: TextStyle(
                              fontFamily: 'Redhat',
                              fontSize: 18,
                            ),),
                          ),
                        )
                    ),
                  ],
                ),
                Center(

                  child: Text('Note - Your Query will be answered within\n            24 hours of your request',
                    style: TextStyle(
                      fontSize: 15,
                      // fontFamily: 'Convergence',
                    ),
                  ),
                ),
                _hasDocuments ?
                Container(
                  margin: EdgeInsets.only(left: 20,top: 30),
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('Your Queries',
                    style: TextStyle(
                      fontSize: 25,
                      // fontFamily: 'Convergence',
                    ),
                  ),
                ): Container(),
                Container(
                  child: SingleChildScrollView(
                    child: _buildExpansionPanelList(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20,top: 30),
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('FAQ\'s',
                    style: TextStyle(
                      fontSize: 25,
                      // fontFamily: 'Convergence',
                    ),
                  ),
                ),
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded){
                    setState(() {
                      _data[index].isExpanded= !isExpanded;
                    });
                  },
                  children: _data.map<ExpansionPanel>((Item item){
                    return ExpansionPanel(headerBuilder: (BuildContext context, bool isExpanded){
                      return ListTile(
                        title: Text(item.headerText),
                      );
                    },
                      body: ListTile(
                      title: Text(item.expandedText),
                    ),
                      isExpanded: item.isExpanded,
                    );
                  }).toList(),

                ),

              ],
            ),
      ),

    );
  }
  Widget _buildExpansionPanelList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('query_${names}').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<Map<String, dynamic>> firestoreData = snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          data['isExpanded'] = data['isExpanded'] ?? false; // Initially closed
          return data;
        }).toList();

        return ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              firestoreData[index]['isExpanded'] = !isExpanded;
              _updateExpansionState(snapshot.data!.docs[index].id, !isExpanded); // Update Firestore with the new expansion state
            });
          },
          children: firestoreData.map<ExpansionPanel>((Map<String, dynamic> data) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(data['Question'] ?? ''),
                );
              },
              body: ListTile(
                title: Text(data['Answer'] ?? ''),
              ),
              isExpanded: data['isExpanded'],
            );
          }).toList(),
        );
      },
    );
  }
  void _updateExpansionState(String documentId, bool isExpanded) {
    // Update the isExpanded state in Firestore for the given documentId
    FirebaseFirestore.instance.collection('query_${names}').doc(documentId).update({
      'isExpanded': isExpanded,
    });
  }
  Future<bool> hasDocuments(String collectionName) async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection(collectionName).limit(1).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error fetching documents: $e');
      return false;
    }
  }
  Future<void> addQuery() async {
    setState(() {
      _hasDocuments=true;
    });
    final user = FirebaseFirestore.instance.collection('query_${names}').doc();
    final json ={
      'Question': 'Q. ${querycontroller.text}',
      'Answer': 'Your answer will soon be visible',
      'isExpanded' : false,
    };
    await user.set(json)
        .then((value) => print("Query Added"))
        .catchError((error) => print("Failed to add Query: $error"));

    querycontroller.clear();
  }

}
final _questions = [
  {
    'question': 'Q1. What features does the app offer?',
    'answers': 'Ans. Our app offers features such as doctors\' handwriting recognition, medication schedule management, storing lab reports, prescriptions, and much more.'
  },
  {
    'question': 'Q2. How does the doctors\' handwriting recognition work?',
    'answers': 'Ans. Our app uses advanced machine learning algorithms to analyze and interpret doctors\' handwritten prescriptions, ensuring accurate transcription of medical instructions.'
  },
  {
    'question': 'Q3. Can I order medicines through this app?',
    'answers': 'Ans. Currently, the app does not support ordering medicines directly. However, we are working on integrating this feature in the future updates.'
  },
  {
    'question': 'Q4. How can I manage my medication schedule?',
    'answers': 'Ans. You can easily manage your medication schedule within the app by setting reminders for each dose and tracking your adherence.'
  },
  {
    'question': 'Q5. Is my medical data secure?',
    'answers': 'Ans. Yes, we prioritize the security and privacy of your medical data. Our app employs robust encryption protocols and follows strict privacy guidelines to safeguard your information.'
  },
  {
    'question': 'Q6. Can I store my lab reports in the app?',
    'answers': 'Ans. Absolutely! You can upload and store your lab reports securely in the app, allowing you to access them whenever needed.'
  },
  {
    'question': 'Q7. How can I share my medical records with my healthcare provider?',
    'answers': 'Ans. Our app enables you to easily share your medical records with your healthcare provider through secure channels, ensuring seamless communication and collaboration.'
  },
  {
    'question': 'Q8. Is the app available on multiple platforms?',
    'answers': 'Ans. Yes, our app is available on both iOS and Android platforms, ensuring compatibility with a wide range of devices.'
  },
  {
    'question': 'Q9. Can the app remind me of upcoming doctor appointments?',
    'answers': 'Ans. Absolutely! The app allows you to set reminders for upcoming doctor appointments, ensuring you never miss an important visit.'
  },
  {
    'question': 'Q10. How frequently is the app updated?',
    'answers': 'Ans. We strive to provide regular updates to our app, incorporating new features, improvements, and security enhancements based on user feedback and industry advancements.'
  }
];
